process RENAME_READS {

    tag "${meta.sample_id}"

    publishDir "${params.outdir}/00GenDX", mode: 'copy'
    
    input:
    tuple val(meta),path(r1),path(r2)

    output:
    tuple val(meta),path(r1_renamed),path(r2_renamed), emit: reads

    script:
    r1_renamed = meta.sample_id + "_R1_001.fastq.gz"
    r2_renamed = meta.sample_id + "_R2_001.fastq.gz"

    """
        cp $r1 $r1_renamed
        cp $r2 $r2_renamed
    """

}
