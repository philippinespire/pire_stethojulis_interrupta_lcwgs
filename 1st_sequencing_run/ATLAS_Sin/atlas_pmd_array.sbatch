#!/bin/bash -l

#SBATCH --job-name=ATLAS_PMD
#SBATCH -o ATLAS_PMD-%j.out 
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

BAMPATTERN=*_clmp.fp2_repr_fltrd.bam

all_samples=$(ls $SPDIR/mkBAM/$BAMPATTERN | sed -e 's/_clmp.fp2_repr_fltrd\.bam//' -e 's/.*\///g')
all_samples=($all_samples)

sample_name=${all_samples[${SLURM_ARRAY_TASK_ID}]}
echo ${sample_name}

mkdir -p ${SPDIR}/ATLAS/
mkdir -p ${SPDIR}/ATLAS/joblog

cd ${SPDIR}/ATLAS/

samtools view ${SPDIR}/mkBAM/${sample_name}_clmp.fp2_repr_fltrd.bam | crun rgsam collect -s sample -o ${SPDIR}/ATLAS/${sample_name}_fltrd_rg.txt

sed -i 's/SM:sample/SM:${sample_name}/g' ${SPDIR}/ATLAS/${sample_name}_fltrd_rg.txt

sed -i 's/LB:sample/LB:${sample_name}-lcwgs_lib1/g' ${SPDIR}/ATLAS/${sample_name}_fltrd_rg.txt

samtools view -h ${SPDIR}/mkBAM/${sample_name}_clmp.fp2_repr_fltrd.bam | crun rgsam tag -r ${SPDIR}/ATLAS/${sample_name}_fltrd_rg.txt | samtools view -b - > ${SPDIR}/ATLAS/${sample_name}_clmp.fp2_repr_fltrd_rg.bam

samtools index ${SPDIR}/ATLAS/${sample_name}_clmp.fp2_repr_fltrd_rg.bam

crun atlas task=PMD bam=${SPDIR}/ATLAS/${sample_name}_clmp.fp2_repr_fltrd_rg.bam fasta=${SPDIR}/refGenome/${REFLOC}
