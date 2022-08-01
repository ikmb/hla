process REPORT {

	publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}", mode: 'copy'

	input:
	tuple val(meta),path(reports)

	output:
	tuple val(meta),path(pdf)

	script:
	sample = "${meta.patient_id}_${meta.sample_id}"
	pdf = "${sample}.pdf"
	
	"""
		report.rb -s ${sample} -v ${workflow.manifest.version}
	"""

}
