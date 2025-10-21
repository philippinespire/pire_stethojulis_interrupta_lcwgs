#!/bin/bash -l

#SBATCH --job-name=pcangsd_pca
#SBATCH -o pcangsd_pca-%j.out 
#SBATCH -p main 
#SBATCH -n 1  
#SBATCH -N 1  
#SBATCH --cpus-per-task=16 

enable_lmod
module load container_env ngsTools
export SINGULARITY_BIND=/home/e1garcia

OUTDIR=$1


cd ${OUTDIR}

crun pcangsd -b angsd_depth1_15_notrans_snplist_neutral_fdr.beagle.gz --maf 0.001 --it 500 --threads 16 --out angsd_pca_notrans_neutral_fdr
