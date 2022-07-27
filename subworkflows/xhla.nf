include { XHLA } from './../modules/xhla'
//include { XHLTA_TO_TABLE } from './../modules/xhla_to_table'
include { ALIGN } from './../modules/bwa'
include { MERGE_MULTI_LANE } from './../modules/samtools/merge_multi_lane'
include { BAM_INDEX } from './../modules/samtools/bam_index'

workflow XHLA_TYPING {

	take:
	reads
	
	main:
	ALIGN(
		reads
	)
        bam_mapped = ALIGN.out.bam.map { meta, bam ->
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

	XHLA(
		BAM_INDEX.out.bam
	)
	
	
}
