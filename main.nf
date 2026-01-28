#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * TAR Extraction Workflow
 * Extracts X401SC25112668-Z02-F001.tar from S3 and uploads to output bucket
 */

params.input_tar = "s3://default-compute-001-hn9mpq5gz/X401SC25112668-Z02-F001.tar"
params.outdir = "s3://default-compute-001-hn9mpq5gz/extracted"

process DOWNLOAD_TAR {
    memory '4 GB'
    cpus 2
    
    input:
    val tar_path
    
    output:
    path "downloaded.tar", emit: tar_file
    
    script:
    """
    set -e
    
    echo "=== Downloading tar file from S3 ==="
    echo "Source: ${tar_path}"
    
    # Download using aws s3 cp with verification
    aws s3 cp "${tar_path}" downloaded.tar
    
    echo "Download complete!"
    echo "File size: \$(ls -lh downloaded.tar | awk '{print \$5}')"
    
    # Verify the tar file is valid
    echo "Verifying tar file integrity..."
    tar -tzf downloaded.tar > /dev/null && echo "✓ Tar file is valid" || {
        echo "✗ ERROR: Tar file is corrupted!"
        exit 1
    }
    """
}

process EXTRACT_TAR {
    publishDir params.outdir, mode: 'copy'
    memory '8 GB'
    cpus 4
    
    input:
    path tar_file
    
    output:
    path "extracted/**", emit: files
    
    script:
    """
    set -e
    
    echo "=== Starting tar extraction ==="
    echo "Input file: ${tar_file}"
    echo "File size: \$(du -h ${tar_file} | cut -f1)"
    
    # Create output directory
    mkdir -p extracted
    
    # Extract with progress
    echo "Extracting tar file..."
    tar -xvf ${tar_file} -C extracted/
    
    echo "=== Extraction complete! ==="
    echo "Files extracted:"
    find extracted/ -type f | head -20
    echo "..."
    echo "Total files: \$(find extracted/ -type f | wc -l)"
    echo "Total size: \$(du -sh extracted/ | cut -f1)"
    """
}

workflow {
    // Step 1: Download tar file from S3 using AWS CLI
    tar_path_ch = channel.of(params.input_tar)
    DOWNLOAD_TAR(tar_path_ch)
    
    // Step 2: Extract the downloaded tar file
    EXTRACT_TAR(DOWNLOAD_TAR.out.tar_file)
    
    // View the extracted files
    EXTRACT_TAR.out.files
        .flatten()
        .take(10)
        .view { file -> "Extracted: ${file}" }
}
