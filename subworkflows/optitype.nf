include { OPTITYPE_FILTER } from './../modules/optitype/filter'
include { OPTITYPE_RUN } from './../modules/optitype/optitype'

workflow OPTITYPE {

	take:
	reads

	main:
	OPTITYPE_FILTER(
		reads
	)
	OPTITYPE_RUN(
		OPTITYPE_FILTER.out.reads
	)
	
	emit:
	report = OPTITYPE_RUN.out.tsv	
}
