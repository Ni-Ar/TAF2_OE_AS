#!/bin/bash
# Generate a FastQC on Raw fastq files
# Run MultiQC

# REMEMBER: activate conda env with latest versions of QC tools
# conda activate vast-tools
echo -e "Remember to activate the conda environment for the required software\n\tconda activate vast-tools\n"
sleep 1

# Set Up PARAMS
PROJ_NAME="01_ALTdemix"
EXPERIMENT_NAME="Tanja"

# Set Up directories paths
PROJ_DIR="/users/mirimia/narecco/projects/${PROJ_NAME}"
FASTQ_DIR="/users/mirimia/narecco/sharing/${EXPERIMENT_NAME}/fastq_split3"

QC_DIR="${PROJ_DIR}/data/qc/${EXPERIMENT_NAME}"
FASTQC_DIR="${QC_DIR}/fastqc"
QC_ALL_READS_DIR="${FASTQC_DIR}/all_reads"
MULTIQC_DIR="${QC_DIR}/multiqc"

# Create output directory
mkdir -p ${MULTIQC_DIR}

echo -e "Running MultiQC"

cd ${QC_ALL_READS_DIR}
multiqc . \
        --filename ${EXPERIMENT_NAME} \
        --no-data-dir \
        --profile-runtime \
        --outdir ${MULTIQC_DIR}

# Remove zipped files from fastqc
echo -e "Clean up some redundant files\n"
cd ${QC_ALL_READS_DIR}
rm ./*.zip

echo -e "Done!\n"
