process HISAT_GENOTYPE {

    tag "${meta.patient_id}|${meta.sample_id}"

    label 'medium_parallel'

    publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}", mode: 'copy'

    input:
    tuple val(meta),path(left),path(right)
    val(genes)

    output:
    tuple val(meta),path("hisatgenotype_out"), emit: results
    path("versions.yml"), emit: versions
    
    script:
    def gene_list = params.hla_genes.join(",")

    """
    hisatgenotype --index_dir ${params.hisat_genome_index} --base hla -p ${task.cpus}  --locus-list $gene_list -1 $left -2 $right 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hisatgenotype: \$(echo \$(hisatgenotype -h 2>&1) | grep HISAT-Genotype | sed 's/^HISAT-Genotype //' | sed 's/ .* //')
    END_VERSIONS
    
    """
}
