require 'pdf-reader'
require 'json'
require 'csv'
require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
require 'optparse'
require 'ostruct'

### Define modules and classes here

# Compare to HLA calls and see if they match on those position that they share
def match_calls(list)

	short = list.shift.strip.split(":")
	long = list.shift.strip.split(":")
	
	mismatch = false
	
	short.each_with_index do |s,i|
		l = long[i]
		mismatch = true unless s == l
	end
	
	return mismatch
	
end

# Check calls across all tools to find the best-supported one
def get_majority_call(calls)

    bucket = {}
    calls.each do |c|
        next if c.empty?
        combined = c.join(",")
        bucket.has_key?(combined) ? bucket[combined] += 1 : bucket[combined] = 1
    end

    sorted = bucket.sort_by{|k,v| v}.reverse

    best = sorted[0]

    best_name = best.shift
    best_value = best.shift

    sorted.select{|s| s[1] == best_value }.length > 1 ? conflict = true : conflict = false

    conflict ? answer =  "Ambigious" : answer = best_name

    return answer

end

# Reduce resolution of HLA calls to the desired level (e.g., 2 = xx:xx)
def trim_allele(call,precision)

    answer = nil
    e = call.split(":")
    if e.length > precision
        answer = e[0..precision-1].join(":")
    else 
        answer = call
    end

    return answer
end

# Try to sanitize HiSat calls to only emit the best-guess diploid call
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
opts.on("-c","--csv", "=CSV","CSV report from GenDX") {|argument| options.csv = argument }
opts.on("-f","--precision", "=PRECISION","PPrecision of HLA comparison") {|argument| options.precision = argument }
opts.on("-j","--jsons", "=JSONS","Folder containing JSON reports") {|argument| options.jsons = argument }
opts.on("-o","--outfile", "=OUTFILE","Output file") {|argument| options.outfile = argument }
opts.on("-h","--help","Display the usage information") {
    puts opts
    exit
}

opts.parse!

abort "Must provide (valid) name for result file" unless options.outfile && options.outfile.include?(".xlsx")

options.precision ? precision = options.precision.to_i : precision = 2

abort "Path to JSON files not found" unless File.directory?(options.jsons)

# Set some basic variables we will use later

even        = "FFFFFF"
uneven      = "93DDFF"

jsons       = Dir["#{options.jsons}/*.json"]

abort "No JSON files in folder" if jsons.empty?

bucket      = {}

genes       = []

###########################
# READ LOOKUPS
###########################
p_group_file = IO.readlines(File.expand_path(File.dirname(__FILE__)) + "/../assets/hla_nom_p.txt")

groups = {}

