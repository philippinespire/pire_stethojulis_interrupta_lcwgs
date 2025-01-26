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
