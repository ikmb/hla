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

### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.banner = "A script description here"
opts.separator ""
opts.on("-j","--json", "=JSON","JSON input") {|argument| options.json = argument }
opts.on("-l","--logo", "=LOGO","Logo to include") {|argument| options.logo = argument }
opts.on("-o","--outfile", "=OUTFILE","Output file") {|argument| options.outfile = argument }
opts.on("-h","--help","Display the usage information") {
    puts opts
    exit
}

opts.parse! 

json = JSON.parse(IO.readlines(options.json).join("\n"))

calls       = json["calls"]
sample      = json["sample"]
version     = json["pipeline_version"]

data        = []
header      = []

# Transform the JSON structure into something Prawn can make a table from (array of arrays)
calls.each do |gene,results|

    if header.empty?
        header = [ "Locus" ] + results.keys
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

footer = "Bericht erstellt am: #{date} | Pipeline version: github.com/ikmb/hla:#{version}"

pdf = Prawn::Document.new

pdf.font("Helvetica")
pdf.font_size 14

pdf.image(options.logo, :at => [400,730], :width => 150 )

pdf.move_down 5

pdf.text "IKMB - HLA Typisierung mittels Sequenzierung (NGS)"

pdf.move_down 5
pdf.stroke_horizontal_rule

pdf.font_size 10
pdf.move_down 5
pdf.text "Probe: #{sample}"
pdf.move_down 20

t = pdf.make_table( 
    data,
    :header => true
)

t.draw

pdf.move_cursor_to 30
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.font_size 8
pdf.move_down 5
pdf.text footer

pdf.render_file(options.outfile)
