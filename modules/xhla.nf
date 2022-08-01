process XHLA {

	container "docker://humanlongevity/hla:latest"
	
	tag "${meta.patient_id}|${meta.sample_id}"

	publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/xHLA", mode: 'copy'

	input:
	tuple val(meta),path(bam),path(bai)

	output:
	tuple val(meta),path(result), emit: results

	script:
	sample_id = "${meta.patient_id}_${meta.sample_id}"
	result = sample_id + ".xHLA.json"

	script:

	"""
		run.py --sample_id $sample_id --input_bam $bam --output_path report --delete
		cp report/*.json $result
	"""
}
