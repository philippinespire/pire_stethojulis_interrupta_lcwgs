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

Confirm that there are the same number of .bai and .bam files. This is the number of individuals!
```
ls *.bam | wc -l
89

ls *.bai | wc -l
89
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
JobID: 4256546
2/4/25 @ 13:46 PST

Check output files.
```
less angsd_snp-4256546.out

Filtering complete: Observed: 313 different chromosomes from file:global_snp_list_depth1_15_notrans.txt
```

</details>


<details><summary>3. Generate genotype likelihoods & a beagle.gz file</summary>

### 3. Generate genotype likelihoods & a beagle.gz file 

Genotype likelihoods will be used for all downstream analyses (PCA, admixture, estimating diversity, FST, and selection).
Use the get_beagle.sbatch file to generate a .beagle.gz file containing genotype likelihoods for the set of SNPs identified in the SNP calling step. 

Copy the `get_beagle.sbatch` script from ANGSD_wahab. 
```
cp /archive/carpenterlab/pire/pire_lcwgs_data_processing/scripts/ANGSD_wahab/get_beagle.sbatch ./
```

Edit `get_beagle.sbatch`.
- After `-anc`, change the pathway to the correct reference genome for your species. Use the `reference.denovoSSL.Sin20k.fasta` reference genome from `GenErode_Sin_20k/reference`.
```
nano get_beagle.sbatch

crun angsd \
        -b bam_list_all.txt \
        -anc /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
        -out angsd_depth1_15_notrans.beagle.gz \
        -doSaf 1 -noTrans 1 -GL 1 -doGlf 2 -doMaf 1 -doMajorMinor 3 -doCounts 1 -doDepth 1 -dumpCounts 1 \
        -P 8 \
        -sites global_snp_list_depth1_15_notrans.txt -rf global_snp_list_depth1_15_notrans.chrs
```

Run `get_beagle.sbatch` and specify the output directory.
```
sbatch get_beagle.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 4257258
2/4/25 @ 16:48 PST

Check output files.
```
less angsd_beagle-4257258.out

Total number of sites analyzed: 9905586
Number of sites retained after filtering: 2106
```

**File naming error! 

All subsequent scripts that used `angsd_depth1_15_notrans.beagle.gz` used the wrong file. The `angsd_depth1_15_notrans.beagle.gz` file was generated by `snp_calling.sbatch`, not `get_beagle.sbatch`. The downstream scripts require the `.beagle.gz` file generated from `get_beagle.sbatch`, which contains genotype likelihoods for the set of SNPs identified in the SNP calling step, which was named `angsd_depth1_15_notrans.beagle.gz.beagle.gz`. The steps that this affected are PCANGSD & WinPCA. The PCANGSD scripts that this affected are `pcangsd_pca.sbatch`, `pcangsd_admix.sbatch`, and `pcangsd_selection.sbatch`. The outfile pattern of all future `get_beagle.sbatch` runs should be `--out angsd_depth1_15_notrans_snplist`. However, instead of rerunning `get_beagle.sbatch`, these files can just be rename, and the scripts can be edited. 

Copy the rename scripts from ANGSD_wahab. 
```
cp /archive/carpenterlab/pire/pire_lcwgs_data_processing/scripts/ANGSD_wahab/rename*.sh .
```

Run the script `rename_get_beagle_output_files.sh` to rename all of the output files from the `get_beagle.sbatch` script to standardize the outfile pattern (`-out`) as `angsd_depth1_15_notrans_snplist` instead of `angsd_depth1_15_notrans.beagle.gz`. This will have to be edited for a `subset` run. 
```
bash rename_get_beagle_output_files.sh
```

Use the script `rename_pcangsd_sbatch_beagle_filename.sh` to rename all of the input beagle.gz scripts in the `pcangsd_*.sbatch` scripts from `-b angsd_depth1_15_notrans.beagle.gz` to `-b angsd_depth1_15_notrans_snplist.beagle.gz`. These scripts can then be run without any further changes. The output will overwrite the output from the previous incorrect runs. 
```
bash rename_pcangsd_sbatch_beagle_filename.sh
```

**Good to proceed with next steps. Make sure all relevant scripts are using the correct beagle.gz file: `angsd_depth1_15_notrans_snplist.beagle.gz`

</details>


<details><summary>4. PCANGSD: PCA</summary>

### 4. PCANGSD: PCA

**Correct beagle.gz

4.1 `pcangsd_pca.sbatch`

Edit the `pcangsd_pca.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans_snplist.beagle.gz  --maf 0.001 --threads 16 --out angsd_notrans_snps_pca
```

Run `pcangsd_pca.sbatch` and specify the output directory.
```
sbatch pcangsd_pca.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10706690
2/25/25 @ 23:07 PST

Check output files.
```
less pcangsd_pca-10706690.out

PCAngsd did not converge!
Saved covariance matrix as angsd_notrans_snps_pca.cov
```

**Did not converge. Rerun with 500 iterations

----

4.2 `pcangsd_pca_it500.sbatch`

Edit the `pcangsd_pca_it500.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans_snplist.beagle.gz --it 500 --maf 0.001 --threads 16 --out angsd_notrans_snps_it500_pca
```

Run `pcangsd_pca_it500.sbatch` and specify the output directory.
```
sbatch pcangsd_pca_it500.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10706692
2/25/25 @ 23:12 PST

Check output files.
```
less pcangsd_pca-10706692.out

PCAngsd did not converge!
Saved covariance matrix as angsd_notrans_snps_it500_pca.cov
```

**Did not converge. Rerun with 2000 iterations

----

4.3 `pcangsd_pca_it2000.sbatch`

