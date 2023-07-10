include { HISAT_GENOTYPE } from "./../modules/hisat/genotype"
include { HISAT_REPORT } from "./../modules/hisat/report"

ch_versions = Channel.from([])

workflow HISAT_TYPING {

    take:
    reads
    genes

    main:

    HISAT_GENOTYPE(
        reads,
        genes.collect()
    )
    
    ch_versions = ch_versions.mix(HISAT_GENOTYPE.out.versions)

    HISAT_REPORT(
        HISAT_GENOTYPE.out.results,
        params.precision
    )

    emit:
    results = HISAT_GENOTYPE.out.results
    report = HISAT_REPORT.out.tsv
    versions = ch_versions

}
