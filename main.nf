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
    
    output:
    path "extracted/**", type: 'dir', emit: files
    
    script:
    """
    #!/bin/bash
    set -e
    set -x  # Show commands being executed
    
    echo "=== Environment Check ==="
    echo "Working directory: \$PWD"
    echo "Input tar: ${params.input_tar}"
    echo ""
    
    # Check if Fusion mounted the file
    echo "Checking if file exists..."
    if [ -f "${params.input_tar}" ]; then
        echo "✓ File exists!"
        ls -lh "${params.input_tar}"
        echo "File size: \$(stat -c%s "${params.input_tar}") bytes"
    else
        echo "✗ ERROR: File not found: ${params.input_tar}"
        echo "Listing parent directory:"
        ls -la "\$(dirname "${params.input_tar}")" || echo "Parent dir not accessible"
        exit 1
    fi
    
    echo ""
    echo "=== Starting Extraction ==="
    mkdir -p extracted
    
    # Extract tar file
    echo "Running: tar -xzf ${params.input_tar} -C extracted/"
    tar -xzf "${params.input_tar}" -C extracted/
    
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
    EXTRACT_TAR()
}