Edit the `pcangsd_pca_it2000.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans_snplist.beagle.gz --it 2000 --maf 0.001 --threads 16 --out angsd_notrans_snps_it2000_pca
```

Run `pcangsd_pca_it2000.sbatch` and specify the output directory.
```
sbatch pcangsd_pca_it2000.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10706697
2/25/25 @ 23:18 PST

Check output files.
```
less pcangsd_pca-10706697.out

PCAngsd converged.
Saved covariance matrix as angsd_notrans_snps_it2000_pca.cov
```

**Converged. Check PCA & Admix plots. k = 2.

----

**DEPRECATED: wrong beagle

1.1 `pcangsd_pca.sbatch`

Copy the `pcangsd_pca.sbatch` script from ANGSD_wahab. 
```
cp /archive/carpenterlab/pire/pire_lcwgs_data_processing/scripts/ANGSD_wahab/pcangsd_pca.sbatch ./
```

Edit the `pcangsd_pca.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans.beagle.gz  --maf 0.001 --threads 16 --out angsd_notrans_snps_pca
```

Run `pcangsd_pca.sbatch` and specify the output directory.
```
sbatch pcangsd_pca.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 4257261 
2/4/25 @ 17:01 PST

Check output files.
```
less pcangsd_pca-4257261.out

PCAngsd did not converge!
Saved covariance matrix as angsd_notrans_snps_pca.cov
```

**DEPRECATED: wrong beagle

1.2 `pcangsd_pca_it500.sbatch`

Copy the `pcangsd_pca.sbatch` script from ANGSD_wahab and rename it to `pcangsd_pca_it500.sbatch` to indicate a file with 500 iterations.
```
cp /archive/carpenterlab/pire/pire_lcwgs_data_processing/scripts/ANGSD_wahab/pcangsd_pca.sbatch ./pcangsd_pca_it500.sbatch
```

Edit the `pcangsd_pca_it500.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans.beagle.gz --it 500 --maf 0.001 --threads 16 --out angsd_notrans_snps_pca_it500
```

Run `pcangsd_pca_it500.sbatch` and specify the output directory.
```
sbatch pcangsd_pca_it500.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 4257262
2/4/25 @ 17:03 PST

Check output files.
```
less pcangsd_pca-4257262.out

PCAngsd did not converge!
Saved covariance matrix as angsd_notrans_snps_pca_it500.cov
```
Maybe try more than 500 iterations. Try 2000 iterations. Check pcangsd_pca-4257262.out.
Move on to pcangsd selection scan. Don't remove inversion. At least not yet. Brendan 2/5/25

**DEPRECATED: wrong beagle

1.3 `pcangsd_pca_it2000.sbatch`

Copy the `pcangsd_pca_it500.sbatch` script and rename it to `pcangsd_pca_it2000.sbatch` to indicate a file with 2000 iterations.
```
cp pcangsd_pca_it500.sbatch pcangsd_pca_it2000.sbatch
```

Edit the `pcangsd_pca_it2000.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans.beagle.gz --it 2000 --maf 0.001 --threads 16 --out angsd_notrans_snps_pca_it2000
```

Run `pcangsd_pca_it2000.sbatch` and specify the output directory.
```
sbatch pcangsd_pca_it2000.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 4259821
2/5/25 @ 15:34 PST

Check output files.
```
less pcangsd_pca-4259821.out

PCAngsd converged.
Saved covariance matrix as angsd_notrans_snps_pca_it2000.cov
```

---

**Run with 2000 iterations first. Then run the selection scan. Then consider removing inversions. This would start with Step 6 WinPCA. Then return to Step 3 and use `get_beagle_noinv.sbatch` to remove inversions. 

You will want to get genotype likelihoods for all individuals and all chromosomes / scaffolds in order to run your first iteration of PCANGSD. After examining PCANGSD outputs, you may see evidence of (1) outlier individuals or (2) inversions in the PCA output. (1) will appear as particular Albatross or contemporary individuals that do not cluster with their respective era and/or site in the PCA plot, while (2) will be indicated by a "three-stripe" pattern in the PCA (i.e. individuals in the PCA generally do not cluster by their era or site, but rather show a pattern of three vertical or horizontal stripes).

For case (2), if you do not know which chromosomes or scaffolds contain inversions, you can run step 6 (WinPCA) to identify these. Once the inversions are identified, you can create a new get_beagle_noinv.sbatch file and a global_snp_list_depth1_15_notrans_noinv.chrs file and re-run the get_beagle step.

cp global_snp_list_depth1_15_notrans.chrs global_snp_list_depth1_15_notrans_noinv.chrs
# Remove the chromosomes/scaffolds containing inversions from global_snp_list_depth1_15_notrans_noinv.chrs

cp get_beagle.sbatch get_beagle_noinv.sbatch
# change -rf to global_snp_list_depth1_15_notrans_noinv.chrs
# change -out suffix to *_noinv.beagle.gz 

sbatch get_beagle_noinv.sbatch /archive/carpenterlab/pire/{species_dir}/angsd_analysis/


</details>


<details><summary>5. PCANGSD: Admix</summary>

### 5. PCANGSD: Admix

**Correct beagle.gz

5.1 `pcangsd_admix.sbatch`

Copy.
```
cp pcangsd_admix_it500.sbatch pcangsd_admix.sbatch
```

Edit the `pcangsd_admix_it500.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans_snplist.beagle.gz --admix --maf 0.001 --threads 16 --out angsd_notrans_snps_admix
```

Run `pcangsd_admix.sbatch` and specify the output directory.
```
sbatch pcangsd_admix.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10706691
2/25/25 @ 23:09 PST

Check output file.
```
less pcangsd_admix_notrans-10706691.out

