process REPORT {

    tag "${meta.patient_id}|${meta.sample_id}"

    publishDir "${params.outdir}/Reports", mode: 'copy'

    input:
    tuple val(meta),path(reports)
    val(precision)

    output:
    tuple val(meta),path(pdf), emit: pdf
    tuple val(meta),path(json), emit: json

    script:
    sample = "${meta.sample_id}"
    json = "${sample}.json"
    pdf = "${sample}.pdf"
    
    """
        report.rb -s ${sample} -v ${workflow.manifest.version} -p $precision
    """

}

process JSON2XLS {

    container 'ikmb/exome-seq:5.2'

    tag "All"

    publishDir "${params.outdir}/Reports", mode: 'copy'

    input:
    path(jsons)

    output:
    path(xls)

    when:
    params.excel

    script:
    xls = params.run_name + "-report.xlsx"

    """
        json2xls.rb --outfile $xls
    """
}
