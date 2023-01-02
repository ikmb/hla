process HISAT_GENOTYPE {

	tag "${meta.patient_id}|${meta.sample_id}"

	publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}", mode: 'copy'

	input:
	tuple val(meta),path(left),path(right)
	val(genes)

	output:
	tuple val(meta),path("hisatgenotype_out"), emit: results

	script:
	def genes = params.hla_genes.join(",")

	"""
		hisatgenotype --index_dir ${params.hisat_genome_index} --base hla -p ${task.cpus}  --locus-list $genes -1 $left -2 $right 
	"""
}
