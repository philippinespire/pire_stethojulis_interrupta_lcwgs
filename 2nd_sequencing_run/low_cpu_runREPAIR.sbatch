#!/bin/bash -l

#SBATCH --job-name=repr_fqscrn
#SBATCH -o repr-%j.out
#SBATCH --time=00:00:00
# cpu =40 for wahab and 32 for turing
#SBATCH --cpus-per-task=32
#SBATCH --exclusive=user

enable_lmod
module load container_env pire_genome_assembly/2021.07.01
#module load java/1.8
#module load bbmap/38.90
#module load parallel

export SINGULARITY_BIND=/home/e1garcia

INDIR=$1   #/home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_clmp_fp2_fqscrnBt2
OUTDIR=$2    #/home/e1garcia/shotgun_PIRE/fq_4denovo_fp1_clmp_fp2_fqscrnBt2_repaired
THREADS=$3    #repair.sh will spawn approxmately 8 threads per every one of these, so total threads/8 = this value
EXTENSION=.tagged_filter.fastq.gz

mkdir $OUTDIR $OUTDIR/orphans

# repair the paired end files
ls $INDIR/*$EXTENSION | \
sed -e "s/r[12]$EXTENSION//" -e "s/orph$EXTENSION//" -e 's/.*\///g' | \
uniq | \
crun parallel --no-notice -j $THREADS \
        repair.sh \
        in1=$INDIR/{}r1$EXTENSION \
        in2=$INDIR/{}r2$EXTENSION \
        out1=$OUTDIR/{}repr.R1.fq.gz \
        out2=$OUTDIR/{}repr.R2.fq.gz \
        outs=$OUTDIR/orphans/{}repr.orph.fq \
        overwrite=t \
        repair
