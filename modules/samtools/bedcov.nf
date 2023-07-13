process SAMTOOLS_BEDCOV {

    label 'short_serial'

    tag "${meta.patient_id}|${meta.sample_id}"

    publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/Coverage", mode: 'copy'

    input:
    tuple val(meta),path(bam),path(bai)
    path(bed)

    output:
    tuple val(meta), path(report), emit: report
    path("versions.yml"), emit: versions
    
    script:
    def prefix = "${meta.patient_id}_${meta.sample_id}.dedup"
    report = prefix + ".bedcov.txt"

    """
    samtools bedcov -Q 1 $bed $bam > $report

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

}
