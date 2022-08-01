process FASTQ_MERGE {

	tag "${meta.patient_id}|${meta.sample_id}"

	input:

	tuple val(meta),path(left),path(right)

	output:
	tuple val(meta),path(R1),path(R2), emit: reads

	script:

	R1 = "${meta.patient_id}_${meta.sample_id}_R1_001.fastq.gz"
	R2 = "${meta.patient_id}_${meta.sample_id}_R2_001.fastq.gz"

	"""
		zcat $left | gzip -c > $R1
		zcat $right | gzip -c > $R2
	"""

}
