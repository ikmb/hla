include { CONCAT_FASTQ } from "./../modules/concat_fastq"
include { RENAME_READS } from "./../modules/rename_reads"

workflow MERGE_READS {

    take:
        reads

    main:

        reads.map { meta, l, r ->
            new_meta = [:]
            new_meta.patient_id = meta.patient_id
            new_meta.sample_id = meta.sample_id
            def groupKey = meta.sample_id
            tuple( groupKey, new_meta, l, r)
        }.groupTuple(by: [0,1]).map { g ,new_meta ,l,r -> [ new_meta,l,r ] }.branch {
            single:   it[1].size() == 1
            multiple: it[1].size() > 1
        }.set { reads_to_merge }

        CONCAT_FASTQ(
            reads_to_merge.multiple
        )

        ch_reads = reads_to_merge.single.mix(CONCAT_FASTQ.out.reads)

        RENAME_READS(
            ch_reads
        )

    emit:
    reads = ch_reads
    renamed_reads = RENAME_READS.out.reads


}
