process HISAT_GENOTYPE {

	tag "${meta.patient_id}|${meta.sample_id}"

	publishDir "${params.outdir}/${meta.patient_id}|${meta.sample_id}", mode: 'copy'

	input:
	tuple val(meta),path(left),path(right)

	output:
	tuple val(meta),path("hisatgenotype_out"), emit: genotypes	

	script:

	"""
		hisatgenotype --index_dir ${params.hisat_genome_index} --base hla -p ${task.cpus} --locus-list A,B,C,DRB1,DQA1 -1 $left -2 $right 
	"""
}
