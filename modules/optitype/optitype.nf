process OPTITYPE {

	label 'optitype'

	input:
	tuple val(meta),path(left),path(right)

	output:

	
	script:
	results = "optitype_out"

	"""
		cp ${baseDir}/assets/optitype/config.ini
		OptiTypePipeline.py -i $left $right --dna -e 3 -c config.ini --outdir $results
	"""


}
