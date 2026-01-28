#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * TAR Extraction Workflow v2
 * Uses direct S3 path with Fusion mounting (no channel.fromPath)
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
    path "extracted/**", type: 'dir', emit: files
    
    script:
    """
    #!/bin/bash
    set -e
    set -x  # Show commands being executed
    
    echo "=== Starting Extraction ==="
    echo "Working directory: \$PWD"
    echo "Input file: ${tar_file}"
    echo ""
    
    # Create output directory
    mkdir -p extracted
    
    # Extract tar file (Fusion makes S3 files accessible directly)
    tar -xzf "${tar_file}" -C extracted/
    
    echo ""
    echo "=== Extraction Complete! ==="
    echo "Files extracted (first 20):"
    find extracted/ -type f | head -20
    if [ \$(find extracted/ -type f | wc -l) -gt 20 ]; then
        echo "... (showing first 20 of \$(find extracted/ -type f | wc -l) total files)"
    fi
    echo ""
    echo "Total size: \$(du -sh extracted/ | cut -f1)"
    """
}

workflow {
    // Create channel with S3 file path
    tar_ch = channel.fromPath(params.input_tar, checkIfExists: false)
    
    // Run extraction
    EXTRACT_TAR(tar_ch)
}
