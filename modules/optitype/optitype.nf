process OPTITYPE_RUN {

    container 'quay.io/biocontainers/optitype:1.3.5--hdfd78af_1'

    tag "${meta.patient_id}|${meta.sample_id}"

    publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/optitype", mode: 'copy'

    label 'medium_parallel'

    input:
    tuple val(meta),path(left),path(right)

    output:
    tuple val(meta),path(tsv), emit: tsv
	path("versions.yml"), emit: versions

    script:
    results = "optitype_out"
    tsv = "${meta.patient_id}_${meta.sample_id}-optitype.tsv"

    """
    cp ${baseDir}/assets/optitype/config.ini .
    OptiTypePipeline.py -i $left $right --dna -e 3 -c config.ini --outdir $results
    cp optitype_out/*/*.tsv $tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        optitype: \$(cat \$(which OptiTypePipeline.py) | grep -e "Version:" | sed -e "s/Version: //g")
    END_VERSIONS
    """
}