PCAngsd did not converge!
Saved covariance matrix as angsd_notrans_snps_admix.cov

Converged.
Frobenius error: 1.5929399728775024
Log-likelihood: -84779.47178
Saved admixture proportions as angsd_notrans_snps_admix.admix.2.Q
Saved ancestral allele frequencies proportions as angsd_notrans_snps_admix.admix.2.P
```

**Did not converge. Rerun with 500 iterations. 

----

5.2 `pcangsd_admix_it500.sbatch`

Edit the `pcangsd_admix_it500.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans_snplist.beagle.gz --admix --it 500 --maf 0.001 --threads 16 --out angsd_notrans_snps_it500_admix
```

Run `pcangsd_admix_it500.sbatch` and specify the output directory.
```
sbatch pcangsd_admix_it500.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10706694
2/25/25 @ 23:15 PST

Check output file.
```
less 

PCAngsd did not converge!
Saved covariance matrix as angsd_notrans_snps_it500_admix.cov

Converged.
Frobenius error: 1.5929399728775024
Log-likelihood: -84779.18994
Saved admixture proportions as angsd_notrans_snps_it500_admix.admix.2.Q
Saved ancestral allele frequencies proportions as angsd_notrans_snps_it500_admix.admix.2.P
```

**Did not converge. Rerun with 2000 iterations. 

----

5.3 `pcangsd_admix_it2000.sbatch`

Edit the `pcangsd_admix_it2000.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans_snplist.beagle.gz --admix --it 2000 --maf 0.001 --threads 16 --out angsd_notrans_snps_it2000_admix
```

Run `pcangsd_admix_it2000.sbatch` and specify the output directory.
```
sbatch pcangsd_admix_it2000.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10706699
2/25/25 @ 23:21 PST

Check output file.
```
less pcangsd_admix_notrans-10706699.out

PCAngsd converged.
Saved covariance matrix as angsd_notrans_snps_it2000_admix.cov

Converged.
Frobenius error: 1.5929700136184692
Log-likelihood: -84779.14
Saved admixture proportions as angsd_notrans_snps_it2000_admix.admix.2.Q
Saved ancestral allele frequencies proportions as angsd_notrans_snps_it2000_admix.admix.2.P
```

**Converged. Check PCA & Admix plots. k = 2.

----

**DEPRECATED: wrong beagle

2.2 `pcangsd_admix_it500.sbatch`

Copy the `pcangsd_admix.sbatch` script from ANGSD_wahab and rename to `pcangsd_admix_it500.sbatch` to indicate a file with 500 iterations.
```
cp /archive/carpenterlab/pire/pire_lcwgs_data_processing/scripts/ANGSD_wahab/pcangsd_admix.sbatch ./pcangsd_admix_it500.sbatch
```

Edit the `pcangsd_admix_it500.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans.beagle.gz --admix --it 500 --maf 0.001 --threads 16 --out angsd_admix_notrans_it500
```

Run `pcangsd_admix_it500.sbatch` and specify the output directory.
```
sbatch pcangsd_admix_it500.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 4257265
2/4/25 @ 17:06 PST

Check output file.
```
less pcangsd_admix_notrans-4257265.out

Converged.
Frobenius error: 1.0855300426483154
Log-likelihood: -128751.63469
Saved admixture proportions as angsd_admix_notrans_it500.admix.2.Q
Saved ancestral allele frequencies proportions as angsd_admix_notrans_it500.admix.2.P
```

----

**DEPRECATED: wrong beagle

2.3 `pcangsd_admix_it2000.sbatch`

Copy the `pcangsd_admix_it500.sbatch` script and rename to `pcangsd_admix_it2000.sbatch` to indicate a file with 2000 iterations.
```
cp pcangsd_admix_it500.sbatch pcangsd_admix_it2000.sbatch
```

Edit the `pcangsd_admix_it2000.sbatch` script to fit your paths and filenames.
```
crun pcangsd -b angsd_depth1_15_notrans.beagle.gz --admix --it 2000 --maf 0.001 --threads 16 --out angsd_admix_notrans_it2000
```

Run `pcangsd_admix_it2000.sbatch` and specify the output directory.
```
sbatch pcangsd_admix_it2000.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 4259956
2/5/25 @ 15:46 PST

Check output file.
```
less pcangsd_admix_notrans-4259956.out

Converged.
Frobenius error: 1.0870100259780884
Log-likelihood: -128751.68366
Saved admixture proportions as angsd_admix_notrans_it2000.admix.2.Q
Saved ancestral allele frequencies proportions as angsd_admix_notrans_it2000.admix.2.P
```

----


</details>


<details><summary>5. PCANGSD: Admixture STATS</summary>

### 5. PCANGSD: Admixture STATS

**Analyze results


3. Analyze results

After running `running pcangsd_pca_it500_noinv_subset.sbatch` & `pcangsd_admix_it500_noinv_subset.sbatch`, analyze the output files`angsd_snps_pca.cov`, `bam_list.txt`, and `angsd_admix.2.Q` with the scripts `admixture.R` and `pca.R`. This can be done on [ODU OnDemand RStudio](https://ondemand.wahab.hpc.odu.edu/), or these output files and scripts can be downloaded and run locally. Run the `admixture.R` before `pca.R`.

Copy the R script `admixture.R`.
```
cp /archive/carpenterlab/pire/pire_lethrinus_variegatus_lcwgs/ANGSD_Lva/admixture_subset_k2.R ./admixture_it2000_k2.R
```

Make a directory for output plots.
```
mkdir plots
```

Run `admixture.R` in RStudio to get the admixture proportions plot. 
```
K = 2

