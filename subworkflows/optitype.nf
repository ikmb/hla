include { OPTITYPE_FILTER } from './../modules/optitype/filter'
include { OPTITYPE } from './../modules/optitype/optitype'

workflow OPTITYPE {

	take:
	reads

	main:
	OPTITYPE_FILTER(
		reads
	)
	OPTITYPE(
		OPTITYPE_FILTER.out.reads
	)
	
}
