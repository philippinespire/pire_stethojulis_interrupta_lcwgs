#!/bin/bash -l

#SBATCH --job-name=ATLAS_PMD_pp
#SBATCH -o ATLAS_PMD_pp-%j.out 
#SBATCH -p main 
#SBATCH -n 1  
#SBATCH -N 1  
#SBATCH --cpus-per-task=40 

enable_lmod
module load bwa
module load samtools
module load container_env atlas
export SINGULARITY_BIND=/home/e1garcia

SPDIR=$1
REFLOC=$2

BAMPATTERN=*.rmdup.bam

all_samples=$(ls $SPDIR/fltrBAM_pp/$BAMPATTERN | sed -e 's/\.rmdup\.bam//' -e 's/.*\///g')
all_samples=($all_samples)

sample_name=${all_samples[${SLURM_ARRAY_TASK_ID}]}
echo ${sample_name}

mkdir -p ${SPDIR}/ATLAS_fltr_pp/
mkdir -p ${SPDIR}/ATLAS_fltr_pp/joblog

cd ${SPDIR}/ATLAS/

samtools view ${SPDIR}/fltrBAM_pp/${sample_name}.rmdup.bam | crun rgsam collect -s sample -o ${SPDIR}/ATLAS_fltr_pp/${sample_name}_fltr_pp_rg.txt

sed -i 's/SM:sample/SM:${sample_name}/g' ${SPDIR}/ATLAS_fltr_pp/${sample_name}_fltr_pp_rg.txt

sed -i 's/LB:sample/LB:${sample_name}-lcwgs_lib1/g' ${SPDIR}/ATLAS_fltr_pp/${sample_name}_fltr_pp_rg.txt

samtools view -h ${SPDIR}/fltrBAM_pp/${sample_name}.rmdup.bam | crun rgsam tag -r ${SPDIR}/ATLAS_fltr_pp/${sample_name}_fltr_pp_rg.txt | samtools view -b - > ${SPDIR}/ATLAS_fltr_pp/${sample_name}_fltr_pp_rg.bam

samtools index ${SPDIR}/ATLAS_fltr_pp/${sample_name}_fltr_pp_rg.bam

crun atlas task=PMD bam=${SPDIR}/ATLAS_fltr_pp/${sample_name}_fltr_pp_rg.bam fasta=${SPDIR}/refGenome/${REFLOC}
