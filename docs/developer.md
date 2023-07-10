# Development guide

This document provides some basic instructions on how to read and modify this code base. 

# Code structure

This pipelines uses Nextflow [DSL2](https://www.nextflow.io/docs/latest/dsl2.html) code conventions. The general structure can be broken down as follows:

- `main.nf` is the entry into the pipeline. It loads some library files and calls the actual workflow in `workflows/dragen.nf`
- `workflows/hla.nf` defines the main logic of the pipeline. It sets some key options, reads the samplesheet and calls the various subworkflows and modules
- `subworkflows/` location where self-contained processing chains are defined (also part of the pipeline logic).
- `modules/` the various process definitions that make up the pipeline
- `conf/` location of the general and site-specific config files
- `conf/resources.config` holds many of the important options about the location of reference files etc
- `assets` holds some of the (smaller) reference files needed by the pipeline, such as exome kit interval lists
- `bin` location of custom scripts needed by some of the pipeline processes
- `doc` the documentation lives here

# Metadata

This pipelines uses a hash object to pull information about patient and sample names through the various processing stages. This object is called `meta`. Use it to introduce metadata or
read out metadata to e.g. name output folders or files. 

# Inputs for subworkflows/modules

HLA typing tools use one of two inputs - either trimmed reads or pre-aligned BAM files. In both cases, data will be merged across sequencing lanes if applicable. 

Within the pipeline, you can grab these types of data from either `MERGED_READS.out.reads` [source](../subworkflows/merge_reads.nf) for trimmed and merge FastQ files or 
from `TRIM_AND_ALIGN.out.bam` [source](../subworkflows/align.nf) for pre-aligned and merged BAM files.

# Results

Tool-specific results are added to the `ch_reports` channel and grouped by the metadata object to combine all results belonging to the same patient and sample. If you add new tools
to the pipeline, make sure they add to this channel.

The actual aggregation of sample-specific results happens with help of the script [report.rb](../bin/report.rb). If you add new types of reports, or perform tool updates that change
the report format, you will have to modify this script (or replace it with something you can edit moving forward). It is, admittably, a but crummy in its current state. 

The script emits both a PDF formatted report as well as a JSON object that can be used for futher processing. The report, importantly, implements the `--precision` flag defined in the
nextflow config to trim alleles down to a desired resultion/precision. 





