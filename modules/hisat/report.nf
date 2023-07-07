process HISAT_REPORT {

    tag "${meta.patient_id}|${meta.sample_id}"

    publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}", mode: 'copy'

    input:
    tuple val(meta),path(result)
    val(precision)

    output:
    tuple val(meta),path(report), emit: tsv

    script:

    report = "${meta.patient_id}_${meta.sample_id}.hisat.tsv"

    """
        hisatgenotype_toolkit parse-results --csv --in-dir $result --trim $precision --output-file $report
    """

}
