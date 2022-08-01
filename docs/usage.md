# Usage information

This pipeline is configured to run on the IKMB MedCluster and DX Cluster. 

## Basic execution

To run this pipeline, use the following syntax:

```
nextflow run ikmb/hla --samples Samples.csv --tools 'xhla,hisat,optitype' -profile standard
```

## Options

### Input(s)

#### `--samples`

This pipeline accepts input data in CSV format. The format should look as follows:

```
patientID;sampleID;libraryID;rgID;R1;R2
PatientA;Sample1;22Oct21_S3;C41232CXX.1.22Oct21_S3;/path/to/R1.fastq.gz;/path/to/R2.fastq.gz
```

This is the preffered input option as it provide more control over the naming and grouping of the data. 

A simple ruby script is included with this pipeline to produce this file from a folder of FastQ files. However, please check 
the output to make sure that it correctly recognized the file names etc.

```
ruby samplesheet_from_folder.rb -f /path/to/data
```

This can then be used as input like so:

```
nextflow run ikmb/hla --samples Samples.csv
```

#### `--folder`

Input folder containing paired-end fastQ files.

```
nextflow run ikmb/hla --folder '/path/to/folder'
```

#### `--reads`

A regular expression pointing to a set of paired-end fastQ files. 

```
nextflow run ikmb/hla --reads '/path/to/*_R{1,2}_001.fastq.gz'
```

### `--tools`

This pipeline supports several competing tool chains for HLA calling. Specify them with this option as a comma-separated list. 

```
nextflow run ikmb/hla --samples Samples.csv --tools 'hisat,xhla,optitype' 
```

Supported tools:

* [xHLA](https://github.com/humanlongevity/HLA) (xhla)
* [Hisat-genotype](https://daehwankimlab.github.io/hisat-genotype/) (hisat)
* [Optitype](https://github.com/FRED-2/OptiType) (optitype)

### `--run_name`

Provide a descriptive name for this analysis run. 

## Testing the pipeline

This pipeline has a built-in test. To run it, simply provide the appropriate profile and test config. On MedCluster, this would look like so:

```
nextflow run ikmb/hla -profile standard,test
```

