#!/bin/bash

# this script sends several jobs each to their own compute node using an array, which limits the number of nodes used at one time

BAMDIR=$1
OUTDIR=$2

BAMPATTERN=*merged.rmdup.merged.realn_RGInfo.json

all_samples=$(ls $BAMDIR/$BAMPATTERN | sed -e 's/\.merged\.rmdup\.merged\.realn_RGInfo\.json//' -e 's/.*\///g')
all_samples=($all_samples)

all_samples=( $(ls $BAMDIR/$BAMPATTERN) )

JOBID=$(sbatch --array=0-$((${#all_samples[@]}-1))%20 \
       --output=atlas_gerp.%A.%a.out \
       --partition main \
       -t 96:00:00 \
      /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ATLAS_Sin/atlas_theta_albrecal_array.sbatch ${BAMDIR} ${OUTDIR})
