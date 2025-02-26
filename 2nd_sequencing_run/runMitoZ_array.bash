#!/bin/bash 

#Script for running MitoZ over multiple cssl libraries
#Use contam libraries created after second trim (fp2)
#just needs two arguments:
#1)location of fq_fp1_clmp_fp2 filder
#2)number of nodes to use (I set to 32 for a test run and it cranked through ~100 libraries in ~2 hrs)
#will execute MitoZ in parallel through the companion script runMitoZ_array.sbatch

#Pass in the maximum number of nodes to use at once
nodes=$2    # eg 32 - running 4 at a time?

INDIR=$1                 #example= /home/e1garcia/shotgun_PIRE/pire_cssl_data_processing/siganus_spinus/fq_fp1_clmp_fp2
FQPATTERN=*.clmp.fp2_r1.fq.gz        #forward reads

SCRIPTPATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

all_samples=$(ls $INDIR/$FQPATTERN | sed -e 's/.clmp.fp2_r1\.fq\.gz//' -e 's/.*\///g')
all_samples=($all_samples)

sbatch --array=0-$((${#all_samples[@]}-1))%${nodes} $SCRIPTPATH/runMitoZ_array.sbatch ${INDIR} ${nodes}
