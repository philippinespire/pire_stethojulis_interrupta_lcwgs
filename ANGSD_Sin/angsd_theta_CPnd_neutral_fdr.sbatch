#!/bin/bash -l

#SBATCH --job-name=angsd_theta
#SBATCH -o angsd_theta-%j.out
#SBATCH -p main
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --cpus-per-task=8

enable_lmod
module load container_env angsd
export SINGULARITY_BIND=/home/e1garcia

OUTDIR=$1


cd ${OUTDIR}

# Add the Contemporary .saf.idx file after the saf2theta command: CPnd_sites_notrans_subset.saf.idx
# Add the Contemporary sfs file after the -sfs prompt: CPnd_notrans_subset.sfs
# Edit the -outname to reflect your data: CPnd_notrans_subset

crun.angsd realSFS saf2theta CPnd_sites_notrans_neutral_fdr.saf.idx -sfs CPnd_notrans_neutral_fdr.sfs -fold 1 -P 8 -outname CPnd_notrans_neutral_fdr

