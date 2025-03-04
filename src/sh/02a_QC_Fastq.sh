#!/bin/bash
# Generate a FastQC on Raw fastq files

# REMEMBER: activate conda env with latest versions of QC tools
# conda activate vast-tools
echo -e "Remember to activate the conda environment for the required software\n\tconda activate vast-tools\n"
sleep 1

# How many processes?
Num_Hours=2
Num_Ram=6
Num_Processes=1

# Time ref
DATE=`date +%Y_%m_%d`

# Set Up PARAMS
COMPRESSED="YES"
SEQ_LAYOUT="PE" # "PE" or "SE"
PROJ_NAME="01_ALTdemix"
EXPERIMENT_NAME="Tanja"
JOB_NAME="FstQC"
QUEUE_NAME="long-sl7"
CRG_EMAIL="***.***@crg.eu"

# Set Up directories paths
PROJ_DIR="/users/mirimia/narecco/projects/${PROJ_NAME}"
FASTQ_DIR="/users/mirimia/narecco/sharing/${EXPERIMENT_NAME}/fastq_split3"
JOBS_OUT_DIR="/users/mirimia/narecco/qsub_out/${DATE}/${JOB_NAME}"
QC_DIR="${PROJ_DIR}/data/qc/${EXPERIMENT_NAME}"
FASTQC_DIR="${QC_DIR}/fastqc"
QC_ALL_READS_DIR="${FASTQC_DIR}/all_reads"

# Create output directory
mkdir -p ${QC_ALL_READS_DIR}
mkdir -p ${JOBS_OUT_DIR}

# change if the files are compressed or not.
if [ ${COMPRESSED} == "YES" ] ; then
    FASTQ_EXTENSION=".fastq.gz"

elif [ $COMPRESSED == "NO" ] ; then
    FASTQ_EXTENSION=".fastq"
fi

# Metadata tbl with New Sample Names in the second column. 
METADATA_FILE="${PROJ_DIR}/data/SRA_tbls/${EXPERIMENT_NAME}/Tanja_metadata.tab"

fastq_files=$( cut -f 1 ${METADATA_FILE} )

# Read in individual fastq files and run FASTQC
for file in ${fastq_files} ; do

  # Define the file path of the files based on the library layout
  # If fastq file is not found it is skipped
  if [ $SEQ_LAYOUT == "PE" ] ; then
    if [[ -f "${FASTQ_DIR}/${file}_1${FASTQ_EXTENSION}" ]] && [[ -f "${FASTQ_DIR}/${file}_2${FASTQ_EXTENSION}" ]] ; then
        fastq_path=$(ls ${FASTQ_DIR}/${file}_{1,2}${FASTQ_EXTENSION})
    else
        echo -e "\t${file}_1${FASTQ_EXTENSION} AND ${file}_2${FASTQ_EXTENSION} do NOT exist! Skipping these fastq samples!"
        continue
    fi
  elif [ $SEQ_LAYOUT == "SE" ] ; then
    if [[ -f "${FASTQ_DIR}/${file}${FASTQ_EXTENSION}" ]] ; then
      fastq_path=$(ls ${FASTQ_DIR}/${file}${FASTQ_EXTENSION})
    else
      echo -e "\t${file}${FASTQ_EXTENSION} does NOT exist! Skipping this fastq sample!"
      continue
    fi
  else 
    echo -e "SEQ_LAYOUT is not 'PE' nor 'SE'\n\n"
    exit 
  fi 

  # For each read (_{1,2} if Paired End) in the path
  for reads in ${fastq_path}; do
  
    sample_name=$( basename $reads ${FASTQ_EXTENSION} )
    echo -e "Running FastQC on: ${sample_name}"

    qsub -q ${QUEUE_NAME} -V -cwd -pe smp ${Num_Processes} -terse \
         -l virtual_free=${Num_Ram}G -l h_rt=${Num_Hours}:05:15 \
         -N ${sample_name}_${JOB_NAME} -m a -M ${CRG_EMAIL} -j y \
         -o "${JOBS_OUT_DIR}/${sample_name}.log" -b y \
         fastqc ${reads} \
                --outdir ${QC_ALL_READS_DIR} \
                --nogroup \
                --format fastq \
                --kmers 8 \
                --threads ${Num_Processes}
  done
done
