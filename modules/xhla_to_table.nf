process XHLA_TO_TABLE {
	
	tag "${meta.patient_id}|${meta.sample_id}"

	publishDir "${params.outdir}/${meta.patient_id}|${meta.sample_id}/XHLA", mode: 'copy'

	input:
	tuple val(meta),path(jsons)

	output:
	tuple val(meta),path(rtable), emit: results

	script:
	rtable = "${meta.patient_id}|${meta.sample_id}_xHLA.txt"

	"""
		xhla2table *.json >> $rtable
	"""

}
