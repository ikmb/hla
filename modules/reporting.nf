process REPORT {

	publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}", mode: 'copy'

	input:
	tuple val(meta),path(reports)

	output:
	tuple val(meta),path(pdf), emit: pdf
	tuple val(meta),path(json), emit: json

	script:
	sample = "${meta.patient_id}_${meta.sample_id}"
	json = "${sample}.json"
	pdf = "${sample}.pdf"
	
	"""
		report.rb -s ${sample} -v ${workflow.manifest.version}
	"""

}