k2_angsd_not <- read.table("angsd_notrans_snps_it2000_admix.admix.2.Q")

bamlist=read.table("bam_list_all.txt")

Number of Albatross (historical) BAM files: 25

Number of Contemporary (modern) BAM files: 64

Total number of BAM files: 89
```
Plot: `sin_plot_angsd_notrans_snps_it2000_admix_admix_2_Q.png`

----

**DEPRECATED. wrong beagle.gz. 500 Iterations: Admixture converged, but PCA did not converge

Run `admixture.R` in RStudio to get the admixture proportions plot. 
```
K = 2

k2_angsd_not <- read.table("/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin/angsd_admix_notrans_it500.admix.2.Q")

bamlist=read.table("/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin/bam_list_all.txt")
```
Plot: `sin_plot_angsd_admix_notrans_it500_admix_2_Q.png`

Run `pca.R` in RStudio to get the PCA for historical and contemporary individuals. 
```
cov_matrix_angsd <- as.matrix(read.table("/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin/angsd_notrans_snps_pca_it500.cov"))

bamlist=read.table("/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin/bam_list_all.txt")
```
Plot: `sin_plot_angsd_notrans_snps_pca_it500_cov.png`

---

**DEPRECATED. wrong beagle.gz. 2000 Iterations: PCA & Admixture converged

Run `admixture.R` in RStudio to get the admixture proportions plot. 
```
K = 2

k2_angsd_not <- read.table("angsd_admix_notrans_it2000.admix.2.Q")

bamlist=read.table("bam_list_all.txt")
```
Plot: `sin_plot_angsd_admix_notrans_it2000_admix_2_Q.png`

Run `pca.R` in RStudio to get the PCA for historical and contemporary individuals. 
```
cov_matrix_angsd <- as.matrix(read.table("angsd_notrans_snps_pca_it2000.cov"))

bamlist=read.table("bam_list_all.txt")
```
Plot: `sin_plot_angsd_notrans_snps_pca_it2000_cov.png`

----

</details>


<details><summary>5. PCANGSD: PCA STATS</summary>

### 5. PCANGSD: PCA STATS

** Analyze results

--> Once you have run admixture and PCA, if you have individual outliers or evidence of inversions (a "three-stripe" pattern in the PCA) you may want to revisit step #3, removing outlier individuals and/or chromosomes containing inversions (identifiable by running separate PCAs for each chromosome). WinPCA (step #6, still in development) can also help to pinpoint inverted regions.

Copy the R script `pca.R`.
```
cp /archive/carpenterlab/pire/pire_lethrinus_variegatus_lcwgs/ANGSD_Lva/pca_subset_k2.R ./pca_it2000_k2.R
```

Run `pca.R` in RStudio to get the PCA for historical and contemporary individuals. 
```
cov_matrix_angsd <- as.matrix(read.table("angsd_notrans_snps_it2000_pca.cov"))

bamlist=read.table("bam_list_all.txt")
```
Plot: `sin_plot_angsd_notrans_snps_it2000_pca_cov_k2.png`



</details>


<details><summary>5. (Optional) Running PCANGSD for a Selection Scan</summary>

### 5. (Optional) Running PCANGSD for a Selection Scan

If the PCA identifies the historical and contemporary samples as two separate clusters along PC1, you can use PCANGSD to perform a selection scan.

Copy.
```
cp pcangsd_selection.sbatch pcangsd_selection_it2000.sbatch
```

Edit.
```
crun pcangsd -b angsd_depth1_15_notrans_snplist.beagle.gz --it 2000 --maf 0.001 --threads 16 --out angsd_notrans_snps_it2000_selection --selection --sites_save
```

Run.
```
sbatch pcangsd_selection_it2000.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
Job ID: 10706720
2/26/25 @ 00:23 PST

Check output file.
```
less pcangsd_selection-10706720.out

PCAngsd converged.
Saved covariance matrix as angsd_notrans_snps_it2000_selection.cov

Performing selection scan (FastPCA) for 1 PCs.
Saved test statistics as angsd_notrans_snps_it2000_selection.selection

Creating boolean vector of sites surviving filters.
Saved boolean vector of sites kept after filtering as angsd_notrans_snps_it2000_selection.sites
```

----

**DEPRECATED: wrongle beagle.gz

5.2 `pcangsd_selection_it2000.sbatch`

Copy the `pcangsd_selection.sbatch` script from ANGSD_wahab and rename to `pcangsd_selection_it2000.sbatch` to indicate a file with 2000 iterations.
```
cp /archive/carpenterlab/pire/pire_lcwgs_data_processing/scripts/ANGSD_wahab/pcangsd_selection.sbatch ./pcangsd_selection_it2000.sbatch
```

Edit the `pcangsd_selection_it2000.sbatch` script to run the selection scan according to your dataset.
- Define the input file (`-b`) according to your dataset: `-b angsd_depth1_15_notrans.beagle.gz` 
- Define the output file naming format according to your dataset: `–out angsd_notrans_snps_selection_it2000` 
- Define the number of iterations according to your dataset. Set to 2000: `--it 2000`
- Make sure that the arguments `--selection --sites_save` are at the end of the crun command. 
```
nano pcangsd_selection_it2000.sbatch

crun pcangsd -b angsd_depth1_15_notrans.beagle.gz --it 2000 --maf 0.001 --threads 16 --out angsd_notrans_snps_selection_it2000 --selection --sites_save
```

