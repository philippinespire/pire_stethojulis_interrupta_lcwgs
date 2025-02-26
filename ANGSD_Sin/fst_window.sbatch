#!/bin/bash -l

#SBATCH --job-name=angsd_fst_window
#SBATCH -o angsd_fst_window-%j.out 
#SBATCH -p main 
#SBATCH -n 1  
#SBATCH -N 1  
#SBATCH --cpus-per-task=8 

enable_lmod
module load container_env angsd
export SINGULARITY_BIND=/home/e1garcia


## This script is used to get pairwise windowed Fst estimates from angsd for each population / group pair

SAFDIR=${1:-/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin}
THREADS=${2:-8} # Number of parallel threads to use, default value is 8.
EXTRA_ARG=${3:-''} # Extra arguments for the SFS estimation step, default value is ''
POP1=${4:-APnd_sites_notrans}
POP2=${5:-CPnd_sites_notrans}

cd $SAFDIR

# Estimating average Fst in angsd
crun.angsd realSFS fst stats2 $POP1'_'$POP2'.alpha_beta.fst.idx' -win 50000 -step 10000 > $POP1'_'$POP2'.window_fst.txt' 
