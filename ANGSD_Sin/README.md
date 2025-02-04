<img src="https://inaturalist-open-data.s3.amazonaws.com/photos/236392150/original.jpg" alt="Sin" width="300"/>

# ANGSD: *Stethojulis interrupta* lcWGS data from Pandanon Island

Following the [ANGSD pipeline](https://github.com/philippinespire/pire_lcwgs_data_processing/tree/main/scripts/ANGSD_wahab) for *Stethojulis interrupta* lcWGS data from the 1st & 2nd sequencing runs from Pandanon Island (Modern) and Cebu City Market (Historical).

```
/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```

[ANGSD](https://www.popgen.dk/angsd/index.php/ANGSD) is a software package that can calculate genotype likelihoods from mapped lcwgs data. Along with accessory packages such as [pcangsd](https://www.popgen.dk/software/index.php/PCAngsd) and [realSFS](https://www.popgen.dk/angsd/index.php/RealSFS), ANGSD can be used to perform a number of useful analyses, including estimating population structure, genetic divergence, genetic diversity, and loci potentially under selection. Scripts were adapted from the Therkildsen Lab's [GitHub](https://github.com/therkildsen-lab) to perform analyses in ANGSD.

Outline of potential analyses using ANGSD: 
  1) Combining sequencing runs
  2) SNP calling
  3) Generating genotype likelihoods and making a beagle.gz file
  4) Running PCANGSD: PCA and Admixture Analyses
  5) (Optional) Running PCANGSD: Selection Scan
  6) (Optional) Running winPCA to detect chromosome inversions
  7) Generating Site Allele Frequencies
  8) Calculating FST across the whole genome
  9) Generate site frequency spectra for each site/era
  10) Calculate per-site thetas
  11) Calculate neutrality test statistics
  12) {additional steps TBD}

---

<details><summary>1. Pre-processing</summary>

### 1. Pre-processing

Create an ANGSD directory within your species' lcwgs processing directory. 
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs

mkdir ANGSD_Sin
```

Copy GenErode output \*.bam files to be analyzed by ANGSD into the ANGSD_Sin directory. For Albatross/historical samples these are the `.merged.rmdup.merged.realn.rescaled.bam` files that have been rescaled to account for historic DNA damage. For contemporary files these are the `.merged.rmdup.merged.realn.bam` files.
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin

# Count modern GenErode output *.bam files
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/results/modern/mapping/reference.denovoSSL.Sin20k/*.merged.rmdup.merged.realn.bam | wc -l
64

# Copy modern GenErode output *.bam files
rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/results/modern/mapping/reference.denovoSSL.Sin20k/*.merged.rmdup.merged.realn.bam /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin &

# Count historical GenErode output *.bam files
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/results/historical/mapping/reference.denovoSSL.Sin20k/*.merged.rmdup.merged.realn.rescaled.bam | wc -l
25

# Copy historical GenErode output *.bam files
rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/results/historical/mapping/reference.denovoSSL.Sin20k/*.merged.rmdup.merged.realn.rescaled.bam /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin &

# Confirm all files have been copied. This is the number of individuals!
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin/*.bam | wc -l
89
```

</details>


<details><summary>2. SNP Calling</summary>

### 2. SNP Calling

An initial SNP calling step is used to identify a set of SNPs with a reasonable depth that can be assessed across the historic and contemporary samples.

Copy the `snp_calling.sbatch` script from ANGSD_wahab. 
```
cp /archive/carpenterlab/pire/pire_lcwgs_data_processing/scripts/ANGSD_wahab/snp_calling.sbatch ./
```

First make .txt files with list of all \*.bam files and a list of all \*.bam files with their full path.
```
ls *.bam > bam_list_all.txt

ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin/*.bam > bam_list_all_fullpath.txt
```

Generate an index for all .bam files, which will provide a supplementary index file (.bai) for each .bam file. 
```
salloc 

module load samtools

crun samtools index -M *.bam
```

Edit the `snp_calling.sbatch` script to fit your data. 
- After `-b`, add the full directory pathway to the file name of the `bam_list_all_fullpath.txt` file.
- After `-ref`, change the pathway to the correct reference genome for your species. Use the `reference.denovoSSL.Sin20k.fasta` reference genome from `GenErode_Sin_20k/reference`.
- setMinDepth: Minimum depth filter should be 1x the number of individuals: 89
- setMaxDepth: Maximum depth filter should be 15x the number of individuals: 1335
- minInd: Minimum individual filter should be half of the total number of individuals (round up for a whole number): 45
- Parameters that stayed the same from the original script are a map quality filter (minMapQ) of 30, a minimum allele frequency filter (minMaf) of 0.001, and a SNP p-value (SNP_pval) of 1e-6. 
```
nano snp_calling.sbatch

crun angsd \
        -b /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin/bam_list_all_fullpath.txt \
		-ref /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \ 
		-out angsd_depth1_15_notrans -GL 1 -doGlf 2 -doMaf 1 -doMajorMinor 1 -doCounts 1 -doDepth 1 -maxDepth 10000 -dumpCounts 1 -doIBS 1 -makematrix 1 -doCov 1 -noTrans 1  \
        -setMinDepth 89 -setMaxDepth 1335 -minInd 45 \
        -minMapQ 30 \
        -SNP_pval 1e-6 -minMaf 0.001 \
        -P 40 \
        -remove_bads 1 -only_proper_pairs 1 -C 50
```

Run `snp_calling.sbatch` and specify the output directory. 
```
sbatch snp_calling.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 
2//25 @ PST

Check output files.
```
less


```

</details>
