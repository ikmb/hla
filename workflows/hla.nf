include { INPUT_CHECK } from '../modules/input_check'
include { TRIM_AND_ALIGN } from '../subworkflows/align'
include { XHLA_TYPING } from '../subworkflows/xhla'
include { HISAT_TYPING } from '../subworkflows/hisat'
include { SOFTWARE_VERSIONS } from '../modules/software_versions'
include { MULTIQC } from '../modules/multiqc'

// Input options
samplesheet = Channel.fromPath(params.samples)

tools = params.tools ? params.tools.split(',').collect{it.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '')} : []

ch_versions = Channel.from([])
ch_qc = Channel.from([])

// Workflow
workflow HLA {

	main:
	INPUT_CHECK(samplesheet)

	// Align reads to chromosome 6
	TRIM_AND_ALIGN(
		INPUT_CHECK.out.reads
	)
	//ch_versions = FASTP.out.version
	ch_qc = ch_qc.mix(TRIM_AND_ALIGN.out.qc)

	if ( 'hisat' in tools ) {
		HISAT_TYPING(
			TRIM_AND_ALIGN.out.reads
		)
	}

	if ('xhla' in tools) {
		XHLA_TYPING(
			TRIM_AND_ALIGN.out.bam
		)
	}
	
	SOFTWARE_VERSIONS(
		ch_versions.collect()
	)		
	
        MULTIQC(
           ch_qc.collect()
        )

	emit:
	qc = MULTIQC.out.report
	
}
