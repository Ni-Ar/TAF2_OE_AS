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
MIN_dPSI="15" # Min dPSI to consider an AS event differentially spliced
MIN_RANGE="0" # PSI distribution of the two groups do not overlap and must be at least MIN_RANGE apart from the max and min value.
MAX_dPSI="5" # Maximum dPSI to consider an AS EVENT non-changing

RUN_GO="YES" # YES or NO

# Set up directories paths
PROJ_DIR="/users/mirimia/narecco/projects/${PROJ_NAME}"
VAST_TOOLS="${PROJ_DIR}/data/INCLUSION_tbl/${EXPERIMENT_NAME}/vast_tools"
VAST_OUT="${VAST_TOOLS}/vast_out"
PSI_TBL="${VAST_OUT}/INCLUSION_LEVELS_FULL-${VAST_SPECIES}-${VAST_SAMPLES}-v${VAST_VERSION}.tab"
CMPR_DIR="${VAST_OUT}/compare_${DATE}/min_dPSI${MIN_dPSI}_min_range${MIN_RANGE}_max_dPSI${MAX_dPSI}"

cd ${VAST_TOOLS}

# Check that the PSI table exists
if [[ -f ${PSI_TBL} ]] ; then
    TBL_NAME=$( basename -a ${PSI_TBL} )
    echo "Working with the PSI table ${TBL_NAME}"
    # Give execution right to the table as it might be needed
    chmod u+x ${PSI_TBL}
else
    TBL_NAME=$( basename -a ${PSI_TBL} )
    echo -e "\n STOP! \t There's no inclusion table ${TBL_NAME} for species ${VAST_SPECIES} at:\n${PSI_TBL}"
    exit
fi

mkdir -p ${CMPR_DIR}

# Make a folder for the GO terms files if running GO
if [ $RUN_GO == "YES" ] ; then
    GO_OPTION=$( echo " --GO" )
    GO_DIR="${CMPR_DIR}/GO_gene_lists"
    mkdir -p ${GO_DIR}
elif [ $RUN_GO == "NO" ] ; then
    GO_OPTION=$( echo "" )

else 
 echo "\nERROR!\nRUN_GO must be either 'YES' or 'NO'!\n"
fi

# echo -e "Comparing vast-tools inclusion tables with these parameters:"
# echo -e "Filters:\n\t dPSI min: ${MIN_dPSI}\t min PSI range: ${MIN_RANGE}\tdPSI max: ${MAX_dPSI}\tnoB3\tp_IR\n"

echo "Comparison 1:"

CMPR_BASENAME="HeLa_TAF2OE_vs_CNTRL_mrgd_noB3_pIR"
CMPR_OUTFILE="${CMPR_BASENAME}.tab"
vast-tools compare ${PSI_TBL} \
                   --outFile ${CMPR_OUTFILE} \
                   -a HeLa_FRT \
                   -b HeLa_TAF2 \
                   -name_A HeLa_Cntrl \
                   -name_B HeLa_TAF2OE \
                   --min_dPSI ${MIN_dPSI} \
                   --min_range ${MIN_RANGE} \
                   --max_dPSI ${MAX_dPSI} \
                   --print_sets \
                   --noB3 \
                   --p_IR \
                   --print_dPSI ${GO_OPTION} \
                   -sp ${VAST_SPECIES}

# Move the compare tables to a sub-folder
mv "${VAST_OUT}/${CMPR_OUTFILE}" ${CMPR_DIR}
mv "${VAST_OUT}/CS-${CMPR_BASENAME}.tab" ${CMPR_DIR}
mv "${VAST_OUT}/CR-${CMPR_BASENAME}.tab" ${CMPR_DIR}
mv "${VAST_OUT}/AS_NC-${CMPR_BASENAME}-Max_dPSI${MAX_dPSI}.tab" ${CMPR_DIR}

# Move the go gene list files to a subfolder
if [ ${RUN_GO} == "YES" ] ; then
    SUB_DIR_NAME=$( basename ${CMPR_DIR}/${CMPR_OUTFILE} .tab)
    SUB_GO_DIR="${GO_DIR}/${SUB_DIR_NAME}"
    mkdir -p ${SUB_GO_DIR}
    echo "Moving GO gene lists files to subdirectory: ${SUB_DIR_NAME}"
    mv ${VAST_OUT}/All_Ev-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/AltEx-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/BG-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/IR_DOWN-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/IR_UP-**.txt ${SUB_GO_DIR}
fi

echo -e "\n"
echo "Comparison 2:"

CMPR_BASENAME="HeLa_NLSTAF2dIDR_vs_CNTRL_mrgd_noB3_pIR"
CMPR_OUTFILE="${CMPR_BASENAME}.tab"

vast-tools compare ${PSI_TBL} \
                   --outFile ${CMPR_OUTFILE} \
                   -a HeLa_FRT \
                   -b HeLa_NLSTAF2dIDR \
                   -name_A HeLa_Cntrl \
                   -name_B HeLa_NLSTAF2dIDR \
                   --min_dPSI ${MIN_dPSI} \
                   --min_range ${MIN_RANGE} \
                   --max_dPSI ${MAX_dPSI} \
                   --print_sets \
                   --noB3 \
                   --p_IR \
                   --print_dPSI ${GO_OPTION} \
                   -sp ${VAST_SPECIES}

