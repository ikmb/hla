process REPORT {

    tag "${meta.patient_id}|${meta.sample_id}"

    publishDir "${params.outdir}/Reports", mode: 'copy'

    input:
    tuple val(meta),path(reports),path(coverage)
    val(precision)

    output:
    tuple val(meta),path(json), emit: json

    script:
    sample = "${meta.sample_id}"
    json = "${sample}.json"
    
    """
        report_with_cov.rb -c $coverage -s ${sample} -v ${workflow.manifest.version} -p $precision
    """

}

process JSON2PDF {

    tag "${meta.patient_id}|${meta.sample_id}"

    publishDir "${params.outdir}/Reports", mode: 'copy'

    input:
    tuple val(meta),path(json)

    output:
    tuple val(meta),path(pdf), emit: pdf

    script:
    sample = "${meta.sample_id}"
    pdf = "${sample}.pdf"
    
    """
        json2pdf.rb -j ${json} -o $pdf
    """
}

process JSON2XLS_SUMMARY {

    tag "All"

    publishDir "${params.outdir}/Reports", mode: 'copy'

    input:
    path(jsons)

    output:
    path(xls)

    script:
    xls = params.run_name + ".xlsx"

    """
        json2xls_summary.rb --outfile $xls
    """
}

process JSON2XLS {

    tag "All"

    publishDir "${params.outdir}/Reports", mode: 'copy'

    input:
    tuple val(meta),path(jsons)

    output:
    path(xls)

    when:
    params.excel

    script:
    xls = meta.sample_id + "-report.xlsx"

    """
        json2xls_single.rb --infile $json --outfile $xls
    """
}
