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

def calculate_precision(list)
    data = {}

    list.each do |alleles|
        data.has_key?(alleles) ? data[alleles] += 1 : data[alleles] = 1
    end

    return data
end

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

jsons       = Dir["*.json"]
pversion    = nil
date        = nil
bucket      = {}
coverages   = {}
genes       = []

jsons.each do |json|

    j = JSON.parse(IO.readlines(json).join)

    sample      = j["sample"] #.split("_")[0]
    calls       = j["calls"]
    pversion    = j["pipeline_version"]
    date        = j["date"]
    coverages[sample] = j["coverage"] 
        
    calls.each do |gene,data|

        this_data = { "sample" => sample, "data" => data }
        bucket.has_key?(gene) ? bucket[gene] << this_data : bucket[gene] = [ this_data ]

    end

end

row = 0
col = 0

sheet = workbook.worksheets[0]
sheet.sheet_name = "Summary"

sheet.add_cell(row,col,"Results in this document are provided as-is and without any guarantees regarding accuracy!")
row += 2
sheet.add_cell(row,col,"Samples under spec")
row+= 2
sheet.add_cell(row,col,"Sample")
sheet.add_cell(row,col+1,"Exons < 30X")
sheet.add_cell(row,col+2,"Exons < 10X")

coverages.keys.sort.each do |k|

    row += 1
    col = 0

    sub_30 = 0
    sub_10 = 0

    cov = coverages[k]
    cov.each do |gene,exons|
        exons.each do |e|
            mean_cov = e["mean_cov"]
            if mean_cov < 30.0
                sub_30 +=1
            end
            if mean_cov < 10.0
                sub_10 += 1
            end
        end
    end

    sheet.add_cell(row,col,k)
    sheet.add_cell(row,col+1,sub_30)
    sheet.add_cell(row,col+2,sub_10)

end

bucket.keys.sort.each_with_index do |gene,i|
    
    sheet               = workbook.add_worksheet(gene)
    data                = bucket[gene]

    row = 0
    col = 0

    keys = data[0]["data"].keys
    header = [ "Sample" ] + keys + [ "Majority call" ]

    header.flatten.each_with_index do |h,i|
        sheet.add_cell(row,i,h)
        sheet.sheet_data[row][i].change_font_bold(true)
    end
    
    data.each do |calls|

        row += 1
        col = 0

        this_data   = calls["data"]
        sample      = calls["sample"]

        #warn this_data.inspect

        values = []

        sheet.add_cell(row,col,sample)
        col += 1

        keys.each do |k|
            abort "Missing tool #{k} from data object" unless this_data.has_key?(k)
            val = this_data[k].uniq
            if k == "Hisat" && val.length <= 2
                val = val.collect {|v| v.split(" ")[0]}
            end
            
            values << val.sort.join(", ")
        end

        prec = calculate_precision(values.select{|v| v.strip.length > 0 })

        prec.keys.empty? ? best = "" : best = prec.sort_by(&:last)[-1][0]

        all_counts = prec.values 
        best_count = prec[best]

        # more than one best option - call conflict
        if all_counts.select {|c| c == best_count }.length > 1
            best = "CONFLICT"
            warn "Conflict (#{gene}: #{sample})"
        end

        values.each do |value|
            sheet.add_cell(row,col,value)
            color = "CDCDCD"
            if value.strip.length > 0 && best != "CONFLICT"
                value == best ? color = "9AF79D" : color = "FE9B43"
            end
            
            sheet.sheet_data[row][col].change_fill(color)
            col += 1
        end

        sheet.add_cell(row,col,best)
        #sheet.change_row_fill(row, color)
    end

end

workbook.write(options.outfile)
