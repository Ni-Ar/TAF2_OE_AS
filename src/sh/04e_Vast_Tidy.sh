#!/bin/bash
# Compare vast-tools PSI between samples.

# Time ref
DATE=`date +%Y_%m_%d`

# Set up variable names
PROJ_NAME="01_ALTdemix"
EXPERIMENT_NAME="Tanja"

# VAST-TOOLS OPTIONS
VAST_SPECIES="hg38"
VAST_VERSION="251"
VAST_SAMPLES="12"

# Set up directories paths
PROJ_DIR="/users/mirimia/narecco/projects/${PROJ_NAME}"
VAST_TOOLS="${PROJ_DIR}/data/INCLUSION_tbl/${EXPERIMENT_NAME}/vast_tools"
VAST_OUT="${VAST_TOOLS}/vast_out"
PSI_TBL="${VAST_OUT}/INCLUSION_LEVELS_FULL-${VAST_SPECIES}-${VAST_SAMPLES}-v${VAST_VERSION}.tab"
TIDY_DIR="${VAST_OUT}/tidy_${DATE}"

cd ${VAST_OUT}
mkdir -p ${TIDY_DIR}

echo -e "Tidyign up vast-tools inclusion table\n"

TIDY_OUTFILE="INCLUSION_LEVELS_TIDY_HeLa_noB3_pIR.tab"
vast-tools tidy ${PSI_TBL} \
                --outFile ${TIDY_OUTFILE} \
                --noB3 \
                --p_IR \
                --add_names \
                --log

mv "${VAST_OUT}/${TIDY_OUTFILE}" ${TIDY_DIR}
echo -e "\n"

TIDY_OUTFILE="INCLUSION_LEVELS_TIDY_HeLa_onlyEX_noB3_pIR.tab"
vast-tools tidy ${PSI_TBL} \
                --outFile ${TIDY_OUTFILE} \
                --onlyEX \
                --noB3 \
                --p_IR \
                --add_names \
                --log

mv "${VAST_OUT}/${TIDY_OUTFILE}" ${TIDY_DIR}
echo -e "\n"