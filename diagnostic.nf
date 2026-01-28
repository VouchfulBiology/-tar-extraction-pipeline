#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * Diagnostic workflow to test Fusion mounting
 */

params.input_tar = "s3://default-compute-001-hn9mpq5gz/X401SC25112668-Z02-F001_V.tar.download/X401SC25112668-Z02-F001.tar"

process CHECK_FILE {
    debug true
    
    script:
    """
    echo "=== Diagnostic Check ==="
    echo "Working directory: \$PWD"
    echo ""
    echo "Environment variables:"
    env | grep -E '(AWS|S3|FUSION)' || echo "No AWS/S3/FUSION vars found"
    echo ""
    echo "Checking if file exists:"
    ls -lh ${params.input_tar} || echo "File not found via direct path"
    echo ""
    echo "Checking S3 bucket:"
    aws s3 ls s3://default-compute-001-hn9mpq5gz/X401SC25112668-Z02-F001_V.tar.download/ || echo "Cannot list S3 bucket"
    echo ""
    echo "=== End Diagnostic ==="
    """
}

workflow {
    CHECK_FILE()
}
