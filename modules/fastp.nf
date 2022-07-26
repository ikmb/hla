process FASTP {

   input:
   tuple val(meta),path(r1),path(r2)

   output:
   tuple val(meta),path(r1_trim),path(r2_trim), emit: reads
   tuple val(meta),path("*.json"), emit: json
   path('v_fastp.txt'), emit: version

   script:
   r1_trim = file(r1).getBaseName() + "_trimmed.fastq.gz"
   r2_trim = file(r2).getBaseName() + "_trimmed.fastq.gz"
   json = file(r1).getBaseName() + ".fastp.json"
   html = file(r2).getBaseName() + ".fastp.html"

   """
      fastp -c --in1 $r1 --in2 $r2 --out1 $r1_trim --out2 $r2_trim --detect_adapter_for_pe -w ${task.cpus} -j $json -h $html --length_required 35

      cat <<-END_VERSIONS > v_fastp.txt
      "${task.process}":
            fastp \$( fastp --version | sed -e "s/fastp //g" )
      END_VERSIONS

   """	

}


