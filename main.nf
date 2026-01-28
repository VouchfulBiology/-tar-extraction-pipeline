#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * TAR Extraction Workflow
 * Extracts X401SC25112668-Z02-F001.tar from S3 and uploads to output bucket
 */

params.input_tar = "s3://default-compute-001-hn9mpq5gz/X401SC25112668-Z02-F001.tar"
params.outdir = "s3://default-compute-001-hn9mpq5gz/extracted"

process EXTRACT_TAR {
    publishDir params.outdir, mode: 'copy'
    
    input:
    path tar_file
    
    output:
    path "extracted/*", emit: files
    
    script:
    """
    mkdir -p extracted
    tar -xvf ${tar_file} -C extracted/
    
    echo "Extraction complete!"
    echo "Files extracted:"
    ls -lh extracted/
    """
}

workflow {
    // Create channel from S3 tar file
    tar_ch = channel.fromPath(params.input_tar)
    
    // Extract the tar file
    EXTRACT_TAR(tar_ch)
    
    // View the extracted files
    EXTRACT_TAR.out.files
        .flatten()
        .view { file -> "Extracted: ${file}" }
}
