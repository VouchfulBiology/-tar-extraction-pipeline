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
    memory '8 GB'
    cpus 4
    
    input:
    path tar_file
    
    output:
    path "extracted/*", emit: files
    
    script:
    """
    set -e
    
    echo "=== Starting tar extraction ==="
    echo "Input file: ${tar_file}"
    echo "File size: \$(du -h ${tar_file} | cut -f1)"
    
    # Verify file exists and is readable
    if [ ! -f "${tar_file}" ]; then
        echo "ERROR: Tar file not found!"
        exit 1
    fi
    
    # Try to read first few bytes to verify file is accessible
    echo "Verifying file integrity..."
    head -c 1024 ${tar_file} > /dev/null || {
        echo "ERROR: Cannot read tar file!"
        exit 1
    }
    
    # Create output directory
    mkdir -p extracted
    
    # Extract with verbose output and error handling
    echo "Extracting tar file..."
    tar -xvf ${tar_file} -C extracted/ || {
        echo "ERROR: Tar extraction failed!"
        echo "Partial extraction may have occurred. Listing what was extracted:"
        ls -lhR extracted/ || true
        exit 1
    }
    
    echo "=== Extraction complete! ==="
    echo "Files extracted:"
    find extracted/ -type f | head -20
    echo "..."
    echo "Total files: \$(find extracted/ -type f | wc -l)"
    echo "Total size: \$(du -sh extracted/ | cut -f1)"
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
