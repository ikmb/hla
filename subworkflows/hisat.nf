include { HISAT_GENOTYPE } from "./../modules/hisat_genotype"

workflow HISAT {

	take:
		reads

	
	main:
		HISAT_GENOTYOPE(
			reads
		)

	emit:
	hisat = HISAT_GENOTYPE.out.genotypes

}
