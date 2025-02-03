#!/bin/bash -l

#SBATCH --job-name=ATLAS_recal_theta
#SBATCH -o ATLAS_recal_theta-%j.out 
#SBATCH -p main 
#SBATCH -n 1  
#SBATCH -N 1  
#SBATCH --cpus-per-task=40 

enable_lmod
module load container_env atlas/20240503
export SINGULARITY_BIND=/home/e1garcia

BAMDIR=$1
OUTDIR=$2

BAMPATTERN=*merged.rmdup.merged.realn_RGInfo.json

all_samples=$(ls $BAMDIR/$BAMPATTERN | sed -e 's/\.merged\.rmdup\.merged\.realn_RGInfo\.json//' -e 's/.*\///g')
all_samples=($all_samples)

sample_name=${all_samples[${SLURM_ARRAY_TASK_ID}]}
echo ${sample_name}

cd ${OUTDIR}
cp ${BAMDIR}/${sample_name}* .

crun.atlas atlas --task theta --bam ${sample_name}.merged.rmdup.merged.realn.bam --RGInfo ${sample_name}.merged.rmdup.merged.realn_RGInfo.json --prob 1,0.5,0.2,0.1,0.05,0.02,0.01 --out ${sample_name}_theta --logFile ${sample_name}_log