Run `pcangsd_selection_it2000.sbatch` and specify the output directory.
```
sbatch pcangsd_selection_it2000.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
Job ID: 4262476
2/6/25 @ 10:33 PST

Check output file.
```
less pcangsd_selection-4262476.out

PCAngsd converged.
Saved covariance matrix as angsd_notrans_snps_selection_it2000.cov

Performing selection scan (FastPCA) for 1 PCs.
Saved test statistics as angsd_notrans_snps_selection_it2000.selection

Creating boolean vector of sites surviving filters.
Saved boolean vector of sites kept after filtering as angsd_notrans_snps_selection_it2000.sites
```

After running `pcangsd_selection_it500_noinv_subset.sbatch`, analyze the output files `angsd_notrans_snps_selection_it500_noinv_subset.selection`, `global_snp_list_depth1_15_notrans.regions`, and `angsd_notrans_snps_selection_it500_noinv_subset.sites` with the script `pcangsd_selection_plot_v2.R`. This can be done on [ODU OnDemand RStudio](https://ondemand.wahab.hpc.odu.edu/), or these output files and script can be downloaded and run locally. This script will generate a Manhattan plot and look at SNPs potentially under selection. 

Copy the R script `pcangsd_selection_plot_v2.R` from ANGSD_wahab.
```
cp /archive/carpenterlab/pire/pire_lcwgs_data_processing/scripts/ANGSD_wahab/pcangsd_selection_plot_v2.R ./
```





</details>


<details><summary>6. (Optional) Running winPCA to detect chromosome inversions (still in testing on Wahab)</summary>

### 6. (Optional) Running winPCA to detect chromosome inversions (still in testing on Wahab)

Make sure to install any Python packagedependencies needed for winPCA. 
```
mamba install numpy pandas numba scikit-allel plotly
```

Run salloc. Unlike sbatch, which submits a batch job script for later execution, salloc allocates resources immediately and starts an interactive shell session within the allocation. This is useful for testing, debugging, or running commands interactively on a compute node. 

```
salloc
```
Make a list of unique chromosome names (or identifiers) from the beagle file. Save this to a file named ncbi_chromnames.
```
gunzip -c angsd_depth_1_15_notrans.beagle.gz | ‘ awk { print $1 } ‘ | cut -c 1-11 | uniq > ncbi_chromnames
#extracts unique chromosome names (or identifiers) from the beagle file by printing the first field of the file (chromosome name), the first 11 characters of that field, and prints it to ncbi_chromnames file
```

Create a new beagle.gz file with the inversions using sed command to make the format compliant with running winPCA. Make sure to use the original beagle.gz file that does include inversions (angsd_depth_1_15_notrans.beagle.gz). Instead of our chromosome names being like NC_043745.1_651, they should be listed as chr1_SNPmarker#. In Excel, paste unique chromosome names into one column, and a list of the necessary chromosome names (chr1, chr2, chr3 …) in another column. This is needed for your sed file. Copy these two columns into a new file in the command line named sedfile. 
```
vi sedfile 
#Make sure to paste your two columns

gunzip - c angsd_depth_1_15_notrans.beagle.gz  | sed -f sedfile > angsd_depth_1_15_notrans_renamed.beagle.gz
#compresses a .gz file, applies sed transformations, and creates a new .beagle file with the modifications.

gunzip -c angsd_depth1_15_notrans_renamed.beagle.gz | less
#view format of new beagle file to check that it is the same as the format used for winPCA.
```

Try running winPCA on the fourth chromosome since we know this chromosome has inversions. 
```
module load ngsTools/2024

crun.ngsTools winpca pca angsd_depth_1_15_notrans_renamed.beagle.gz chr4:1-27169852 chr4
#Chr4:27169852 is chromosome name and size
#1- is the size of the windows analysis 
```

</details>


<details><summary>7. Generating Site Allele Frequencies</summary>

### 7. Generating Site Allele Frequencies

Make two bam lists: one with only Albatross individuals (`APnd`) and one with only contemporary individuals (`CPnd`). If necessary, adjust these to use the subsetted bam list that excludes outlier individuals. 

```
grep "CPnd" bam_list_all.txt > bam_list_all_CPnd.txt

grep "APnd" bam_list_all.txt > bam_list_all_APnd.txt 
```

Copy the `saf_beagle_maf.sbatch` script from ANGSD_wahab. 
```
cp /archive/carpenterlab/pire/pire_hypoatherina_temminckii_lcwgs/ANGSD_Hte/saf_beagle_maf_*.sbatch ./

cp saf_beagle_maf_APnd.sbatch saf_beagle_maf.sbatch
```

**Albatross
Edit the Albatross `saf_beagle_maf_APnd.sbatch` script to fit your data.
- Change the input bam list (`-b`) to the historical .bam list: `-b bam_list_all_APnd.txt`
- Change the ancestral state (`-anc`) to the GenErode reference genome since we don't know the ancestral states: `-anc /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \`
- Change the reference genome (`-ref`) to the GenErode reference genome: `-ref /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \`
- Change the output (`-out`) to indicate historical sites: `-out APnd_sites_notrans`
```
# Albatross
nano saf_beagle_maf_APnd.sbatch

crun angsd \
        -b bam_list_all_APnd.txt \
        -anc /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
        -ref /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
        -out APnd_sites_notrans \
		-doSaf 1 -noTrans 1 -GL 1 -doGlf 2 -doMaf 1 -doMajorMinor 3 -doCounts 1 -doDepth 1 -dumpCounts 1 -P 8 \
        -sites global_snp_list_depth1_15_notrans.txt -rf global_snp_list_depth1_15_notrans.chrs