p_group_file.each do |line|

    next if line.match(/^#.*/)

    e = line.strip.split(";")
    if e.length == 3

        allele,acalls,group = line.split(";")
        allele.gsub!("*", "").strip
        calls = acalls.split("/").collect{|c| c.split(":")[0..precision-1].join(":")}.uniq
    
        unless group.nil?
            groups[allele] = {} unless groups.has_key?(allele)
            groups[allele][group.strip] = calls
        end
        
    end
end


results     = {}
sample      = nil
        
if options.pdf

    ###########################
    # READ PDF FILE 
    ############################
    reader = PDF::Reader.new(options.pdf)

    # read the GenDX PDF report, page by page
    reader.pages.each_with_index do |page,i|

        warn "Parsing page #{i}"

        text = page.text.split("\n")

        # Find the result lines
        text.each do |line|

            line.strip!

            # best-guess on how to find the current sample name
            if line.match(/^Sample:\s.*/) && !line.include?("NGSengine")

                unless results.empty?
                    bucket[sample] = results
                end

                results = {}

                sample = line.split(/\s+/)[-1]

            end

            # GenDX calls are apparently listed on lines together with the *reviewed string
            next unless line.match(/.*reviewed$/) 

            # Gene Allele 1           Allele 2           CWD 1    CWD 2    Review status

            gene,allele_a,allele_b,cwd_a,cwd_b,status = line.strip.split(/\s+/)

            # Parsing the alleles
            alleles = [ trim_allele(allele_a,precision),trim_allele(allele_b,precision)]

            # Clean additional characters resulting from footnotes by removing a potential third integer in the last position
            #alleles.each_with_index do |a,i|
            #    last = a.strip.split(":")[-1]
            #    if last.length > 2
            #        alleles[i] = a.slice!(0..-2)
            #    end
            #end

            # Sanitize gene name (HLA-A -> A)
            gene = gene.split("-")[-1]
            
            genes << gene unless genes.include?(gene)
            results[gene] = alleles.sort

            # this should not happen and suggests an issue parsing the report. 
            exit if gene.include?("*")
            
        end

    end

    # Clean up the final dangling sample
    bucket[sample] = results

    abort "Could not find HLA calls in the PDF (format changed?!)" if bucket.keys.empty?

elsif options.csv

    csv = CSV.read(options.csv, headers: true, col_sep: ';')

    this_sample = nil
        
    csv.each do |row|
    
        sample = row["Sample name"]
        locus = row["Locus"]
        locus.include?("_") ? gene = locus.split("_")[1] : gene = locus
        genes << gene unless genes.include?(gene)
            
        calls = row["Typing result"]
        
        if calls.include?(",")
	        alleles = calls.split(",").map {|c| trim_allele(c.strip.split("*")[-1],precision) }
	else
		alleles = [ "NoCall", "NoCall" ]
	end
        
        if this_sample && this_sample != sample
        
            bucket[this_sample] = results
            results = {}
            
        end
        
        results[gene] = alleles.sort
        this_sample = sample
                                                                                    
    end
    
    bucket[this_sample] = results
                                                    
else

    abort "Must provide a GenDX input (--pdf or --csv)"
    
end

# Create XLS sheet
workbook = RubyXL::Workbook.new

# Store samples that are present in the GenDX report not do not have a JSON report (omitted by pipeline?)
missing_samples = []

# We report this gene by gene rather than per-sample
genes.sort.each do |gene|

    warn gene
    
    sheet   = workbook.add_worksheet(gene)

    row     = 0
    col     = 0

    data  = {}

    bucket.each do |sample,results|
    
        # We find the matching JSON report or record the sample as missing
        json = jsons.find{|j| j.include?(sample) }

        missing_samples << sample unless json
        
        next unless json
        
        j = JSON.parse(IO.readlines(json).join)

        ###############################################
        # Add results from various tools to result HASH
        ###############################################

        # Getting the results for this gene and sample across all tools
        calls = results[gene]

	if calls.nil?  
		calls = [ "NoCall","NoCall" ]      
	end

	if calls.empty?
		calls = [ "NoCall","NoCall" ]
	end
	
        data[sample] = { "GenDX" => calls }

        if j["calls"].has_key?(gene)
            l_calls = j["calls"][gene]
            l_calls.each do |tool,t_calls|

                # sanitize call names
                t_calls = t_calls.map {|tc| trim_allele(tc.split("*")[-1],precision) }
                data[sample][tool] = t_calls.sort

            end
        else
            warn "Gene #{gene} not found: #{gene} in #{j['calls'].inspect}"
        end

    end

    ################################
    # Construct the result XLS sheet
    ################################

    header = []
    header << "Sample"

    # add names of all the tools to the header
    data.first[1].keys.map {|k| [ "#{k}-1", "#{k}-2" ] }.flatten.each {|k| header << k }

    header << "MajorityCall"

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

    data.each do |sample,calls|
            
        col = 0
        row += 1

        color = row.even? ? even : uneven

        sample_calls = []

        # write the gene locus
        sheet.add_cell(row,col,sample)
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

                sample_calls << tcalls
                
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

                sample_calls << tcalls

                tcalls.sort[0..1].each_with_index do |t,i|

                    t = t.split(" ")[0] unless t.nil?

                    mismatch = false

                    g = gendx[i]

                    # check if the call matches the GenDX reference call
                    # Sort and check if the shorter call fits into the larger call - else its a mismatch
                    if g && t

                        if g.include?("P")
                            g.gsub!(/\d$/, "")
                            if groups.has_key?(gene) && groups[gene].has_key?(g)
                                dictionary = groups[gene][g]
                                unless dictionary.include?(t.strip)   
                                    mismatch = true 
                                    warn "Could not find #{t} in #{dictionary.join(',')}"
                                end
                            else
                                abort "Missing dictionary entry for #{gene} #{g}!"
                            end
                                
                        else
                            #short,long = [t,g].sort
                            scalls = [t,g].sort
                            mismatch = match_calls(scalls)
                            #mismatch = true unless long.include?(short)
                        end
                    else
                        mismatch = true
                    end

                    issues = true if mismatch

                    # write the call for this tool
                    sheet.add_cell(row,col,t)
                    sheet.sheet_data[row][col].change_fill(color)

                    if mismatch
                        sheet.sheet_data[row][col].change_fill("ff7c7c")                        
                    end

                    col += 1
                                    
                end # tcalls
                
            end # else

        end # calls

        # majority call
        mc = get_majority_call(sample_calls)

        sheet.add_cell(row,col,mc)        
        sheet.sheet_data[row][col].change_fill(color)


    end # data

end # genes

workbook.write("#{options.outfile}")

missing_samples.uniq.each do |ms|
    warn "Could not find JSON for #{ms} - omitting sample!"
end

