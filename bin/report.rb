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

alleles =  { "A" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  }, 
    "B" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  },
    "C" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  },
    "DQB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  },
    "DRB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  },
    "DRB4" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  },
    "DRB5" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  },
    "DQA1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  },
    "DRB3" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  },
    "DPA1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  },
    "DPB1" => { "xHLA" => [], "Hisat" => [], "Optitype" => [], "HLAscan" => [], "HLA-HD" => []  }
}

# Options
## Only show hisat results supported at this level
hisat_cutoff = 0.3

# Find result files
files = Dir["*"]
xhla = files.find{|f| f.upcase.include?("XHLA") }
hisat = files.find{|f| f.upcase.include?("HISAT") }
optitype = files.find{|f| f.upcase.include?("OPTI") }
hlascan = files.select {|f| f.upcase.include?("HLASCAN") }
hlahd = files.find {|f| f.upcase.include?("HLAHD") }

# The header of the result table, only including those tools we actually have data for. 
rheader = [ "HLA Genes" ]

########################
# HLA-HD data processing
########################

if hlahd 

    IO.readlines(hlahd).each do |line|
        
        line.strip!
        # A       HLA-A*24:02:01  HLA-A*01:01:01

        gene,a,b = line.split("\t")
        if alleles.has_key?(gene)
            a = "" if a.include?("Not typed")
            b = "" if b.include?("Not typed")
            alleles[gene]["HLA-HD"] = [ a,b ]
        end

    end
    rheader << "HLA-HD"
end

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

        next unless alleles.has_key?(gene)

        allele_1 = ""
        allele_2 = ""

        first = lines.find {|l| l.include?("Type 1") }
        second = lines.find {|l| l.include?("Type 2") }

        if first
            allele_1 = "#{gene}*#{first.split(/\s+/)[2]}"
        end
        if second
            allele_2 = "#{gene}*#{second.split(/\s+/)[2]}"
        end
        
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

        if h.include?("Allele splitting: ")
            gene = h.split(" ")[-1]
            tmp = info[i]
            tmp.split(",").each do |t|
                # C*08 - Trimmed (score: 0.9090),C*08:02 - Trimmed (score: 0.3636)
                # We show percentages for ambiguous calls, but only >= 20% fraction
                c = t.split(" ")[0].strip
                abundance = t.split(" ")[-1].gsub(")","")
                f = abundance.split("%")[0].to_f
                next if f < hisat_cutoff
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

alleles.keys.sort.each do |k|
    r = [ k ]
    this_result = [ k ]
    rheader[1..-1].each do |h|
        this_result << alleles[k][h].sort.map {|a| a.split("*")[-1]}.join("\n")
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