```

Run `saf_beagle_maf_APnd.sbatch` and specify the output directory.
```
sbatch saf_beagle_maf_APnd.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10706723
2/26/25 @ 00:37

Check output.
```
less angsd_saf-10706723.out

Total number of sites analyzed: 9901420
Number of sites retained after filtering: 2106
```

**Contemporary
Edit the Contemporary `saf_beagle_maf_CPnd.sbatch` script to fit your data.
- Change the input bam list (`-b`) to the contemporary .bam list: `-b bam_list_all_CPnd.txt`
- Change the ancestral state (`-anc`) to the GenErode reference genome since we don't know the ancestral states: `-anc /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \`
- Change the reference genome (`-ref`) to the GenErode reference genome: `-ref /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \`
- Change the output (`-out`) to indicate contemporary sites: `-out CPnd_sites_notrans`
```
crun angsd \
        -b bam_list_all_CPnd.txt \
        -anc /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
        -ref /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
        -out CPnd_sites_notrans \
		-doSaf 1 -noTrans 1 -GL 1 -doGlf 2 -doMaf 1 -doMajorMinor 3 -doCounts 1 -doDepth 1 -dumpCounts 1 -P 8 \
        -sites global_snp_list_depth1_15_notrans.txt -rf global_snp_list_depth1_15_notrans.chrs
```

Run `saf_beagle_maf_CPnd.sbatch` and specify the output directory.
```
sbatch saf_beagle_maf_CPnd.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10707049
2/26/25 @ 08:52

Check output.
```
less 


```


Edit the **All** `saf_beagle_maf.sbatch` script to fit your data.
- Change the input bam list (`-b`) to the all .bam list: `-b bam_list_all.txt`
- Change the ancestral state (`-anc`) to the GenErode reference genome since we don't know the ancestral states: `-anc /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \`
- Change the reference genome (`-ref`) to the GenErode reference genome: `-ref /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \`
- Change the output (`-out`) to indicate all sites: `-out all_sites_notrans`
- Make sure the `-sites` for the SNP list is set correctly: `-sites global_snp_list_depth1_15_notrans.txt`
- Make sure the right chromosomes (`-rf`) is set correctly: `-rf global_snp_list_depth1_15_notrans.chrs`
```
crun angsd \
        -b bam_list_all.txt \
        -anc /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
        -ref /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta \
        -out all_sites_notrans \
		-doSaf 1 -noTrans 1 -GL 1 -doGlf 2 -doMaf 1 -doMajorMinor 3 -doCounts 1 -doDepth 1 -dumpCounts 1 -P 8 \
        -sites global_snp_list_depth1_15_notrans.txt -rf global_snp_list_depth1_15_notrans.chrs
```

Run `saf_beagle_maf.sbatch` and specify the output directory.
```
sbatch saf_beagle_maf.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 
3/8/25 @  PST

Check output file.
```
less 


```

Copy the script `concat_pos_gz_files.sbatch` to concatenate the files, remove duplicates, preserve header. 
```
cp ../../pire_corythoichthys_haematopterus_lcwgs/ANGSD_Cha/concat_pos_gz_files.sbatch ./
```

Run script. 
```
bash concat_pos_gz_files.sbatch APnd_sites_notrans.pos.gz CPnd_sites_notrans.pos.gz combined_sites_notrans.pos.gz
```


</details>


<details><summary>8. Calculating genome-wide and windowed FST</summary>

### 8. Calculating genome-wide and windowed FST

**Genome-wide Fst

Copy the `fst.sbatch` script from ANGSD_wahab. This script gets pairwise Fst estimates from angsd for each population/group pair.
```
cp /archive/carpenterlab/pire/pire_hypoatherina_temminckii_lcwgs/ANGSD_Hte/fst.sbatch ./
```

Edit the `fst.sbatch` script to fit your data. It uses the `*.saf.idx` output files from Step 7. Generating Allele Frequencies.
- Change the SAF directory (`SAFDIR`) to your ANGSD_Sin directory: `SAFDIR=${1:-/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin}`
- Change population 1 (`POP1`) to: `POP1=${4:-APnd_sites_notrans}`
- Change population 2 (`POP2`) to: `POP2=${5:-CPnd_sites_notrans}`
```
SAFDIR=${1:-/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin}
POP1=${4:-APnd_sites_notrans}
POP2=${5:-CPnd_sites_notrans}
```

Run `fst.sbatch`. The script specifies the output directory so you do not have to add the add the `/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin` argument.
```
sbatch fst.sbatch
```
JobID: 10707070
2/26/25 @ 10:04

Check output.
```
less angsd_fst-10707070.out

FST.Unweight[nObs:2106]:0.020231 Fst.Weight:0.090916
```


**Windowed Fst

Windowed Fst can be calculated in ANGSD based on the output of `fst.sbatch` using the `fst_window.sbatch` script. Currently the script uses a window size of 50kbp and a step size of 10kbp, though this can be adjusted (however note that this will reduce the number of SNPs per window and potentially increase the "noise" of Fst estimates).

Copy the `fst_window.sbatch` script from ANGSD_wahab. 
```
cp /archive/carpenterlab/pire/pire_hypoatherina_temminckii_lcwgs/ANGSD_Hte/fst_window.sbatch ./
```

