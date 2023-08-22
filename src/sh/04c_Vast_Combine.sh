#!/bin/bash
# Combine vast-tools output of expression values of each sample into a single table.
# This script requires R packages limma and edgeR

echo -e "Remember to activate conda environment vast-tools for the required R packages\n\tconda activate vast-tools\n"
sleep 5

# How many processes?
Num_Hours=2
Num_Ram=8 # In GigaBytes
Num_Processes=4

# Time reference
DATE=`date +%Y_%m_%d`

# Set up variable names
PROJ_NAME="01_ALTdemix"
EXPERIMENT_NAME="Tanja"
JOB_NAME="VstCmbn"
QUEUE_NAME="short-sl7,long-sl7,mem_512"
CRG_EMAIL="niccolo.arecco@crg.eu"

# Set up directories paths
PROJ_DIR="/users/mirimia/narecco/projects/${PROJ_NAME}"
JOBS_OUT_DIR="/users/mirimia/narecco/qsub_out/${DATE}/${JOB_NAME}"
VAST_TOOLS="${PROJ_DIR}/data/INCLUSION_tbl/${EXPERIMENT_NAME}/vast_tools"
VAST_OUT="${VAST_TOOLS}/vast_out"

mkdir -p ${JOBS_OUT_DIR}

# VAST-TOOLS OPTIONS
VAST_SPECIES="hg38"
VAST_IR_VERSION=2

# Important to be here as the output folder is the default "vast_out"
cd ${VAST_TOOLS}

echo -e "Combine samples into one table for INCLUSION (PSI) and one for EXPRESSION (cRPKM or TPM, normalised and not) with vast-tools combine\n"

# The qsub -V option is required to export all my PATHs to the node so that I can have the conda env with the R packages there.
qsub -q ${QUEUE_NAME} -V -cwd -pe smp ${Num_Processes} -terse \
     -l virtual_free=${Num_Ram}G -l h_rt=${Num_Hours}:05:15 \
     -m ea -M ${CRG_EMAIL} -N ${JOB_NAME}_${EXPERIMENT_NAME} -j y \
     -o "${JOBS_OUT_DIR}/${EXPERIMENT_NAME}.log" -b y \
     vast-tools combine -sp ${VAST_SPECIES} \
                        --cores ${Num_Processes} \
                        --IR_version ${VAST_IR_VERSION} \
                        --TPM \
                        --norm \
                        --keep_raw_reads \
                        --keep_raw_incl \
                        --add_version \
                        --verbose 

# Do not specify the output with  --output ${VAST_OUT} otherwise some scripts fail to find the required temp files.
