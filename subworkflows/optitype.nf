include { OPTITYPE_FILTER } from './../modules/optitype/filter'
include { OPTITYPE_RUN } from './../modules/optitype/optitype'
include { FASTQ_MERGE } from './../modules/fastq_merge'

ch_versions = Channel.from([])

workflow OPTITYPE {

	take:
	reads

	main:

	reads.map { meta, l, r ->
        new_meta = [:]
        new_meta.patient_id = meta.patient_id
        new_meta.sample_id = meta.sample_id
        def groupKey = meta.sample_id
        tuple( groupKey, new_meta, l,r)
    }.groupTuple(by: [0,1]).map { g ,new_meta ,l,r -> [ new_meta,l,r ] }.branch {
        single:   it[1].size() == 1
        multiple: it[1].size() > 1
    }.set { reads_to_merge }

	FASTQ_MERGE(
		reads_to_merge.multiple
	)

	OPTITYPE_FILTER(
		reads_to_merge.single.mix(FASTQ_MERGE.out.reads)

	)
	OPTITYPE_RUN(
		OPTITYPE_FILTER.out.reads
	)
	
	ch_versions = ch_versions.mix(OPTITYPE_RUN.out.versions)

	emit:
	report = OPTITYPE_RUN.out.tsv	
	versions = ch_versions
	
}
