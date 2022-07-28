include { FASTP } from "./../modules/fastp"
include { BWA } from "./../modules/bwa"
include { MERGE_MULTI_LANE } from "./../modules/samtools/merge_multi_lane"
include { BAM_INDEX }  from "./../modules/samtools/bam_index"
include { DEDUP } from "./../modules/samtools/dedup"

workflow TRIM_AND_ALIGN {

	take:
		reads
	main:

		ch_versions = Channel.from([])

		FASTP(
			reads
                )
		BWA( FASTP.out.reads )
		bam_mapped = BWA.out.bam.map { meta, bam ->
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

		MERGE_MULTI_LANE( bam_to_merge.multiple )
		BAM_INDEX(MERGE_MULTI_LANE.out.bam.mix( bam_to_merge.single ))

		DEDUP(BAM_INDEX.out.bam)
		ch_final_bam = DEDUP.out.bam
		
	emit:
		reads = FASTP.out.reads
		bam = ch_final_bam
		qc = FASTP.out.json
		dedup_report = DEDUP.out.report
		sample_names = BWA.out.sample_name.unique()
		metas = BWA.out.meta_data
		versions = ch_versions.collect()
}

