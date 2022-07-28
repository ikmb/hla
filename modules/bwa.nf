process BWA {

	scratch true

	container "docker://ikmb/exome-seq:3.2"

	tag "${meta.patient_id}|${meta.sample_id}"

	input:
	tuple val(meta), path(left),path(right)

	output:
	tuple val(meta), path(bam), emit: bam
	val(sample), emit: sample_name
        val(meta), emit: meta_data
    
	script:
	bam = "${meta.sample_id}_${meta.library_id}_${meta.readgroup_id}.aligned.fm.bam"
	sample = "${meta.patient_id}_${meta.sample_id}"

	def aligner = "bwa"
	def options = ""
	"""
		bwa mem -H ${params.dict} -M -R "@RG\\tID:${meta.readgroup_id}\\tPL:ILLUMINA\\tSM:${meta.patient_id}_${meta.sample_id}\\tLB:${meta.library_id}\\tDS:${params.fasta}\\tCN:CCGA" \
			-t ${task.cpus} ${params.fasta} $left $right \
			| samtools fixmate -@ ${task.cpus} -m - - \
			| samtools sort -@ ${task.cpus} -m 2G -O bam -o $bam - 
	"""	
}
