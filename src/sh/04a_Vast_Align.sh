#!/bin/bash
# Launch paired end (PE) or single end (SE) vast-tools align from input fastq files

# How many processes?
Num_Hours=18
Num_Ram=12 # In GigaBytes
Num_Processes=6

# Time ref
DATE=`date +%Y_%m_%d`

# Set up variables
PROJ_NAME="01_ALTdemix"
EXPERIMENT_NAME="Tanja"
JOB_NAME="VstAlgn"
QUEUE_NAME="long-sl7,mem_512"
CRG_EMAIL="niccolo.arecco@crg.eu"

# Library sequencing layout
SEQ_LAYOUT="PE" # "PE" or "SE"

# Are the files compressed or not?
COMPRESSED="YES" # "YES" or "NO"

# change if the files are compressed or not.
if [ ${COMPRESSED} == "YES" ] ; then
    FASTQ_EXTENSION=".fastq.gz"

elif [ $COMPRESSED == "NO" ] ; then
    FASTQ_EXTENSION=".fastq"
fi

# Set Up directories paths
FASTQ_DIR="/users/mirimia/narecco/sharing/${EXPERIMENT_NAME}/fastq_split3"
PROJ_DIR="/users/mirimia/narecco/projects/${PROJ_NAME}"
JOBS_OUT_DIR="/users/mirimia/narecco/qsub_out/${DATE}/${JOB_NAME}"
METADATA_FILE="${PROJ_DIR}/data/SRA_tbls/${EXPERIMENT_NAME}/Tanja_metadata.tab"

VAST_TOOLS="${PROJ_DIR}/data/INCLUSION_tbl/${EXPERIMENT_NAME}/vast_tools"
VAST_OUT="${VAST_TOOLS}/vast_out"
mkdir -p ${VAST_OUT}
mkdir -p ${JOBS_OUT_DIR}

# Specie input
FASTQ_FILENAME=$( cut -f 1 ${METADATA_FILE} )

# VAST-TOOLS OPTIONS
VAST_SPECIES="hg38"
VAST_IR_VERSION=2
VAST_TRIM_STEP=25

echo -e "\nLaunching vast align ${EXPERIMENT_NAME} with these options:"
echo -e "\tQueue: ${QUEUE_NAME}\n\tProcessors: ${Num_Processes} Threads"
echo -e "\tRAM: ${Num_Ram} GigaBytes\n\tTime: ${Num_Hours}:45:15"
echo -e "\tLog files in ${JOBS_OUT_DIR}"
echo -e "\tSpecies: ${VAST_SPECIES}\tIntron Retention module version: ${VAST_IR_VERSION}\tvast-tools trim step size: ${VAST_TRIM_STEP}"

sleep 3

module load Bowtie/1.2.1.1-foss-2016b

for file in ${FASTQ_FILENAME} ; do
 
  # Define the input files based on the library
  if [ $SEQ_LAYOUT == "PE" ] ; then
    # PAIRED END SEQ: set input file 1 to "READ1", input file 2 to "READ2"
    READ1=$(ls ${FASTQ_DIR}/${file}_1${FASTQ_EXTENSION})
    READ2=$(ls ${FASTQ_DIR}/${file}_2${FASTQ_EXTENSION})
    READ_INPUT=$( echo "${READ1} ${READ2}")

  elif [ $SEQ_LAYOUT == "SE" ] ; then
    # SINGL END SEQ:
    if [[ -f "${FASTQ_DIR}/${file}${FASTQ_EXTENSION}" ]] ; then
      READ_INPUT=$( ls ${FASTQ_DIR}/${file}${FASTQ_EXTENSION} )
    else
      echo -e "\t${file}${FASTQ_EXTENSION} does NOT exist! Skipping this sample!"
      continue
    fi

  else 
    echo -e "SEQ_LAYOUT is not 'PE' nor 'SE'\n\n"
    exit 
  fi 

  qsub -q ${QUEUE_NAME} -cwd -pe smp ${Num_Processes} -terse \
       -l virtual_free=${Num_Ram}G -l h_rt=${Num_Hours}:45:15 \
       -N ${file}_${JOB_NAME} -m a -M ${CRG_EMAIL} -j y \
       -o "${JOBS_OUT_DIR}/${file}.log" -b y \
       vast-tools align ${READ_INPUT} \
                        --name ${file} \
                        --sp ${VAST_SPECIES} \
                        --expr --EEJ_counts \
                        --IR_version ${VAST_IR_VERSION} \
                        --stepSize ${VAST_TRIM_STEP} \
                        --cores ${Num_Processes} \
                        --output ${VAST_OUT}
done
