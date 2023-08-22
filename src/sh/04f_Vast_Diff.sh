#!/bin/bash
# Compare vast-tools PSI between samples.

# Time ref
DATE=`date +%Y_%m_%d`

# How many processes?
Num_Hours=1
Num_Ram=6 # In GigaBytes
Num_Processes=2

# Set up variable names
PROJ_NAME="01_ALTdemix"
EXPERIMENT_NAME="Tanja"
JOB_NAME="VstDiff"
QUEUE_NAME="short-sl7,long-sl7,mem_512"
CRG_EMAIL="niccolo.arecco@crg.eu"

# VAST-TOOLS OPTIONS
VAST_SPECIES="hg38"
VAST_VERSION="251"
VAST_SAMPLES="12"
MIN_dPSI="0.15"
MIN_dPSI_PERCENT="$(echo "scale=2; $MIN_dPSI*100" | bc)" | awk '{print int($1)}'
MIN_READS="10"

# Set up directories paths
PROJ_DIR="/users/mirimia/narecco/projects/${PROJ_NAME}"
VAST_TOOLS="${PROJ_DIR}/data/INCLUSION_tbl/${EXPERIMENT_NAME}/vast_tools"
JOBS_OUT_DIR="/users/mirimia/narecco/qsub_out/${DATE}/${JOB_NAME}"
VAST_OUT="${VAST_TOOLS}/vast_out"
PSI_TBL="${VAST_OUT}/INCLUSION_LEVELS_FULL-${VAST_SPECIES}-${VAST_SAMPLES}-v${VAST_VERSION}.tab"
DIFF_DIR="${VAST_OUT}/diff_${DATE}/min_dPSI${MIN_dPSI_PERCENT}_min_reads${MIN_READS}"
mkdir -p ${DIFF_DIR}
mkdir -p ${JOBS_OUT_DIR}

cd ${VAST_OUT}

echo -e "Differential splicing analysis of vast-tools inclusion table"
# A and B are the oppositve as the vast-tools compare

DIFF_OUTFILE="HeLa_TAF2OE_minRead${MIN_READS}_noB3_pIR"
qsub -q ${QUEUE_NAME} -V -cwd -pe smp ${Num_Processes} -terse \
     -l virtual_free=${Num_Ram}G -l h_rt=${Num_Hours}:45:15 \
     -m ea -M ${CRG_EMAIL} -N ${JOB_NAME}_${DIFF_OUTFILE} -j y \
     -o "${JOBS_OUT_DIR}/${DIFF_OUTFILE}.log" -b y \
     vast-tools diff -i ${PSI_TBL} \
                     -d ${DIFF_OUTFILE} \
                     -n 10000 -m ${MIN_dPSI} -e ${MIN_READS} -z 16 \
                     -b HeLa_FRT_A,HeLa_FRT_B,HeLa_FRT_C \
                     -a HeLa_TAF2_A,HeLa_TAF2_B,HeLa_TAF2_C \
                     --noPDF \
                     -c ${Num_Processes} \
                     -o ${VAST_OUT} 

# mv "${VAST_OUT}/${DIFF_OUTFILE}.tab" ${DIFF_DIR}

DIFF_OUTFILE="HeLa_NLSTAF2dIDR_minRead${MIN_READS}_noB3_pIR"
qsub -q ${QUEUE_NAME} -V -cwd -pe smp ${Num_Processes} -terse \
     -l virtual_free=${Num_Ram}G -l h_rt=${Num_Hours}:45:15 \
     -m ea -M ${CRG_EMAIL} -N ${JOB_NAME}_${DIFF_OUTFILE} -j y \
     -o "${JOBS_OUT_DIR}/${DIFF_OUTFILE}.log" -b y \
     vast-tools diff -i ${PSI_TBL} \
                     -d ${DIFF_OUTFILE} \
                     -n 10000 -m ${MIN_dPSI} -e ${MIN_READS} -z 16 \
                     -b HeLa_FRT_A,HeLa_FRT_B,HeLa_FRT_C \
                     -a HeLa_NLSTAF2dIDR_A,HeLa_NLSTAF2dIDR_B,HeLa_NLSTAF2dIDR_C \
                     --noPDF \
                     -c ${Num_Processes} \
                     -o ${VAST_OUT} 

# mv "${VAST_OUT}/${DIFF_OUTFILE}.tab" ${DIFF_DIR}

# tail -n +2 HeLa_TAF2OE_minRead10_noB3_pIR.tab | \
#      awk '{OFS="\t"} { if($6 >= 0.15) print $1, $2, $5, $6}' | \
#      sort -k3,4nr  | sed -e $'1iGENE\tEVENT\tdPSI\tMVdPSIat95'  > Fltrd

tail -n +2 HeLa_TAF2OE_minRead10_noB3_pIR.tab | awk '{OFS="\t"} { if($6 >= 0.15) print $1, $2, $5, $6}' | sort -k3,4nr  | sed -e $'1iGENE\tEVENT\tdPSI\tMVdPSIat95'