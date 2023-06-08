process BAM2FASTQ {

    scratch true 

    tag "${meta.patient_id}|${meta.sample_id}"

    input:
    tuple val(meta),path(bam),path(bai)

    output:
    tuple val(meta),path(left),path(right), emit: reads

    script:

    left = bam.getBaseName() + "-extracted_R1_001.fastq.gz"
    right = bam.getBaseName() + "-extracted_R2_001.fastq.gz"

    """
        samtools sort -m 1G -n -@ ${task.cpus} -O BAM $bam - | samtools fastq -1 $left -2 $right -@ ${task.cpus} -
    """

}
