#!/bin/bash -l

#SBATCH --job-name=angsd_snp
#SBATCH -o angsd_snp-%j.out 
#SBATCH -p main 
#SBATCH -n 1  
#SBATCH -N 1  
#SBATCH --cpus-per-task=40 

enable_lmod
module load container_env angsd
export SINGULARITY_BIND=/home/e1garcia

OUTDIR=$1


cd ${OUTDIR}

crun angsd \
        -b /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin/bam_list_all_fullpath.txt \
	-ref /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
	-out angsd_depth1_15_notrans -GL 1 -doGlf 2 -doMaf 1 -doMajorMinor 1 -doCounts 1 -doDepth 1 -maxDepth 10000 -dumpCounts 1 -doIBS 1 -makematrix 1 -doCov 1 -noTrans 1  \
        -setMinDepth 89 -setMaxDepth 1335 -minInd 45 \
        -minMapQ 30 \
        -SNP_pval 1e-6 -minMaf 0.001 \
        -P 40 \
        -remove_bads 1 -only_proper_pairs 1 -C 50

## Create a SNP list to use in downstream analyses
gunzip -c angsd_depth1_15_notrans.mafs.gz | cut -f 1,2,3,4 | tail -n +2 > global_snp_list_depth1_15_notrans.txt
crun angsd sites index global_snp_list_depth1_15_notrans.txt

## Also make it in regions format for downstream analyses
cut -f 1,2 global_snp_list_depth1_15_notrans.txt | sed 's/\t/:/g' > global_snp_list_depth1_15_notrans.regions

## Lastly, extract a list of chromosomes/LGs/scaffolds for downstream analysis
cut -f1 global_snp_list_depth1_15_notrans.txt | sort | uniq > global_snp_list_depth1_15_notrans.chrs

