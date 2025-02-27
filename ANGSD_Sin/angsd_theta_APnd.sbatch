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

# Add the Albatross .saf.idx file after the saf2theta command e.g.: APnd_sites_notrans_subset.saf.idx
# Add the Albatross sfs file after the -sfs prompt e.g.: APnd_notrans_subset.sfs
# Edit the -outname to reflect your data e.g.: APnd_notrans_subset

crun.angsd realSFS saf2theta APnd_sites_notrans.saf.idx -sfs APnd_sites_notrans.sfs -fold 1 -P 8 -outname APnd_sites_notrans
