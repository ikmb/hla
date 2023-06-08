process OPTITYPE_FILTER {

    container 'quay.io/biocontainers/optitype:1.3.5--hdfd78af_1'

    tag "${meta.patient_id}|${meta.sample_id}"

    label 'medium_parallel'

    scratch true

    input:
    tuple val(meta),path(left),path(right)

    output:
    tuple val(meta),path(left_clean),path(right_clean), emit: reads

    script:

    left_clean = left.getBaseName() + "_clean.fastq"
    right_clean = right.getBaseName() + "_clean.fastq"

    """
        zcat $left > left.fq
        zcat $right > right.fq

        razers3 -i 95 -m 1 --thread-count ${task.cpus} -dr 0 -o fished_1.bam $params.optitype_index left.fq
        samtools bam2fq fished_1.bam > $left_clean
        razers3 -i 95 -m 1 --thread-count ${task.cpus} -dr 0 -o fished_2.bam $params.optitype_index right.fq
        samtools bam2fq fished_2.bam > $right_clean
        rm *.fq *.bam
    """
}
