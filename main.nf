#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * TAR Extraction Workflow
 * Extracts tar file from S3 using Fusion (no download needed!)
 */

params.input_tar = "s3://default-compute-001-hn9mpq5gz/X401SC25112668-Z02-F001_V.tar.download/X401SC25112668-Z02-F001.tar"
params.outdir = "s3://default-compute-001-hn9mpq5gz/extracted"

process EXTRACT_TAR {
    publishDir params.outdir, mode: 'copy'
    memory '8 GB'
    cpus 4
    
    input:
    path tar_file
    
    output:
    path "extracted/*", type: 'dir', emit: files
    
    script:
    """
    set -e
    
    echo "=== Starting tar extraction ==="
    echo "Input file: ${tar_file}"
    echo "File size: \$(ls -lh ${tar_file} | awk '{print \$5}')"
    
    # Create output directory
    mkdir -p extracted
    
    # Extract tar file (Fusion mounts S3 directly, no download needed!)
    echo "Extracting tar file..."
    tar -xzf ${tar_file} -C extracted/
    
    echo "=== Extraction complete! ==="
    echo "Files extracted:"
    find extracted/ -type f | head -20
    echo "..."
    echo "Total files: \$(find extracted/ -type f | wc -l)"
    echo "Total size: \$(du -sh extracted/ | cut -f1)"
    """
}

workflow {
    // Fusion mounts S3 file directly - no download process needed!
    tar_ch = channel.fromPath(params.input_tar)
    EXTRACT_TAR(tar_ch)
}
