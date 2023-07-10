include { OPTITYPE_FILTER } from './../modules/optitype/filter'
include { OPTITYPE_RUN } from './../modules/optitype/optitype'

ch_versions = Channel.from([])

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
    
    ch_versions = ch_versions.mix(OPTITYPE_RUN.out.versions)

    emit:
    report = OPTITYPE_RUN.out.tsv    
    versions = ch_versions
    
}
