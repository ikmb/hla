include { CONCAT_FASTQ } from "./../modules/concat_fastq"
include { RENAME_READS } from "./../modules/rename_reads"

workflow MERGE_READS {

    take:
        reads

    main:
        CONCAT_FASTQ(
            reads.map { m,f,r -> 
                [[
                    sample_id: m.sample_id
                    patient_id: m.patient_id
                ],f,r]
            }.groupTuple()
        )

        RENAME_READS(
            CONCAT_FASTQ.out.reads
        )

    emit:
    reads = RENAME_READS.out.reads

´
}