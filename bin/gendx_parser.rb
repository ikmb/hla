require 'pdf-reader'
require 'json'
require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
require 'optparse'
require 'ostruct'

### Define modules and classes here

def hisat_reconcile(list)
	answer = []
	list = list.map {|l| l.split("*")[-1]}

	if list.length <= 2
		answer = list.map {|l| l.split(" ")[0]}
	else

		list.each do |l|
			call = l.split(" ")[0]
			fraction = l.slice(/\d+\.\d+/).to_f
			# high-confidence call, take as-is
			if fraction > 0.8
				answer << calls
				list.delete(l)	
			end
		end
		# All low confidence calls get reduced to 3 digits in the hope that this pans out...
		grouped = list.group_by{|l| l.split(":")[0..2].join(":")}
		answer << grouped.keys.join("/")

	end

	if answer.length == 1
		answer << answer[0]
	end

	return answer
end
### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.banner = "A script description here"
opts.separator ""
opts.on("-p","--pdf", "=PDF","PDF report from GenDX") {|argument| options.pdf = argument }
opts.on("-j","--jsons", "=JSONS","Folder containing JSON reports") {|argument| options.jsons = argument }
opts.on("-o","--outfile", "=OUTFILE","Output file") {|argument| options.outfile = argument }
opts.on("-h","--help","Display the usage information") {
	puts opts
	exit
}

opts.parse!

abort "Path to JSON files not found" unless File.directory?(options.jsons)

even = "FFFFFF"
uneven = "93DDFF"

jsons = Dir["#{options.jsons}/*.json"]
abort "No JSON files in folder" if jsons.empty?

###########################
# READ PDF FILE 
############################
reader = PDF::Reader.new(options.pdf)

# Page 1 holds the main report
front = reader.pages[0]

text = front.text.split("\n")

results = {}

sample = nil

# Find the result lines
text.each do |line|
	
	line.strip!

	if line.match(/^Sample:\s.*/) && sample.nil?
		sample = line.split(/\s+/)[-1]
	end

	next unless line.match(/.*reviewed$/) 

        # Gene Allele 1           Allele 2           CWD 1    CWD 2    Review status

	gene,allele_a,allele_b,cwd_a,cwd_b,status = line.strip.split(/\s+/)

	alleles = [ allele_a,allele_b]

	# Clean additional characters resulting from footnotes by removing a potential third integer in the last position
	alleles.each_with_index do |a,i|
		last = a.strip.split(":")[-1]
		if last.length > 2
			alleles[i] = a.slice!(0..-2)
		end
	end

	# Sanitize gene name (HLA-A -> A)
	gene = gene.split("-")[-1]
	
	results[gene] = alleles.sort

end

abort "Could not find HLA calls in the PDF (format changed?!)" if results.keys.empty?

# FIND MATCHING JSON FILE
json = jsons.find{|j| j.include?(sample) }
abort "Could not find matching json file (#{sample}) under the path provided!"

# Build a HASH per gene, for each calling approach - starting with GenDX
if json

	# Create XLS sheet
	workbook = RubyXL::Workbook.new

	sheet = workbook.worksheets[0]
	sheet.sheet_name = sample

	row = 0
	col = 0

	bucket = {}

	j = JSON.parse(IO.readlines(json).join)

	###############################################
	# Add results from various tools to result HASH
	###############################################

	results.each do |gene,calls|
		bucket[gene] = { "GenDX" => calls }
		if j["calls"].has_key?(gene)
			l_calls = j["calls"][gene]
			l_calls.each do |tool,t_calls|

				# sanitize call names
				t_calls = t_calls.map {|tc| tc.split("*")[-1] }
				bucket[gene][tool] = t_calls.sort

			end
		else
			warn "Gene not found: #{gene}"
		end
	end

	################################
	# Construct the result XLS sheet
	################################

	header = []
	header << "Locus"
	bucket["A"].keys.map {|k| [ "#{k}-1", "#{k}-2" ] }.flatten.each {|k| header << k }

	# Write the table header
	header.each do |h|
		sheet.add_cell(row,col,h)
		sheet.sheet_data[row][col].change_fill(uneven)
		sheet.sheet_data[row][col].change_font_bold(true)
		sheet.change_column_width(col, 11)
		col += 1
	end

	col = 0
	row = 0

	bucket.each do |gene,calls|
		
		col = 0
		row += 1
		color = row.even? ? even : uneven

		# write the gene locus
		sheet.add_cell(row,col,gene)
		sheet.sheet_data[row][col].change_fill(color)
		sheet.sheet_data[row][col].change_font_bold(true)
		
		col += 1		

		gendx = calls["GenDX"]

		calls.each do |tool,tcalls|

			# jump 2 columns is this tool has no calls
			if tcalls.empty?
				sheet.add_cell(row,col,"")
				sheet.sheet_data[row][col].change_fill(color)
				col += 1
				sheet.add_cell(row,col,"")
				sheet.sheet_data[row][col].change_fill(color)
				col += 1

			# GenDX is our reference, just print
			elsif tool == "GenDX"
				
				tcalls.each do |t|
					sheet.add_cell(row,col,t)
					sheet.sheet_data[row][col].change_fill(color)
					col += 1
				end
			
			# Any other tool with existing calls
			else

				# Try to sanitize hisat outputs and reduce to minimum set of alleles
				if tool == "Hisat"
					tcalls = hisat_reconcile(tcalls)
				end
			
				tcalls = tcalls.select {|tc| tc.length > 1 }

				# if only one call exists, we assume it is homozygous and we double it. 
				if tcalls.length == 1
					tcalls << tcalls[0]
				end

				tcalls.sort[0..1].each_with_index do |t,i|

					t = t.split(" ")[0] unless t.nil?

					mismatch = false

					g = gendx[i]

					# check if the call matches the GenDX reference call
					# Sort and check if the shorter call fits into the larger call - else its a mismatch
					if g && t
						short,long = [t,g].sort
						mismatch = true unless long.include?(short)
					else
						mismatch = true
					end

					# write the call for this tool
					sheet.add_cell(row,col,t)
					sheet.sheet_data[row][col].change_fill(color)

					if mismatch
						sheet.sheet_data[row][col].change_fill("ff7c7c")						
					end

                    col += 1
				
				end
			
			end

		end # calls

		
	end # bucket
	
        workbook.write("#{sample}.xlsx")

else
	warn "No matching JSON found!"
end # json


