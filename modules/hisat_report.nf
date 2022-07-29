process HISAT_REPORT {

	input:
	tuple val(meta),path(result)

	output:
	tuple val(meta),path(report)

	script:

	report = "${meta.patient_id}_${meta.sample_id}_hisat.tsv"

	"""
		hisatgenotype_toolkit parse-results --csv --in-dir $result > $report
	"""

}
