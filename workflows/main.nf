include { INPUT_CHECK } from '../modules/input_check'
include { FASTP } from '../modules/fastp'
//include { XHLA_TYPING } from '../subworkflows/xhla'
include { HISAT } from '../subworkflows/hisat'
include { SOFTWARE_VERSIONS } from '../modules/software_versions'

workflow MAIN {

	take:
	samplesheet
	
	main:
	INPUT_CHECK(samplesheet)
        FASTP(
           INPUT_CHECK.out.reads
        )
	ch_versions = FASTP.out.version

	HISAT(
		FASTP.out.reads
	)
	
	SOFTWARE_VERSIONS(
		ch_versions.collect()
	)		
	
        MULTIQC(
           TRIM_AND_ALIGN.out.qc.collect()
        )

	emit:
	qc = MULTIQC.out.report
	
}
