include { FASTP } from "./../modules/fastp"
include { BWA_MEM } from "./../modules/bwa/mem"
include { SAMTOOLS_MERGE } from "./../modules/samtools/merge"
include { SAMTOOLS_INDEX }  from "./../modules/samtools/index"
include { SAMTOOLS_MARKDUP } from "./../modules/samtools/markdup"
include { SAMTOOLS_BEDCOV } from "./../modules/samtools/bedcov"
include { MOSDEPTH } from "./../modules/mosdepth/main"

ch_versions = Channel.from([])

workflow TRIM_AND_ALIGN {

    take:
        reads
        bed
        genome_index
        ch_fasta

    main:

        FASTP(
            reads
        )

        ch_versions = ch_versions.mix(FASTP.out.versions)

        // weed out all the files that did not survive the trimming, i.e are smaller than 500kb in size...
        FASTP.out.reads.branch { m,f,r ->
            trimmed: file(f).size() >= 500000
            failed: file(f).size() < 500000
        }.set { ch_reads }

        ch_reads.failed.view { m,f,r -> "Discarding ${m.sample_id} due to low read count..."}

        BWA_MEM( 
            ch_reads.trimmed,
            genome_index
        )

        ch_versions = ch_versions.mix(BWA_MEM.out.versions)

        bam_mapped = BWA_MEM.out.bam.map { meta, bam ->
            new_meta = [:]
            new_meta.patient_id = meta.patient_id
            new_meta.sample_id = meta.sample_id
            def groupKey = meta.sample_id
            tuple( groupKey, new_meta, bam)
        }.groupTuple(by: [0,1]).map { g ,new_meta ,bam -> [ new_meta, bam ] }
            
        bam_mapped.branch {
            single:   it[1].size() == 1
            multiple: it[1].size() > 1
        }.set { bam_to_merge }

        SAMTOOLS_MERGE( 
            bam_to_merge.multiple 
        )

        ch_versions = ch_versions.mix(SAMTOOLS_MERGE.out.versions)
        
        SAMTOOLS_INDEX(
            SAMTOOLS_MERGE.out.bam.mix( 
                bam_to_merge.single 
            )
        )
    
        ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions)

        SAMTOOLS_BEDCOV(
            SAMTOOLS_INDEX.out.bam,
            bed.collect()
        )

        MOSDEPTH(
            SAMTOOLS_INDEX.out.bam,
            bed.collect()
        )
        
        SAMTOOLS_MARKDUP(
            SAMTOOLS_INDEX.out.bam,
            ch_fasta.collect()
        )
        ch_final_bam = SAMTOOLS_MARKDUP.out.bam
        
        ch_versions = ch_versions.mix(SAMTOOLS_MARKDUP.out.versions)

    emit:
        reads           = ch_reads.trimmed
        bedcov          = SAMTOOLS_BEDCOV.out.report
        mosdepth        = MOSDEPTH.out.coverage
        bam             = ch_final_bam
        qc              = FASTP.out.json
        dedup_report    = SAMTOOLS_MARKDUP.out.report
        sample_names    = BWA_MEM.out.sample_name.unique()
        metas           = BWA_MEM.out.meta_data
        versions        = ch_versions
}

