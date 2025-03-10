##Estimating Ne

#### INITIALIZE ####
# set working directory

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### PACKAGES ####
packages_used <- 
  c("tidyverse",
    "boot",
    "R.utils",
    "data.table",
    "Cairo"
  )

packages_to_install <- 
  packages_used[!packages_used %in% installed.packages()[,1]]

if (length(packages_to_install) > 0) {
  install.packages(packages_to_install, 
                   Ncpus = Sys.getenv("NUMBER_OF_PROCESSORS") - 1)
}

lapply(packages_used, 
       require, 
       character.only = TRUE)

options(bitmapType = "cairo")  # Set Cairo as the default graphics device

# install packages
# install.packages("tidyverse")
# install.packages("boot")
# install.packages("R.utils")
# install.packages("data.table")
# install.packages("Cairo")

# load libraries
# library(data.table)
# library(R.utils)
# library(boot)
# library(tidyverse)
# library(Cairo)

#### READ IN DATA ####
# Read in allele frequency data

# MAFS (Minor Allele Frequencies)
apnd_mafs <- fread("APnd_sites_notrans.mafs.gz", header=TRUE)
cpnd_mafs <- fread("CPnd_sites_notrans.mafs.gz", header=TRUE)

#### WRANGLE DATA ####
# Merge population comparisons
# Set Albatross to population 1
setnames(apnd_mafs, c("knownEM", 'nInd'), c("freq1", 'nInd1'))
# Set Contemporary to population 2
setnames(cpnd_mafs, c("knownEM", 'nInd'), c("freq2", 'nInd2'))

# merge by chromo & position & major & minor & ref & anc
all_mafs <- merge(apnd_mafs, cpnd_mafs, by = c("chromo", "position", "major", "minor", "ref", "anc"))
# makes sure the merged dataframe has the same number of observations

# remove NAs from freq columns
all_mafs <- all_mafs[!is.na(freq1) & !is.na(freq2)]

# Find where all populations (1 location, 2 populations) overlap with maf>0.001
# set minimum minor allele frequency filter. default is 0.001. 
minmaf <- 0.001

# filter by minmaf
all_mafs_001 <- subset(all_mafs, freq1 > minmaf & freq2 > minmaf)
# 189 SNPs remaining after minmaf

### Jorde & Ryman/NeEstimator approach
# Jorde & Ryman 2007

# Ne in # diploid individuals
# based on NeEstimator manual v2.1

jrNe2 <- function(maf1, maf2, n1, n2, gen){
  Fsnum <- (maf1-maf2)^2 + (1-maf1 - (1-maf2))^2 # the numerator, summing across the two alleles

  z <- (maf1+maf2)/2 # for the first allele
  z2 <- ((1-maf1)+(1-maf2))/2 # z for the 2nd allele
  Fsdenom <- z*(1-z) + z2*(1-z2) # the denominator of Fs, summing across the 2 alleles
  Fs <- sum(Fsnum)/sum(Fsdenom) # from NeEstimator calculations manual

  sl <- 2/(1/n1 + 1/n2) # harmonic mean sample size for each locus, in # individuals

  S <- length(maf1)*2/sum(2/sl) # harmonic mean sample size in # individuals, across loci and across both times. 2 alleles. Eq. 4.10 in NeEstimator v2.1 manual
  S2 <- length(maf2)*2/sum(2/n2) # harmonic mean sample size of 2nd sample in # individuals, across loci. all 2 alleles. See NeEstimator v2.1 below Eq. 4.13
  Fsprime <- (Fs*(1 - 1/(4*S)) - 1/S)/((1 + Fs/4)*(1 - 1/(2*S2))) # Eq. 4.13 in NeEstimator v2.1
  return(gen/(2*Fsprime)) # calculation of Ne in # diploid individuals
}

# Number of Albatross individuals 
length(unique(all_mafs_001$nInd1))
# 1
# Number of contemporary individuals
length(unique(all_mafs_001$nInd2))
# 30

# contemporary collected in 2021. albatross collected in 1909. So 112 years.
# GenTime as estimated by FishLife is 2.890225 based on family-level estimate
GenTime = 2.890225
Years = 112
Generations = Years/GenTime
# 38.751308

all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, Generations)] # 100.1814 w/ GenTime = 2.890225
all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, 112)] # 289.5467 w/ GenTime = 1 yr
all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, 56)] # 144.7734 w/ GenTime = 2 yr
all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, 37)] # 95.65383 w/ GenTime = 3 yr (37.33)
all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, 28)] # 72.38668 w/ GenTime = 4 yr

#Bootstrap over loci to get CIs

## Jorde & Ryman Ne estimator, for boot() to use

jrNe2boot <- function(data, gen, indices){
  maf1 <- data$freq1[indices]
  maf2 <- data$freq2[indices]
  n1 <- data$nInd1[indices]
  n2 <- data$nInd2[indices]

  Fsnum <- (maf1-maf2)^2 + (1-maf1 - (1-maf2))^2 # the numerator, summing across the two alleles

  z <- (maf1+maf2)/2 # for the first allele
  z2 <- ((1-maf1)+(1-maf2))/2 # z for the 2nd allele
  Fsdenom <- z*(1-z) + z2*(1-z2) # the denominator of Fs, summing across the 2 alleles
  Fs <- sum(Fsnum)/sum(Fsdenom) # from NeEstimator calculations manual

  sl <- 2/(1/n1 + 1/n2) # harmonic mean sample size for each locus, in # individuals

  S <- length(maf1)*2/sum(2/sl) # harmonic mean sample size in # individuals, across loci and across both times. 2 alleles. Eq. 4.10 in NeEstimator v2.1 manual
  S2 <- length(maf2)*2/sum(2/n2) # harmonic mean sample size of 2nd sample in # individuals, across loci. all 2 alleles. See NeEstimator v2.1 below Eq. 4.13
  Fsprime <- (Fs*(1 - 1/(4*S)) - 1/S)/((1 + Fs/4)*(1 - 1/(2*S2))) # Eq. 4.13 in NeEstimator v2.1
  Ne <- gen/(2*Fsprime)
  if(Ne < 0) Ne <- Inf
  return(Ne) # calculation of Ne in # diploid individuals
}

# how to find original t1* bias, std error
boot_pnd <- boot(data = all_mafs_001, statistic = jrNe2boot, R = 1000, gen = Generations) # 100.1814 w/ GenTime = 2.890225
boot_pnd <- boot(data = all_mafs_001, statistic = jrNe2boot, R = 1000, gen = 112) # GenTime = 1
boot_pnd <- boot(data = all_mafs_001, statistic = jrNe2boot, R = 1000, gen = 28) # GenTime = 4
boot_pnd <- boot(data = all_mafs_001, statistic = jrNe2boot, R = 1000, gen = 37) # GenTime = 3

# Ne @ t0 = 100.1814 w/ GenTime = 2.890225
print(boot_pnd$t0)

# 95% Confidence Interval: 76.7, 135.1 w/ GenTime = 2.890225
boot.ci(boot_pnd, type='perc') 

# Bias: -1.859551 w/ GenTime = 2.890225
bias <- boot_pnd$t0 - mean(boot_pnd$t)
print(bias)

# Standard Error: 15.56412 w/ GenTime = 2.890225
se <- sqrt(var(boot_pnd$t))
print(se)

