process MOSDEPTH {

    container 'quay.io/biocontainers/mosdepth:0.3.3--hd299d5a_3'

    publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/Coverage", mode: 'copy'

    label 'medium_parallel'

    tag "${meta.patient_id}|${meta.sample_id}"

    input:
    tuple val(meta), path(bam), path(bai)
    path(bed)

    output:
    tuple val(meta), path(genome_bed_coverage),path(genome_global_coverage), emit: coverage

    script:
    base_name = bam.getBaseName()
    genome_bed_coverage = base_name + ".mosdepth.region.dist.txt"
    genome_global_coverage = base_name + ".mosdepth.global.dist.txt"

    """
    mosdepth -t ${task.cpus} -n -x -Q 10 -b $bed $base_name $bam
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mosdepth: \$(mosdepth -h 2>1 | head -n1 | sed -e "s/mosdepth //g")
    END_VERSIONS
    """
}

