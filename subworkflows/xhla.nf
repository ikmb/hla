include { XHLA } from './../modules/xhla'

workflow XHLA_TYPING {

	take:
	bam
	
	main:

	XHLA(
		bam
	)
	
	
}
