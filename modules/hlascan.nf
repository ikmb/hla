process HLASCAN {

	publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}", mode: 'copy'
	
	tag "${meta.sample_id}|${gene}"

	input:
	tuple val(meta),path(bam),path(bai),val(gene)

	output:
	tuple val(meta),path(txt), emit: report
	
	script:
	txt = meta.sample_id + "_" + gene + "_hlascan.txt"

	"""
		hla_scan -b $bam -d ${params.hlascan_db} -v 38 -t ${task.cpus} -g HLA-${gene} > $txt 2> /dev/null || true
		touch yeah.txt
	"""
}
