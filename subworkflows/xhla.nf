include { XHLA } from './../modules/xhla.nf'
include { XHLTA_TO_TABLE } from '/../modules/xhla_to_table.nf'

workflow XHLA_TYPING {

	take:
	bam
	
	main:
	XHLA(
		bam
	)
	XHLA_TO_TABLE(
		XHLA.out.results
	)
	
	emit:
	xhla = XHLA_TO_TABLE.out.results
	
}
