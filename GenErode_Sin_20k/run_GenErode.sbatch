#!/bin/bash

#SBATCH -c 2

# don't change this, this is just the "kickoff" job, snakemake will launch more jobs on its own

module load snakemake/7.25.4

snakemake --latency-wait 60 -j 40 --use-singularity --slurm

# -j 40 means at maximum, 40 jobs will be running parallely, you can increase or decrease as you see fit
# --slurm is important, it allows snakemake to submitting slurm job properly
