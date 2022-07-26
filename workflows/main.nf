include { INPUT_CHECK } from '../modules/input_check'
include { FASTP } from '../modules/fastp'
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

	SOFTWARE_VERSIONS(
		ch_versions.collect()
	)		
	
        MULTIQC(
           FASTP.out.json.collect()
        )

	emit:
	qc = MULTIQC.out.report
	
}