# # Move the compare table to a sub-folder
mv "${VAST_OUT}/${CMPR_OUTFILE}" ${CMPR_DIR}
mv "${VAST_OUT}/CS-${CMPR_BASENAME}.tab" ${CMPR_DIR}
mv "${VAST_OUT}/CR-${CMPR_BASENAME}.tab" ${CMPR_DIR}
mv "${VAST_OUT}/AS_NC-${CMPR_BASENAME}-Max_dPSI${MAX_dPSI}.tab" ${CMPR_DIR}

# Move the go gene list files to a subfolder
if [ ${RUN_GO} == "YES" ] ; then
    SUB_DIR_NAME=$( basename ${CMPR_DIR}/${CMPR_OUTFILE} .tab)
    SUB_GO_DIR="${GO_DIR}/${SUB_DIR_NAME}"
    mkdir -p ${SUB_GO_DIR}
    echo "Moving GO gene lists files to subdirectory: ${SUB_DIR_NAME}"
    mv ${VAST_OUT}/All_Ev-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/AltEx-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/BG-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/IR_DOWN-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/IR_UP-**.txt ${SUB_GO_DIR}
fi

echo -e "\nComparison 3:"

CMPR_BASENAME="HeLa_TAF2OE_vs_CNTRL_uniq_noB3_pIR"
CMPR_OUTFILE="${CMPR_BASENAME}.tab"
vast-tools compare ${PSI_TBL} \
                   --outFile ${CMPR_OUTFILE} \
                   -a HeLa_FRT_A,HeLa_FRT_B,HeLa_FRT_C \
                   -b HeLa_TAF2_A,HeLa_TAF2_B,HeLa_TAF2_C \
                   -name_A HeLa_Cntrl \
                   -name_B HeLa_TAF2OE \
                   --min_dPSI ${MIN_dPSI} \
                   --min_range ${MIN_RANGE} \
                   --max_dPSI ${MAX_dPSI} \
                   --print_sets \
                   --noB3 \
                   --p_IR \
                   --print_dPSI ${GO_OPTION} \
                   -sp ${VAST_SPECIES}

# Move the compare table to a sub-folder
mv "${VAST_OUT}/${CMPR_OUTFILE}" ${CMPR_DIR}
mv "${VAST_OUT}/CS-${CMPR_BASENAME}.tab" ${CMPR_DIR}
mv "${VAST_OUT}/CR-${CMPR_BASENAME}.tab" ${CMPR_DIR}
mv "${VAST_OUT}/AS_NC-${CMPR_BASENAME}-Max_dPSI${MAX_dPSI}.tab" ${CMPR_DIR}

# Move the go gene list files to a subfolder
if [ ${RUN_GO} == "YES" ] ; then
    SUB_DIR_NAME=$( basename ${CMPR_DIR}/${CMPR_OUTFILE} .tab)
    SUB_GO_DIR="${GO_DIR}/${SUB_DIR_NAME}"
    mkdir -p ${SUB_GO_DIR}
    echo "Moving GO gene lists files to subdirectory: ${SUB_DIR_NAME}"
    mv ${VAST_OUT}/All_Ev-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/AltEx-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/BG-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/IR_DOWN-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/IR_UP-**.txt ${SUB_GO_DIR}
fi

echo -e "\nComparison 4:"

CMPR_BASENAME="HeLa_NLSTAF2dIDR_vs_CNTRL_uniq_noB3_pIR"
CMPR_OUTFILE="${CMPR_BASENAME}.tab"

vast-tools compare ${PSI_TBL} \
                   --outFile ${CMPR_OUTFILE} \
                   -a HeLa_FRT_A,HeLa_FRT_B,HeLa_FRT_C \
                   -b HeLa_NLSTAF2dIDR_A,HeLa_NLSTAF2dIDR_B,HeLa_NLSTAF2dIDR_C \
                   -name_A HeLa_Cntrl \
                   -name_B HeLa_NLSTAF2dIDR \
                   --min_dPSI ${MIN_dPSI} \
                   --min_range ${MIN_RANGE} \
                   --max_dPSI ${MAX_dPSI} \
                   --print_sets \
                   --noB3 \
                   --p_IR \
                   --print_dPSI ${GO_OPTION} \
                   -sp ${VAST_SPECIES}

# Move the compare table to a sub-folder
mv "${VAST_OUT}/${CMPR_OUTFILE}" ${CMPR_DIR}
mv "${VAST_OUT}/CS-${CMPR_BASENAME}.tab" ${CMPR_DIR}
mv "${VAST_OUT}/CR-${CMPR_BASENAME}.tab" ${CMPR_DIR}
mv "${VAST_OUT}/AS_NC-${CMPR_BASENAME}-Max_dPSI${MAX_dPSI}.tab" ${CMPR_DIR}

# Move the go gene list files to a subfolder
if [ ${RUN_GO} == "YES" ] ; then
    SUB_DIR_NAME=$( basename ${CMPR_DIR}/${CMPR_OUTFILE} .tab)
    SUB_GO_DIR="${GO_DIR}/${SUB_DIR_NAME}"
    mkdir -p ${SUB_GO_DIR}
    echo "Moving GO gene lists files to subdirectory: ${SUB_DIR_NAME}"
    mv ${VAST_OUT}/All_Ev-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/AltEx-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/BG-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/IR_DOWN-**.txt ${SUB_GO_DIR}
    mv ${VAST_OUT}/IR_UP-**.txt ${SUB_GO_DIR}
fi