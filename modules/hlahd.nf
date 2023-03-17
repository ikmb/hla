process HLAHD {

	container false
	module 'IKMB:HLAHD/1.7.0'

	publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/HLAHD", mode: 'copy'

	tag "${meta.patient_id}|${meta.sample_id}"

	input:
	tuple val(meta),path(R1),path(R2)

	output:
	tuple val(meta),path(result), emit: report
	path(outdir)

	script:
	result = "${meta.patient_id}-${meta.sample_id}_HLAHD.txt"
	outdir = "hlahd_out"
	
	"""
		mkdir -p $outdir
		hlahd.sh -t ${task.cpus} -m 50 -c 0.95 -f \$HLAHD_FREQ $R1 $R2 \$HLAHD_GENE_SPLIT \$HLAHD_DICT ${meta.sample_id} $outdir
		cp ${outdir}/${meta.sample_id}/result/${meta.sample_id}_final.result.txt ${result}
	"""

}