Edit the `fst_window.sbatch` script to fit your data. It uses the `*.saf.idx` output files from Step 7. Generating Allele Frequencies. The difference between the scripts `fst.sbatch` and `fst_window.sbatch` is the windowed Fst argument: `-win 50000 -step 10000`.
- Change the SAF directory (`SAFDIR`) to your ANGSD_Sin directory: `SAFDIR=${1:-/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin}`
- Change population 1 (`POP1`) to: `POP1=${4:-APnd_sites_notrans}`
- Change population 2 (`POP2`) to: `POP2=${5:-CPnd_sites_notrans}`
```
SAFDIR=${1:-/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin}
POP1=${4:-APnd_sites_notrans}
POP2=${5:-CPnd_sites_notrans}

crun.angsd realSFS fst stats2 $POP1'_'$POP2'.alpha_beta.fst.idx' -win 50000 -step 10000 > $POP1'_'$POP2'.window_fst.txt'
```

Run `fst_window.sbatch`. The script specifies the output directory so you do not have to add the add the `/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin` argument.
```
sbatch fst_window.sbatch
```
JobID: 10707087
2/26/25 @ 10:30

Check output.
```
less angsd_fst_window-10707087.out
```
Window sizes are too large. Consider reducing window size and rerunning. 


</details>

<details><summary>9. Generate site frequency spectra for each site/era</summary>

### 9. Generate site frequency spectra for each site/era

Generate a folded site frequency spectrum (SFS) for each population because we did not have a known ancestral state genome. The `angsd_sfs.sbatch` script needs to be run for each population. It uses the `.saf.idx` input files generated in the last step to create an `.sfs` file for each population. These `.sfs` files will be used as an input in the next step to calculate per-site thetas using the `saf2theta` command and the `angsd_theta.sbatch` scripts.

** Albatross
Copy & rename the `angsd_sfs.sbatch` script to fit your Albatross data. 
```
cp /archive/carpenterlab/pire/pire_hypoatherina_temminckii_lcwgs/ANGSD_Hte/angsd_sfs_apnd_notrans.sbatch ./angsd_sfs_APnd.sbatch
```

Edit the `angsd_sfs_APnd.sbatch` script to fit the data. 
- Add the Albatross `.saf.idx` input file after the `realSFS` command: `APnd_sites_notrans.saf.idx`
```
crun.angsd realSFS APnd_sites_notrans.saf.idx -P 8 -fold 1 > APnd_sites_notrans.sfs
```

Run & specify outdir. 
```
sbatch angsd_sfs_APnd.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10707088
2/26/25 @ 10:34

Check output.
```
less

likelihood: -668.057795
```

** Contemporary

Copy & rename the `angsd_sfs.sbatch` script to fit your Contemporary data. 
```
cp /archive/carpenterlab/pire/pire_hypoatherina_temminckii_lcwgs/ANGSD_Hte/angsd_sfs_cpnd_notrans.sbatch ./angsd_sfs_CPnd.sbatch
```

Edit `angsd_sfs_CPnd.sbatch` script to fit the data.
- Add the Contemporary `.saf.idx` input file after the `realSFS` command: `CPnd_sites_notrans.saf.idx`
```
crun.angsd realSFS CPnd_sites_notrans.saf.idx -P 8 -fold 1 > CPnd_sites_notrans.sfs
```

Run & specify outdir. 
```
sbatch angsd_sfs_CPnd.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10707089
2/26/25 @ 10:39

Check output.
```
less angsd_sfs-10707089.out

likelihood: -2807.178790
```

</details>


<details><summary>10. Calculate per-site thetas</summary>

### 10. Calculate per-site thetas

Calculate per-site thetas using the `saf2theta` command and the `angsd_theta.sbatch` scripts.

**Albatross
Input files.
```
APnd_sites_notrans_subset.saf.idx
APnd_sites_notrans_subset.sfs  
```

Copy and rename the `angsd_theta*.sbatch` script to fit your Albatross data.
```
cp /archive/carpenterlab/pire/pire_hypoatherina_temminckii_lcwgs/ANGSD_Hte/angsd_theta_apnd_notrans.sbatch ./angsd_theta_APnd.sbatch
```

Edit the Albatross `angsd_theta_APnd.sbatch` script. 
- Add the Albatross `.saf.idx` file after the `saf2theta` command: `APnd_sites_notrans.saf.idx`
- Add the Albatross `sfs` file after the `-sfs` prompt: `APnd_sites_notrans.sfs` 
- Edit the `-outname` to reflect your data: `APnd_sites_notrans`
```
crun.angsd realSFS saf2theta APnd_sites_notrans.saf.idx -sfs APnd_sites_notrans.sfs -fold 1 -P 8 -outname APnd_sites_notrans
```

Run the Albatross `angsd_theta_APnd.sbatch` script and specify the output directory.
```
sbatch angsd_theta_APnd.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10707090
2/26/25 @ 10:45

Check output.
```
less angsd_theta-10707090.out

Output filenames:
                ->"APnd_sites_notrans.thetas.gz"
                ->"APnd_sites_notrans.thetas.idx"
```

**Contemporary
Input files.
```
CPnd_sites_notrans_subset.saf.idx
CPnd_notrans_subset.sfs
```

Copy and rename the `angsd_theta*.sbatch` script to fit your Contemporary data. 
```
cp /archive/carpenterlab/pire/pire_hypoatherina_temminckii_lcwgs/ANGSD_Hte/angsd_theta_cpnd_notrans.sbatch ./angsd_theta_CPnd.sbatch
```

Edit the Contemporary `angsd_theta_CPnd.sbatch` script. 
- Add the Contemporary `.saf.idx` file after the `saf2theta` command: `CPnd_sites_notrans.saf.idx`
- Add the Contemporary `sfs` file after the `-sfs` prompt: `CPnd_notrans.sfs` 
- Edit the `-outname` to reflect your data: `CPnd_notrans`
```
crun.angsd realSFS saf2theta CPnd_sites_notrans.saf.idx -sfs CPnd_sites_notrans.sfs -fold 1 -P 8 -outname CPnd_sites_notrans
```

Run the Contemporary `angsd_theta_CPnd.sbatch` script and specify the output directory.
```
sbatch angsd_theta_CPnd.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10707091
2/26/25 @ 10:51

