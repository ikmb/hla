#!/usr/bin/env ruby
# == NAME
# json2xlsx.rb
#
# == AUTHOR
#  Marc Hoeppner, mphoeppner@gmail.com

require 'optparse'
require 'ostruct'
require 'json'
require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.on("-i","--outfile", "=INFILE","Infile file") {|argument| options.infile = argument }
opts.on("-o","--outfile", "=OUTFILE","Output file") {|argument| options.outfile = argument }
opts.on("-h","--help","Display the usage information") {
    puts opts
    exit
}

opts.parse!

workbook = RubyXL::Workbook.new

jsons = Dir["*.json"]

jsons.each_with_index do |json,i|

    header = [ "Gene" ]

    row = 1
    col = 0

    j = JSON.parse(IO.readlines(json).join)

    sample      = j["sample"].split("_")[0]
    calls       = j["calls"]
    pversion    = j["pipeline_version"]
    date        = j["date"]

    sheet = workbook.worksheets[i]
    sheet.sheet_name = sample

    calls.each do |gene,data|

        col = 0
        row += 1

        sheet.add_cell(row,col,gene)

        data.each do |tool,alleles|

            header = header + [ tool, "" ] unless header.include?(tool)

            if alleles.empty?
               col += 2
            else 
                # only one haplotype called, assume its hom
                alleles << alleles[0] if alleles.length < 2
                alleles.sort.each do |a| 
                    col += 1
                    sheet.add_cell(row,col,a)
                end
            end
        end
    end

    # Header comes last, apparently.... 
    header.flatten.each_with_index do |h,i|
        sheet.add_cell(0,i,h)
        sheet.sheet_data[0][i].change_font_bold(true)
    end

end

workbook.write(options.outfile)
