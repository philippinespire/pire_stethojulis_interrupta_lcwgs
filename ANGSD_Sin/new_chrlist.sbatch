#!/bin/bash -l

#SBATCH --job-name=angsd_newchrslist
#SBATCH -o angsd_newchrslist-%j.out 
#SBATCH -p main 
#SBATCH -n 1  
#SBATCH -N 1  
#SBATCH --cpus-per-task=8 

enable_lmod
module load container_env angsd
export SINGULARITY_BIND=/home/e1garcia

OUTDIR=$1


cd ${OUTDIR}

crun angsd sites index neutral_fdr_snp_list_depth1_15_notrans.txt
