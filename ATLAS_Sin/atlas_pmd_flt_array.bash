#!/bin/bash 

#script to calculate postmortem damage, given a folder with bam files and a reference genome
#will output to a new folder called "ATLAS"
#must make sure reference genome is uncompressed and indexed with samtools faidx before using

SPDIR=$1		#species directory. example= /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/salarias_fasciatus
REFLOC=$2	#reference that files were aligned to. example= refGenome/GCF_902148845.1_fSalaFa1.1_chr1-23-mtgen.fna

BAMPATTERN=*.rmdup.bam

SCRIPTPATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

all_samples=$(ls $SPDIR/fltrBAM_pp/$BAMPATTERN | sed -e 's/\.rmdup\.bam//' -e 's/.*\///g')
all_samples=($all_samples)

sbatch --array=0-$((${#all_samples[@]}-1))%${nodes} $SCRIPTPATH/atlas_pmd_flt_array.sbatch ${SPDIR} ${REFLOC}
