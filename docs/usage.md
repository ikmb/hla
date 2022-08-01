# Usage information

This pipeline is configured to run on the IKMB MedCluster and DX Cluster. 

## Basic execution

To run this pipeline, use the following syntax:

```
nextflow run ikmb/hla --samples Samples.csv --tools 'xhla,hisat,optitype' -profile standard
```

## Options

### `--samples`

The pipeline expects a CSV-formatted samplesheet as input. The format should look as follows:

```
patientID;sampleID;libraryID;rgID;R1;R2
PatientA;Sample1;22Oct21_S3;C41232CXX.1.22Oct21_S3;/path/to/R1.fastq.gz;/path/to/R2.fastq.gz
```

A simple ruby script is included with this pipeline to produce this file from a folder of FastQ files. However, please check 
the output to make sure that it correctly recognized the file names etc.

```
ruby samplesheet_from_folder.rb -f /path/to/data
```

### `tools`

This pipeline supports several competing tool chains for HLA calling. Specify them with this option as a comma-separated list. 

```
nextflow run ikmb/hla --samples Samples.csv --tools 'hisat,xhla,optitype'
```

Supported tools:

* xHLA (xhla)
* Hisat-genotype (hisat)
* Optitype (optitype)



