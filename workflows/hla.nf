include { INPUT_CHECK } from '../modules/input_check'
include { TRIM_AND_ALIGN } from '../subworkflows/align'
include { XHLA_TYPING } from '../subworkflows/xhla'
include { HISAT_TYPING } from '../subworkflows/hisat'
include { SOFTWARE_VERSIONS } from '../modules/software_versions'
include { MULTIQC } from '../modules/multiqc'
include { OPTITYPE } from '../subworkflows/optitype'
include { REPORT } from '../modules/reporting'
include { HLASCAN } from '../modules/hlascan'

// Helper function for the sample sheet parsing to produce sane channel elements
def returnFile(it) {
    // Return file if it exists
    inputFile = file(it)
    if (!file(inputFile).exists()) exit 1, "Missing file in TSV file: ${inputFile}, see --help for more information"
    return inputFile
}

// Input options
if (params.samples) {
        Channel.from(file(params.samples, checkIfExists: true))
        .splitCsv(sep: ';', header: true)
        .map { row ->
			def meta = [:]
                        meta.patient_id = row.patientID
                        meta.sample_id = row.sampleID
			meta.library_id = row.libraryID
                        meta.readgroup_id = row.rgID
                        left = returnFile( row.R1 )
                        right = returnFile( row.R2)
                        [ meta, left, right ]
                }
       .set {  reads_fastp }
} else if (params.folder) {
        Channel.fromFilePairs(params.folder + "/*_L0*_R{1,2}_001.fastq.gz", flat: true)
        .ifEmpty { exit 1, "Did not find any reads matching your input pattern..." }
        .map { triple ->
		def meta = [:]
                meta.patient_id = triple[0].split("_")[0]
                meta.sample_id = triple[0].split("_")[1..-1].join("_").split("_L0")[0]
		meta.readgroup_id = triple[0].split("_L0")[0]
		meta.library_id = triple[0].split("_")[1..-1].join("_").split("_L0")[0]
                tuple( meta,triple[1],triple[2])
        }
        .set { reads_fastp }
} else if (params.reads) {
        Channel.fromFilePairs(params.reads, flat: true)
        .ifEmpty { exit 1, "Did not find any reads matching your input pattern..." }
        .map { triple ->

		def meta = [:]
                meta.patient_id = triple[0].split("_")[0]
                meta.sample_id = triple[0].split("_")[1..-1].join("_").split("_L0")[0]
                meta.readgroup_id = triple[0].split("_L0")[0]
                meta.library_id = triple[0].split("_")[1..-1].join("_").split("_L0")[0]
                tuple( meta,triple[1],triple[2])
                
        }
        .set { reads_fastp }
}

tools = params.tools ? params.tools.split(',').collect{it.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '')} : []

ch_genes = Channel.fromList(params.hla_genes)

ch_bed = Channel.fromPath("$baseDir/assets/targets/genes.bed", checkIfExists: true)

ch_versions = Channel.from([])
ch_qc = Channel.from([])
ch_reports = Channel.from([])

// Workflow
workflow HLA {

	main:

	// Align reads to chromosome 6
	TRIM_AND_ALIGN(
		reads_fastp,
		ch_bed
	)
	//ch_versions = FASTP.out.version
	ch_qc = ch_qc.mix(TRIM_AND_ALIGN.out.qc)
	ch_qc = ch_qc.mix(TRIM_AND_ALIGN.out.bedcov.map { m,r -> r } )

	if ( 'hisat' in tools ) {
		HISAT_TYPING(
			TRIM_AND_ALIGN.out.reads,
			params.hla_genes.join(",")
		)
		ch_reports = ch_reports.mix(HISAT_TYPING.out.report)
	}

	if ('xhla' in tools) {
		XHLA_TYPING(
			TRIM_AND_ALIGN.out.bam
		)
		ch_reports = ch_reports.mix(XHLA_TYPING.out.report)
	}

	if ( 'hlascan' in tools) {
		HLASCAN(
			TRIM_AND_ALIGN.out.bam.combine(ch_genes)
		)
		ch_reports = ch_reports.mix(HLASCAN.out.report)
	}

	if ('optitype' in tools) {
		OPTITYPE(
			TRIM_AND_ALIGN.out.reads
		)
		ch_reports = ch_reports.mix(OPTITYPE.out.report)
	}
	
	REPORT(
		ch_reports.groupTuple()
	)

	SOFTWARE_VERSIONS(
		ch_versions.collect()
	)		
	
        MULTIQC(
           ch_qc.collect()
        )

	emit:
	qc = MULTIQC.out.report
	
}
