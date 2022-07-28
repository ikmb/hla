include { HISAT_GENOTYPE } from "./../modules/hisat_genotype"

workflow HISAT_TYPING {

	take:
		reads

	main:
		HISAT_GENOTYPE(
			reads
		)

	emit:
	hisat = HISAT_GENOTYPE.out.genotypes

}
