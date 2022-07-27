process XHLA {
	
	tag "${meta.patient_id}|${meta.sample_id}"

	publishDir "${meta.patient_id}|${meta.sample_id}", mode: 'copy'

	input:
	tuple val(meta),path(bam),path(bai)

	output:
	tuple val(meta),path("${results}/*.json"), emit: results

	script:
	results = "${meta.patient_id}|${meta.sample_id}_xHLA"

	script:

	"""
		run.py --sample_id ${meta.sample_id} --input_bam $bam --output_path $results
	"""
}
