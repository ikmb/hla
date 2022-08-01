#!/usr/bin/ruby
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

alleles =  { "A" => { "xHLA" => [], "Hisat" => [], "Optitype" => []  }, 
	"B" => { "xHLA" => [], "Hisat" => [], "Optitype" => []  },
	"C" => { "xHLA" => [], "Hisat" => [], "Optitype" => []  },
	"DPB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => []  },
	"DQB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => []  },
	"DRB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => []  },
	"DQA1" => { "xHLA" => [], "Hisat" => [], "Optitype" => []  }
}

files = Dir["*"]
xhla = files.find{|f| f.upcase.include?("XHLA") }
hisat = files.find{|f| f.upcase.include?("HISAT") }
optitype = files.find{|f| f.upcase.include?("OPTI") }

########################
### xHLA data processing
########################

if xhla

	json = JSON.parse( IO.readlines(xhla).join )

	this_alleles = json["hla"]["alleles"]

	alleles.keys.each do |k|

		alleles[k]["xHLA"] << this_alleles.select {|al| al.match(/^#{k}.*/) }
	end
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

end
	

# -------------------------------------------
# PDF Generation
# -------------------------------------------

date = Date.today.strftime("%d.%m.%Y")

footer = "Bericht erstellt am: #{date} | Pipeline version: #{options.version}"

pdf = Prawn::Document.new

pdf.font("Helvetica")
pdf.font_size 14

pdf.text "HLA Typisierung mittels Sequenzierung (NGS)"

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
results << [ "Allele", "xHLA (Nicht-kommerziell)", "Hisat", "Optitype" ]
alleles.keys.each do |k|
	results << [ k, alleles[k]["xHLA"].join(", "), "", alleles[k]["Optitype"].join(", ") ]
end

t = pdf.make_table( 
	results
 )

t.draw

pdf.move_cursor_to 30
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.font_size 8
pdf.move_down 5
pdf.text footer

pdf.render_file("#{sample}_report.pdf")

f = File.new("#{sample}.json","w+")
data = { "sample" => sample, "calls" => alleles, "pipeline_version" => options.version, "date" => date }
f.puts data.to_json
f.close