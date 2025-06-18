#!/usr/bin/env ruby
# == NAME
# report.rb
#
# == USAGE
# ./this_script.rb [ -h | --help ]
#[ -i | --infile ] |[ -o | --outfile ] | 
# == DESCRIPTION
# A script to parse raw results from the ikmb/hla pipeline
#
# == OPTIONS
# -h,--help Show help
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

def build_intervals(regions)

    answer = []

    regions.each_with_index do |region,i|

        exon = { "type" => "exon", "start" => region[0].to_i, "stop" => region[1].to_i , "coverage" => region[-1]}
        
        unless region == regions.first
            prev_exon = answer[-1]
            intron = {"type" => "intron", "start" => prev_exon["stop"]+1, "stop" => exon["start"]-1 }
            answer << intron
        end

        answer << exon

    end
    return answer
end
### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.banner = "A script description here"
opts.separator ""
opts.on("-j","--json", "=JSON","JSON input") {|argument| options.json = argument }
opts.on("-o","--outfile", "=OUTFILE","Output file") {|argument| options.outfile = argument }
opts.on("-h","--help","Display the usage information") {
    puts opts
    exit
}

opts.parse! 

coverage            = {}
genes               = {}

json = JSON.parse(IO.readlines(options.json).join("\n"))

calls               = json["calls"]
sample              = json["sample"]
version             = json["pipeline_version"]
commercial_tools    = json["commercial_tools"]

data                = []
header              = []

cov_data            = json["coverage"]

cov_data.each do |gene,data|

    data.each do |d|
    
        if genes.has_key?(gene)
            genes[gene]["exons"] << [ d["start"], d["stop"], d["mean_cov"] ]
        else
            genes[gene] = { "strand" => d["strand"], "exons" => [ [ d["start"], d["stop"], d["mean_cov"] ] ] }
        end

        coverage["exon"] = d["mean_cov"]

    end

end

has_disclaimer = false

# Transform the JSON structure into something Prawn can make a table from (array of arrays)
calls.each do |gene,results|

    rk = results.keys
    tools = []
    rk.each do |r|
        commercial_tools.include?(r) ? tools << "#{r}*" : tools << r
    end

    if header.empty?
        header = [ "Locus" ] + tools
        data << header
    end

    this_data = [ gene ] 

    results.each do |tool,alleles|
        astring = alleles.select{|a| a.length > 1}.sort.join(", ")
        this_data << astring
    end

    data << this_data
end

# -------------------------------------------
# PDF Generation
# -------------------------------------------

date = Date.today.strftime("%d.%m.%Y")

footer = "Report created: #{date} | Pipeline version: github.com/ikmb/hla:#{version}"

pdf = Prawn::Document.new

pdf.font("Helvetica")
pdf.font_size 14

pdf.move_down 5

pdf.text "IKMB - HLA Typing from short read sequencing data"

pdf.move_down 5
pdf.stroke_horizontal_rule

pdf.font_size 10
pdf.move_down 5
pdf.text "Sample: #{sample}"
pdf.move_down 20

t = pdf.make_table( 
    data,
    :header => true
)

t.draw
pdf.move_down 5
pdf.font_size 8

pdf.text "Tool results marked with '*' may only be used in academic research!"

pdf.move_cursor_to 30
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.text footer


if coverage.keys.length > 0

    max_width = 300

    pdf.start_new_page

    h = 200

    pdf.font_size 12
    pdf.text "Mean sequencing depth of relevant exons"
    pdf.move_down 5
    pdf.stroke_horizontal_rule

    pdf.font_size 10
    pdf.move_down 5
    pdf.text "Green: >= 30X, Orange: >= 10X, Red: < 10X"

    genes.each do |gene,data|

        exons = data["exons"]
        strand = data["strand"]

        exons.reverse! if strand == "-"
        
        h += 5

        pos = 10

        start = exons[0][0]
        stop  = exons[-1][1]

        len = stop.to_i-start.to_i

        intervals = build_intervals(exons)
        
        pdf.bounding_box([pos,h], width: 500, height: 30) do 

            pdf.fill_color "000000"

            pdf.text gene

            intervals.each do |interval|
                istart = interval["start"]
                istop = interval["stop"]
                ilen = istop-istart
                typ = interval["type"]
                
                if typ == "exon"
                    height = 10
                    mod = 0
                    coverage = interval["coverage"]
                    if coverage >= 30
                        pdf.fill_color = "0EBB09"
                    elsif coverage >= 10
                        pdf.fill_color = "E48607"
                    else
                        pdf.fill_color = "E40707"
                    end
                else
                    height = 6
                    mod = 2
                    pdf.fill_color = "CDCDCD"
                end

                i_norm_len = ((ilen.to_f/len.to_f)*max_width).round()
                i_norm_len = 1 if i_norm_len < 1
            
                pdf.fill { pdf.rectangle [pos,20-mod], i_norm_len, height }
                pos += i_norm_len
            end    
        end

        h += 50

    end

    pdf.fill_color "000000"

    pdf.move_cursor_to 30
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    pdf.font_size 8
    pdf.move_down 5
    pdf.text footer

end


pdf.render_file(options.outfile)
