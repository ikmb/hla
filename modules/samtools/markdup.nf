process SAMTOOLS_MARKDUP {

    tag 'short_parallel'

    container 'quay.io/biocontainers/samtools:1.16.1--h6899075_1'    

    tag "${meta.patient_id}|${meta.sample_id}"

    publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/", mode: 'copy'

    input:
    tuple val(meta),path(merged_bam),path(merged_bam_index)
    tuple path(fasta),path(fai),path(dict)

    output:
    tuple val(meta), path(outfile_bam),path(outfile_bai), emit: bam
    path(outfile_md5), emit: md5sum
    path(outfile_metrics), emit: report
    path("versions.yml"), emit: versions

    script:
    def prefix = "${meta.patient_id}_${meta.sample_id}-dedup"
    outfile_bam = prefix + ".bam"
    outfile_bai = prefix + ".bam.bai"
    outfile_md5 = prefix + ".bam.md5"
    outfile_metrics = prefix + "_duplicate_metrics.txt"

    """
    samtools markdup -@ ${task.cpus} --reference $fasta $merged_bam $outfile_bam
    samtools index $outfile_bam
    samtools stats $outfile_bam > $outfile_metrics
    md5sum $outfile_bam > $outfile_md5

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS

    """

}
