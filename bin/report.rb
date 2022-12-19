#!/usr/bin/env ruby
# == NAME
# script_skeleton.rb
#
# == USAGE
# ./this_script.rb [ -h | --help ]
#[ -i | --infile ] |[ -o | --outfile ] | 
# == DESCRIPTION
# A skeleton script for Ruby
#
# == OPTIONS
# -h,--help Show help
# -i,--infile=INFILE input file
# -o,--outfile=OUTFILE : output file

#
# == EXPERT OPTIONS
#
# == AUTHOR
#  Marc Hoeppner, mphoeppner@gmail.com

require 'optparse'
require 'ostruct'
require 'json'
require 'prawn'
require 'prawn/table'
require 'date'

### Define modules and classes here

### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.banner = "A script description here"
opts.separator ""
opts.on("-s","--sample", "=SAMPLE","Sample name") {|argument| options.sample = argument }
opts.on("-v","--version", "=VERSION","PipelineVersion") {|argument| options.version = argument }
opts.on("-o","--outfile", "=OUTFILE","Output file") {|argument| options.outfile = argument }
opts.on("-h","--help","Display the usage information") {
 puts opts
 exit
}

opts.parse! 

sample = options.sample

alleles =  { "A" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => []  }, 
	"B" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => []  },
	"C" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => []  },
	"DPB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => []  },
	"DQB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => []  },
	"DRB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => []  },
	"DQA1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => []  },
	"DPA1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => []  },
	"DPB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => []  }
}

# Find result files
files = Dir["*"]
xhla = files.find{|f| f.upcase.include?("XHLA") }
hisat = files.find{|f| f.upcase.include?("HISAT") }
optitype = files.find{|f| f.upcase.include?("OPTI") }
hlascan = files.select {|f| f.upcase.include?("HLASCAN") }

# The header of the result table, only including those tools we actually have data for. 
rheader = [ "HLA Genes" ]

########################
### xHLA data processing
########################

if xhla

	json = JSON.parse( IO.readlines(xhla).join )

	this_alleles = json["hla"]["alleles"]

	alleles.keys.each do |k|

		this_alleles.select {|al| al.match(/^#{k}.*/) }.each {|a| alleles[k]["xHLA"] << a }
	end

	rheader << "xHLA"
end

###########################
### HLAscan data processing
###########################

unless hlascan.empty?

	hlascan.each do |h|

		lines = IO.readlines(h)
		gene_line = lines.find {|l| l.include?("HLA gene") }

		next unless gene_line

		gene = gene_line.split(" ")[-1].split("-")[-1]

		allele_1 = "???"
		allele_2 = "???"

		first = lines.find {|l| l.include?("Type 1") }
		second = lines.find {|l| l.include?("Type 2") }

		if first
			allele_1 = "#{gene}*#{first.split(/\s+/)[2]}"
		end
		if second
			allele_2 = "#{gene}*#{second.split(/\s+/)[2]}"
		end
		
		warn gene	

		alleles[gene]["HLAscan"] << allele_1
		alleles[gene]["HLAscan"] << allele_2

	end

	rheader << "HLAscan"

end

############################
### Optitype data processing
############################

if optitype

	lines = IO.readlines(optitype)[0..1]
	header = lines.shift.strip.split(/\t/)

	# 0       A*26:01 A*30:01 B*13:02 B*38:01 C*06:02 C*12:03 4526.0  4281.585999999999

	e = lines.shift.strip.split(/\t/)

	header.each_with_index do |h,i|
		if h.match(/^A.*/)
			alleles["A"]["Optitype"] << e[i+1]
		elsif h.match(/^B.*/)
			alleles["B"]["Optitype"] << e[i+1]
		elsif h.match(/^C.*/)
			alleles["C"]["Optitype"] << e[i+1]
		end
	end

	rheader << "Optitype"

end
	

#############################
#### Hisat Genotype
#############################

if hisat

	# 1 ranked B*35:08:01 (abundance: 50.20%) 

	lines = IO.readlines(hisat)
	header = lines.shift.split("\t")

	info = lines.shift.split("\t")


	header.each_with_index do |h,i|

		if h.include?("EM: ")
			gene = h.split(" ")[-1]
			tmp = info[i]
			tmp.split(",").each do |t|
				# C*07:01:01:01 (abundance: 50.46%),C*01:02:01 (abundance: 49.54%) 
				# We show percentages for ambiguous calls, but only >= 20% fraction
				c = t.split(" ")[0].strip
				abundance = t.split(" ")[-1].gsub(")","")
				f = abundance.split("%")[0].to_f
				next if f < 20.0
                                alleles[gene]["Hisat"] << "#{c} (#{abundance})"
                        end
		end
	end

	rheader << "Hisat"
end

			
# -------------------------------------------
# PDF Generation
# -------------------------------------------

date = Date.today.strftime("%d.%m.%Y")

footer = "Bericht erstellt am: #{date} | Pipeline version: github.com/ikmb/hla:#{options.version}"

pdf = Prawn::Document.new

pdf.font("Helvetica")
pdf.font_size 14

pdf.text "IKMB - HLA Typisierung mittels Sequenzierung (NGS)"

pdf.move_down 5
pdf.stroke_horizontal_rule

pdf.font_size 10
pdf.move_down 5
pdf.text "Probe: #{sample}"
pdf.move_down 5
pdf.text "Qualität: OK"
pdf.move_down 20

# Table content
results = []
results << rheader # table header

alleles.keys.each do |k|
	r = [ k ]
	this_result = [ k ]
	rheader[1..-1].each do |h|
		this_result << alleles[k][h].sort.join("\n")
	end
	results << this_result
end

warn results.inspect

t = pdf.make_table( 
	results,
	:header => true
 )

t.draw

pdf.move_cursor_to 30
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.font_size 8
pdf.move_down 5
pdf.text footer

pdf.render_file("#{sample}.pdf")

f = File.new("#{sample}.json","w+")
data = { "sample" => sample, "calls" => alleles, "pipeline_version" => options.version, "date" => date }
f.puts data.to_json
f.close
