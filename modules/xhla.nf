process XHLA {

    container "docker://humanlongevity/hla:latest"

    label 'medium_serial'
    
    tag "${meta.patient_id}|${meta.sample_id}"

    publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/xHLA", mode: 'copy'

    input:
    tuple val(meta),path(bam),path(bai)

    output:
    tuple val(meta),path(result), emit: results
    path("versions.yml"), emit: versions
    
    script:
    sample_id = "${meta.patient_id}_${meta.sample_id}"
    result = sample_id + ".xHLA.json"

    script:

    """
    run.py --sample_id $sample_id --input_bam $bam --output_path report --delete
    cp report/*.json $result

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        xhla: 34221ea
    END_VERSIONS

    """
}
