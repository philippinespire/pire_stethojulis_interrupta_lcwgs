#!/bin/bash -l

#run MitoZ on contam reads for each individual

#SBATCH --job-name=MitoZ-%j
#SBATCH --output MitoZ-%j.out
#SBATCH -p main
#SBATCH --time=48:00:00
#SBATCH -c 8
#SBATCH --exclusive=user

enable_lmod
module load container_env MitoZ
export SINGULARITY_BIND=/home/e1garcia

INDIR=${1}
FQPATTERN=*.clmp.fp2_r1.fq.gz

all_samples=$(ls $INDIR/$FQPATTERN | sed -e 's/.clmp.fp2_r1\.fq\.gz//' -e 's/.*\///g')
all_samples=($all_samples)

sample_name=${all_samples[${SLURM_ARRAY_TASK_ID}]}
echo ${sample_name}

mkdir ${INDIR}/${sample_name}_MitoZ
cd ${INDIR}/${sample_name}_MitoZ

crun MitoZ.py all2 --genetic_code 2 --clade Chordata --outprefix ${sample_name} --thread_number 8 --fastq1 ${INDIR}/${sample_name}.clmp.fp2_r1.fq.gz --fastq2 ${INDIR}/${sample_name}.clmp.fp2_r2.fq.gz --fastq_read_length 150

rm -r tmp
