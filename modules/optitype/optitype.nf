process OPTITYPE_RUN {

	tag "${meta.patient_id}|${meta.sample_id}"

	publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/optitype", mode: 'copy'

	label 'optitype'

	input:
	tuple val(meta),path(left),path(right)

	output:
	tuple val(meta),path(tsv), emit: tsv

	script:
	results = "optitype_out"
	tsv = "${meta.patient_id}_${meta.sample_id}-optitype.tsv"
	"""
		cp ${baseDir}/assets/optitype/config.ini .
		OptiTypePipeline.py -i $left $right --dna -e 3 -c config.ini --outdir $results
		cp optitype_out/*/*.tsv $tsv
	"""


}
