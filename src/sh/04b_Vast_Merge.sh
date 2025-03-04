#!/bin/bash
# Merge individual replicates with vast-tools merge then later on analysed as another sample

# How many processes?
Num_Hours=1
Num_Ram=12 # In GigaBytes
Num_Processes=1

# Time ref
DATE=`date +%Y_%m_%d`

# Set up variable names
PROJ_NAME="01_ALTdemix"
EXPERIMENT_NAME="Tanja"
JOB_NAME="VstMrg"
QUEUE_NAME="long-sl7"
CRG_EMAIL="***.***@crg.eu"

# VAST-TOOLS OPTIONS
VAST_SPECIES="hg38"
VAST_IR_VERSION=2

# Set up directories paths
PROJ_DIR="/users/mirimia/narecco/projects/${PROJ_NAME}"
JOBS_OUT_DIR="/users/mirimia/narecco/qsub_out/${DATE}/${JOB_NAME}"
VAST_TOOLS="${PROJ_DIR}/data/INCLUSION_tbl/${EXPERIMENT_NAME}/vast_tools"
VAST_OUT="${VAST_TOOLS}/vast_out"
mkdir -p ${JOBS_OUT_DIR}

# Since vast-tools merge does NOT support multi-threads and would merge all config groups at the same time
# this step might result a bit memory intensive. So I split the config file into subsection each for each grouping. 
# and write them into a subfolder as tab files.

METADATA_FILE="${PROJ_DIR}/data/SRA_tbls/${EXPERIMENT_NAME}/Tanja_metadata.tab"
CONFIG_TBL="${PROJ_DIR}/data/SRA_tbls/${EXPERIMENT_NAME}/GROUP_VST_ALL_SUBSECTIONS.tab"
SECTIONS_DIR="${PROJ_DIR}/data/SRA_tbls/${EXPERIMENT_NAME}/SUBSECTIONS"
mkdir -p ${SECTIONS_DIR}

# create a grouping file from the metadata table by using only columns 2 and 3 where each group is separated in a new section with a new line
touch ${CONFIG_TBL}
cat ${METADATA_FILE} | \
     awk '{OFS = "\t"} { print $1, $2 }' | \
     awk '{a[$2]=a[$2]?a[$2] ORS $0:$0} END{for(k in a) print a[k] ORS ORS}' | \
     cat -s > ${CONFIG_TBL}

# From: https://stackoverflow.com/a/30744750/9938003
# This splits the config files section in a bash array
# the draw back of this approach is that if there's only a single file in merge it will be "merged" with itself and create a duplicate of the individual file
# I should create a check to avoid maybe merging individual samples that don't have replicates. Maybe?
sections=( )
current_section=
while REPLY=; IFS= read -r || [[ $REPLY ]]; do
  if [[ $REPLY ]]; then
    # preserve newlines within the sections
    if [[ $current_section ]]; then
      current_section+=$'\n'"$REPLY"
    else
      current_section+=$REPLY
    fi
  else
    sections+=( "$current_section" )
    current_section=
  fi
done <  ${CONFIG_TBL}

cd ${VAST_TOOLS}

echo -e "Launching vast-tools merge on ${EXPERIMENT_NAME}\n"

for section in "${sections[@]}"; do
  
  # Write a small subgroup to a file
  SECTION_NAME=$( echo "$section" | awk '{OFS = "\t"} { print $2 }' | sort | uniq )
  SECTION_PATH="${SECTIONS_DIR}/${SECTION_NAME}.tab"
  echo "$section" | awk '{OFS = "\t"} { print $1, $2 }' > ${SECTION_PATH}

  echo -e "Merging subsection: ${SECTION_NAME}"

  qsub -q ${QUEUE_NAME} -V -cwd -pe smp ${Num_Processes} -terse \
     -l virtual_free=${Num_Ram}G -l h_rt=${Num_Hours}:05:15 \
     -m ea -M ${CRG_EMAIL} -N ${JOB_NAME}_${SECTION_NAME} -j y \
     -o "${JOBS_OUT_DIR}/${SECTION_NAME}.log" -b y \
     vast-tools merge --groups ${SECTION_PATH} \
                      --sp ${VAST_SPECIES} \
                      --IR_version ${VAST_IR_VERSION} \
                      --expr \
                      -o ${VAST_OUT}
done


echo "You can check that all the merges went fine with:"
echo -e "\tgrep -L 'Merge finished successfully' ${JOBS_OUT_DIR}/*.log"
echo "This will show you ONLY the merges that were not successful so ideal it should return nothing."



