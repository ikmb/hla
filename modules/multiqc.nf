process  MULTIQC {

   publishDir "${params.outdir}/multiqc", mode: 'copy'

   container 'quay.io/biocontainers/multiqc:1.12--pyhdfd78af_0'

   input:
   path('*')
   val(rname)

   output:
   path('*.html'), emit: report

   script:

   """
      multiqc -n ${rname}_multiqc . 
   """    

}


