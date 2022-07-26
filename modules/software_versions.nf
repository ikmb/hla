process SOFTWARE_VERSIONS {

   input:
   path('*')

   output:
   path('versions.yml')


   script:
   
   """
      parse_versions.pl > versions.yml
   """

}
