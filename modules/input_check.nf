//
// Check input samplesheet and get read channels
//

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    samplesheet
        .splitCsv ( header:true, sep:';' )
        .map { create_fastq_channel(it) }
        .set { reads }

    emit:
    reads                                     // channel: [ val(meta), [ reads ] ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channel(LinkedHashMap row) {
    def meta = [:]
    meta.sample_id           = row.sampleID
    meta.patient_id          = row.patientID
    meta.library_id          = row.libraryID
    meta.readgroup_id        = row.rgID

    def array = []
    array = [ meta, file(row.R1), file(row.R2) ]

    return array
}
