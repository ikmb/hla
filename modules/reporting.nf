process REPORT {

    tag "${meta.patient_id}|${meta.sample_id}"

    publishDir "${params.outdir}/Reports", mode: 'copy'

    input:
    tuple val(meta),path(reports)
    val(precision)

    output:
    tuple val(meta),path(json), emit: json

    script:
    sample = "${meta.sample_id}"
    json = "${sample}.json"
    
    """
        report.rb -s ${sample} -v ${workflow.manifest.version} -p $precision
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
        json2pdf.rb -j ${json} -o $pdf -l ${baseDir}/images/ikmb_bfx_logo.png
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
