process HLASCAN {

	tag "${meta.sample_id}|${gene}"
	input:
	tuple val(meta),path(bam),path(bai)
	val(gene)

	output:
	tuple val(meta),path(results), emit: report
	
	script:
	results = meta.sample_id + "_hlascan.txt"

	"""
		/opt/hlascan/hla_scan -b $bam -d ${params.hlascan_db} -v 38 -t ${task.cpus} -g HLA-${gene} > $results
	"""
}
