#!/bin/env ruby

require 'optparse'
require 'ostruct'

### Define modules and classes here

### Get the script arguments and open relevant files
options = OpenStruct.new()
opts = OptionParser.new()
opts.banner = "Reads Fastq files from a folder and writes a sample sheet to STDOUT"
opts.separator ""
opts.on("-f","--folder", "=FOLDER","Folder to scan") {|argument| options.folder = argument }
opts.on("-l","--lookup", "=FOLDER","Lookup file") {|argument| options.lookup = argument }
opts.on("-s","--sanity", "Perform sanity check of md5 sums") { options.sanity = true }
opts.on("-h","--help","Display the usage information") {
 puts opts
 exit
}

opts.parse! 

abort "Folder not found (#{options.folder})" unless File.directory?(options.folder)

bucket = {}
if options.lookup
    abort "Lookup file not found - please check path!" unless File.exist?(options.lookup)
    IO.readlines(options.lookup).each do |l|
        lib,name = l.strip.split("\t")
        bucket[lib] = name
    end
end

date = Time.now.strftime("%Y-%m-%d")

options.centre ? center = options.centre : center = "IKMB"

fastq_files = Dir["#{options.folder}/*_R*.fastq.gz"]

# 221200000285-DS9_22Dez285-DL009_S9_L001_R2_001.fastq.gz
groups = fastq_files.group_by{|f| f.split("/")[-1].split(/_/)[1] }

warn "Building input sample sheet from FASTQ folder"
warn "Performing sanity check on md5sums" if options.sanity

options.platform ? sequencer = options.platform : sequencer = "NovaSeq6000"

puts "patient;sample;library;rgid;R1;R2"

individuals = []
samples = []

# group = the library id, may be split across lanes
groups.each do |group, files|

    warn "...processing library #{group}"

    library = group
    individual = group

    bucket.has_key?(group) ? sample = bucket[group] : sample = group

    individuals << individual
    samples << sample

    pairs = files.group_by{|f| f.split("/")[-1].split(/_R[1,2]/)[0] }

    pairs.each do |p,reads|

        left,right = reads.sort.collect{|f| File.absolute_path(f)}
    
        abort "This sample seems to not be a set of PE files! #{p}" unless left && right

        # Perform optional MD5 sum check in data
        if options.sanity
            Dir.chdir(options.folder) {
                [left,right].each do |fastq|
                    fastq_simple = fastq.split("/")[-1].strip
                    raise "Aborting - no md5sum found for fastq file #{fastq}" unless File.exists?(fastq_simple + ".md5")
                    status = `md5sum -c #{fastq_simple}.md5`
                    raise "Aborting - failed md5sum check for #{fastq}" unless status.strip.include?("OK")
                end
            }
        end

        # Extract read information to build readgroup names
        e = `zcat #{left} | head -n1 `
        header = e

        instrument,run_id,flowcell_id,lane,tile,x,y = header.split(" ")[0].split(":")

        index = header.split(" ")[-1].split(":")[-1]
        readgroup = flowcell_id + "." + lane + "." + library 

        pgu = flowcell_id + "." + lane + "." + index

        puts "#{individual};#{sample};#{library};#{readgroup};#{left};#{right}"
    end
end


warn "Found: #{individuals.uniq.length} Patients."
warn "Found: #{samples.uniq.length} Samples."
warn "If these numbers do not seem right, please re-check the file naming and manually fix the samplesheet."

