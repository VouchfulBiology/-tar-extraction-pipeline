# TAR Extraction Pipeline

Nextflow pipeline to extract tar files from S3 storage.

## Usage

```bash
nextflow run main.nf \
  --input_tar s3://your-bucket/your-file.tar \
  --outdir s3://your-bucket/extracted
```

## Parameters

- `--input_tar`: S3 path to the tar file (default: s3://default-compute-001-hn9mpq5gz/X401SC25112668-Z02-F001.tar)
- `--outdir`: S3 path for extracted files (default: s3://default-compute-001-hn9mpq5gz/extracted)

## Requirements

- Nextflow >= 25.04.0
- Wave and Fusion enabled
- AWS Batch compute environment with S3 access
