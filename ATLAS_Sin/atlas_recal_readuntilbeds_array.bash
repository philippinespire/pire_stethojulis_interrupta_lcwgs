#!/bin/bash

# this script sends several jobs each to their own compute node using an array, which limits the number of nodes used at one time

BAMDIR=$1
REFLOC=$2
OUTDIR=$3

BAMPATTERN=*merged.rmdup.merged.realn.bam

all_samples=$(ls $BAMDIR/$BAMPATTERN | sed -e 's/\.merged\.rmdup\.merged\.realn\.bam//' -e 's/.*\///g')
all_samples=($all_samples)

all_samples=( $(ls $BAMDIR/$BAMPATTERN) )

JOBID=$(sbatch --array=0-$((${#all_samples[@]}-1))%20 \
       --output=atlas_gerp.%A.%a.out \
       --partition main \
       -t 96:00:00 \
       /archive/carpenterlab/pire/pire_gerres_oyena_lcwgs/2nd_sequencing_run/ATLAS_nurecal/atlas_recal_readuntilbeds_array.sbatch ${BAMDIR} ${REFLOC} ${OUTDIR})
