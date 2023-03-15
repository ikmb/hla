process CONCAT_FASTQ {

    //publishDir "${params.outdir}/GenDX", mode: 'copy'
    
    input:
    tuple val(meta),path(r1),path(r2)

    output:
    tuple val(meta),path(r1_merged),path(r2_merged), emit: reads

    script:
    r1_merged = meta.sample_id + "-" + meta.library_id + "_R1_001.fastq.gz"
    r2_merged = meta.sample_id + "-" + meta.library_id + "_R2_001.fastq.gz"

    """
        zcat $r1 | gzip -c >> $r1_merged
        zcat $r2 | gzip -c >> $r2_merged
    """

}