Check output.
```
less angsd_theta-10707091.out

Output filenames:
                ->"CPnd_sites_notrans.thetas.gz"
                ->"CPnd_sites_notrans.thetas.idx"
```

</details>


<details><summary>11. Calculate neutrality test statistics</summary>

### 11. Calculate neutrality test statistics

Calculate neutrality test statistics using the `do_stat` command with the `angsd_thetastat.sbatch` script. This script needs to be run for each population. It uses the `.thetas.idx` files generated in the last step. The output `.thetas.idx.pestPG` file is used for statistical analysis in the `geneticdiversity.R` script. Since we are using a folded SFS (unknown ancestral state), we are able to generate Watterson's theta (thetaW), nucleotide diversity (thetaD), and Tajima's D.

**Albatross

Copy and rename the `angsd_thetastat*.sbatch` script. 
```
cp /archive/carpenterlab/pire/pire_hypoatherina_temminckii_lcwgs/ANGSD_Hte/angsd_thetastat_apnd_notrans.sbatch ./angsd_thetastat_APnd.sbatch
```

Edit the Albatross `angsd_thetastat_APnd.sbatch` script. 
- Add the Albatross `.thetas.idx` file after the `do_stat` command: `APnd_sites_notrans.thetas.idx`
```
crun.angsd thetaStat do_stat APnd_sites_notrans.thetas.idx
```

Run the Albatross `angsd_thetastat_APnd.sbatch` script and specify the output directory.
```
sbatch angsd_thetastat_APnd.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10707092
2/26/25 @ 10:56

Check output.
```
less angsd_theta-10707092.out

Dumping file: "APnd_sites_notrans.thetas.idx.pestPG"
```

**Contemporary

Copy and rename the `angsd_thetastat*.sbatch` script. 
```
cp /archive/carpenterlab/pire/pire_hypoatherina_temminckii_lcwgs/ANGSD_Hte/angsd_thetastat_cpnd_notrans.sbatch ./angsd_thetastat_CPnd.sbatch
```

Edit the Contemporary `angsd_thetastat_CPnd.sbatch` script. 
- Add the Contemporary `.thetas.idx` file after the `do_stat` command: `CPnd_sites_notrans.thetas.idx`
```
crun.angsd thetaStat do_stat CPnd_sites_notrans.thetas.idx
```

Run the Contemporary `angsd_thetastat_CPnd.sbatch` script and specify the output directory.
```
sbatch angsd_thetastat_CPnd.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/ANGSD_Sin
```
JobID: 10707093
2/26/25 @ 10:57

Check output.
```
less angsd_theta-10707093.out

Dumping file: "CPnd_sites_notrans.thetas.idx.pestPG"
```

**STOPPED HERE

</details>




# Statistical Analysis in R


<details><summary>13. Calculate Effective Population Size</summary>

### 13. Calculate Effective Population Size

Estimating effective population size (Ne) using Ne_estimation.R and Ne_estimation_neutral.R. Using the .mafs.gz outputs from the "saf_beagle_maf.sbatch" ANGSD script. Code developed from Jorde & Ryman 2007 and the NeEstimator manual v.2.1. Ne_estimation.R is used to generate Ne estimates for the adapted CMH and adapted Chi-squared selection scan tests. Ne_estimation_neutral.R is used to generate Ne estimates from the 1.3 million neutral SNPs. These estimates are reported in our manuscript.

Copy script from Cha.
```
cp /archive/carpenterlab/pire/pire_lethrinus_variegatus_lcwgs/ANGSD_Lva/Ne_estimation_subset.R ./
```

Analysis.
```
# MAFS (Minor Allele Frequencies)
apnd_mafs <- fread("APnd_sites_notrans.mafs.gz", header=TRUE)
cpnd_mafs <- fread("CPnd_sites_notrans.mafs.gz", header=TRUE)

all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, 112)] 


# Ne @ t0 = 
print(boot_pnd$t0)

# 95% Confidence Interval: 
boot.ci(boot_pnd, type='perc') 

# Bias: 
bias <- boot_pnd$t0 - mean(boot_pnd$t)
print(bias)

# Standard Error: 
se <- sqrt(var(boot_pnd$t))
print(se)
```


</details>


### 14. Change in Genetic Diversity


Analyzing changes in genetic diversity: Watterson's theta, nucleotide diversity (pi), and Tajima's D using the geneticdiversity.R and geneticdiversity_neutral.R scripts.
Using the .thetas.idx.pestPG outputs from ANGSD. Watterson's theta and nucleotide diversity were originally plotted against sequencing depth (mean depth per individual) to evaluate any depth based correlations that may be biasing results. This analysis identified that genetic diversity was sensitive to sequencing depth below 3x or above 6x (Figures S1-S2); we therefore restricted analyses on genetic diversity metrics to the 2,291 contigs with 3-6x depth. The following statistical analyses for all three metrics were run on this 3-6x depth range (452,496 SNPs).

Copy script.
```
cp /archive/carpenterlab/pire/pire_corythoichthys_haematopterus_lcwgs/ANGSD_Cha/geneticdiversity.R ./

apnd_thetas_notrans <- read_table("APnd_sites_notrans.thetas.idx.pestPG")
cpnd_thetas_notrans <- read_table("CPnd_sites_notrans.thetas.idx.pestPG")

angsd_depth_notrans <- read_table("combined_sites_notrans.pos.gz")
```

</details>
