// Load modules and subworkflows
include { INPUT_CHECK } from '../modules/input_check'
include { TRIM_AND_ALIGN } from '../subworkflows/align'
include { XHLA_TYPING } from '../subworkflows/xhla'
include { HISAT_TYPING } from '../subworkflows/hisat'
include { SOFTWARE_VERSIONS } from '../modules/software_versions'
include { MULTIQC } from '../modules/multiqc'
include { OPTITYPE } from '../subworkflows/optitype'
include { REPORT } from '../modules/reporting'
include { HLASCAN } from '../modules/hlascan'
include { JSON2XLS } from '../modules/reporting'
include { MERGE_READS } from "./../subworkflows/merge_reads"
include { HLAHD } from "./../modules/hlahd"
include { CUSTOM_DUMPSOFTWAREVERSIONS } from "./../modules/custom/dumpsoftwareversions/main"

// Input options
if (params.samples) {
    Channel.from(file(params.samples, checkIfExists: true))
        .splitCsv(sep: ';', header: true)
        .map { row ->
            def meta = [:]
            meta.patient_id = row.patientID
            meta.sample_id = row.sampleID
            meta.library_id = row.libraryID
            meta.readgroup_id = row.rgID
            left = returnFile( row.R1 )
            right = returnFile( row.R2)
            [ meta, left, right ]
        }.set {  reads_fastp }
} else if (params.folder) {
        Channel.fromFilePairs(params.folder + "/*_L0*_R{1,2}_001.fastq.gz", flat: true)
        .ifEmpty { exit 1, "Did not find any reads matching your input pattern..." }
        .map { triple ->
            def meta = [:]
            meta.patient_id = triple[0].split("_")[0]
            meta.sample_id = triple[0].split("_")[1..-1].join("_").split("_L0")[0]
            meta.readgroup_id = triple[0].split("_L0")[0]
            meta.library_id = triple[0].split("_")[1..-1].join("_").split("_L0")[0]
            tuple( meta,triple[1],triple[2])
        }
        .set { reads_fastp }
} else if (params.reads) {
        Channel.fromFilePairs(params.reads, flat: true)
        .ifEmpty { exit 1, "Did not find any reads matching your input pattern..." }
        .map { triple ->
            def meta = [:]
            meta.patient_id = triple[0].split("_")[0]
            meta.sample_id = triple[0].split("_")[1..-1].join("_").split("_L0")[0]
            meta.readgroup_id = triple[0].split("_L0")[0]
            meta.library_id = triple[0].split("_")[1..-1].join("_").split("_L0")[0]
            tuple( meta,triple[1],triple[2])               
        }
        .set { reads_fastp }
}

tools = params.tools ? params.tools.split(',').collect{it.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '')} : []

ch_genes = Channel.fromList(params.hla_genes)
// HLAscan is unique in that it can type the HLA-DRB5 gene - we have to add this separately. 
ch_hlascan_genes = Channel.fromList(params.hla_genes_hlascan)

ch_bed = Channel.fromPath("$baseDir/assets/targets/genes.bed", checkIfExists: true)

genome_index = params.genomes[ "hg38" ].fasta
ch_fasta = Channel.from( [ params.fasta, params.fai, params.dict] )

ch_versions = Channel.from([])
ch_qc = Channel.from([])
ch_reports = Channel.from([])
multiqc_files = Channel.from([])

// Workflow
workflow HLA {

    main:

    // Align reads to chromosome 6
    TRIM_AND_ALIGN(
        reads_fastp,
        ch_bed,
        genome_index,
        ch_fasta
    )
    
    ch_versions = ch_versions.mix(TRIM_AND_ALIGN.out.versions)

    ch_qc = ch_qc.mix(TRIM_AND_ALIGN.out.qc)
    ch_qc = ch_qc.mix(TRIM_AND_ALIGN.out.bedcov.map { m,r -> r } )

    MERGE_READS(
        TRIM_AND_ALIGN.out.reads
    )

    if ( 'hisat' in tools ) {
        HISAT_TYPING(
            TRIM_AND_ALIGN.out.reads,
            params.hla_genes.join(",")
        )
        
        ch_reports     = ch_reports.mix(HISAT_TYPING.out.report)
        ch_versions = ch_versions.mix(HISAT_TYPING.out.versions)

    }

    if ( 'hlahd' in tools ) {
        HLAHD(
            MERGE_READS.out.reads.map { m,b,i ->
                [[
                    patient_id: m.patient_id,
                    sample_id: m.sample_id
                ],b,i]
            }
        )

        ch_reports     = ch_reports.mix(HLAHD.out.report)
        ch_versions = ch_versions.mix(HLAHD.out.versions)

    }

    if ('xhla' in tools) {
        XHLA_TYPING(
            TRIM_AND_ALIGN.out.bam
        )

        ch_reports     = ch_reports.mix(XHLA_TYPING.out.report)

    }

    if ( 'hlascan' in tools) {
        // mix the hlscan-only genes in and make the list unique, just in case
        ch_genes_hlascan = ch_genes.mix(ch_hlascan_genes).unique()
        HLASCAN(
            TRIM_AND_ALIGN.out.bam.combine(ch_genes_hlascan)
        )
        
        ch_reports  = ch_reports.mix(HLASCAN.out.report)
        ch_versions = ch_versions.mix(HLASCAN.out.versions)

    }

    if ('optitype' in tools) {
        OPTITYPE(
            TRIM_AND_ALIGN.out.reads
        )

        ch_reports  = ch_reports.mix(OPTITYPE.out.report)
        ch_versions = ch_versions.mix(OPTITYPE.out.versions)

    }

    CUSTOM_DUMPSOFTWAREVERSIONS(
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    REPORT(
        ch_reports.groupTuple()
    )

    JSON2XLS(
        REPORT.out.json.map {m,j ->j }.collect()
    )
    
    multiqc_files = multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml)
    multiqc_files = multiqc_files.mix(ch_qc)

    MULTIQC(
        multiqc_files.collect()
    )

    emit:
    qc = MULTIQC.out.report
    
}


// Helper function for the sample sheet parsing to produce sane channel elements
def returnFile(it) {
    // Return file if it exists
    inputFile = file(it)
    if (!file(inputFile).exists()) exit 1, "Missing file in TSV file: ${inputFile}, see --help for more information"
    return inputFile
}
