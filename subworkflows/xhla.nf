include { XHLA } from './../modules/xhla'

ch_versions = Channel.from([])
workflow XHLA_TYPING {

	take:
	bam
	
	main:

	XHLA(
		bam
	)

	ch_versions = ch_versions.mix(XHLA.out.versions)
	
	emit:
	report = XHLA.out.results
	versions = ch_versions
	
}
