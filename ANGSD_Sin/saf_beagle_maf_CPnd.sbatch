#!/bin/bash -l

#SBATCH --job-name=angsd_saf
#SBATCH -o angsd_saf-%j.out 
#SBATCH -p main 
#SBATCH -n 1  
#SBATCH -N 1  
#SBATCH --cpus-per-task=8 

enable_lmod
module load container_env angsd
export SINGULARITY_BIND=/home/e1garcia

OUTDIR=$1


cd ${OUTDIR}

crun angsd \
        -b bam_list_all_CPnd.txt \
        -anc /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
        -ref /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
        -out CPnd_sites_notrans \
	-doSaf 1 -noTrans 1 -GL 1 -doGlf 2 -doMaf 1 -doMajorMinor 3 -doCounts 1 -doDepth 1 -dumpCounts 1 -P 8 \
        -sites global_snp_list_depth1_15_notrans.txt -rf global_snp_list_depth1_15_notrans.chrs
