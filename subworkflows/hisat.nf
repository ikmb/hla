include { HISAT_GENOTYPE } from "./../modules/hisat/genotype"
include { HISAT_REPORT } from "./../modules/hisat/report"


workflow HISAT_TYPING {

	take:
		reads

	main:
		HISAT_GENOTYPE(
			reads
		)
	
		HISAT_REPORT(
			HISAT_GENOTYPE.out.results
		)

	emit:
	results = HISAT_GENOTYPE.out.results
	report = HISAT_REPORT.out.tsv

}
