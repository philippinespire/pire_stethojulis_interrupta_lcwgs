#!/bin/bash -l

#SBATCH --job-name=pcangsd_selection
#SBATCH -o pcangsd_selection-%j.out 
#SBATCH -p main 
#SBATCH -n 1  
#SBATCH -N 1  
#SBATCH --cpus-per-task=16 

enable_lmod
module load container_env ngsTools
export SINGULARITY_BIND=/home/e1garcia

OUTDIR=$1


cd ${OUTDIR}


crun pcangsd -b angsd_depth1_15_notrans.beagle.gz --it 2000 --maf 0.001 --threads 16 --out angsd_notrans_snps_selection_it2000 --selection --sites_save
