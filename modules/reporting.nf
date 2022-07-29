process REPORT {

	publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}", mode: 'copy'

	input:
	val(meta),path(xhla)

	output:
	val(meta),path(pdf)

	script:
	sample = "${meta.patient_id}_${meta.sample_id}"
	pdf = "${sample}.pdf"
	
	"""
		report.rb -x ${xhla} -s ${sample} -v ${workflow.manifest.version}
	"""

}
