process BEDCOV {

        tag "${meta.patient_id}|${meta.sample_id}"

        publishDir "${params.outdir}/${meta.patient_id}/${meta.sample_id}/", mode: 'copy'

        input:
        tuple val(meta),path(bam),path(bai)
	path(bed)

        output:
        tuple val(meta), path(report), emit: report

        script:
        def prefix = "${meta.patient_id}_${meta.sample_id}.dedup"
	report = prefix + ".bedcov.txt"

        """
		samtools bedcov -Q 1 $bed $bam > $report
        """

}
