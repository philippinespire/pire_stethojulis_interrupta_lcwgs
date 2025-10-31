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
    "lubridate"
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


#### READ IN DATA ####
# Read in allele frequency data

# MAFS (Minor Allele Frequencies)
apnd_mafs <- fread("APnd_sites_notrans_neutral_fdr.mafs.gz", header=TRUE) # 376 Neutral SNPs
cpnd_mafs <- fread("CPnd_sites_notrans_neutral_fdr.mafs.gz", header=TRUE) # 376 Neutral SNPs

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
# 146 SNPs remaining after minmaf

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

length(unique(all_mafs_001$nInd1))
# 1
length(unique(all_mafs_001$nInd2))
# 29

# GenTime as estimated by FishLife is 2.890225 based on genus-level estimate
GenTime = 2.890225

## Generations (gen) based on sampling years 
a_date <- as.Date("1909-03-24") # 3/24/1909
c_date <- as.Date("2021-11-05") # 11/5/2021

# Calculate exact number of years
years <- as.numeric(difftime(c_date, a_date, units = "days")) / 365.25  # use 365.25 for leap years
years <- round(years, 1)
years2 <- round(years/2,1)
years3 <- round(years/3,1)

Generations = years/GenTime
# 38.9589

# gen = number of generations
all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, Generations)] # 283.7109 w/ GenTime of 2.890225 years and Neutral SNPs. 100 for all SNPs.
all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, years)]       # 819.9884 w/ GenTime of 1 year
all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, years2)]      # 409.9942 w/ GenTime of 2 years
all_mafs_001[, jrNe2(freq1, freq2, nInd1, nInd2, years3)]      # 273.0867 w/ GenTime of 3 years (37.33)


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



################################
#### Calculate Ne @ GenTime #### 
################################
boot_pnd <- boot(data = all_mafs_001, statistic = jrNe2boot, R = 1000, gen = Generations) # GenTime = 2.890225 years

# Ne @ t0 = 283.7109 (SE = 48.1395) at GenTime = 2.890225 years
print(boot_pnd)
# original    bias    std. error
# t1* 283.7109 8.069247     48.1395

# 95% Confidence Interval: (217.0, 402.6) 
boot.ci(boot_pnd, type='perc') 

# Bias: -8.069247
bias <- boot_pnd$t0 - mean(boot_pnd$t)
print(bias)



################################
#### Calculate Ne @ YEARS_X #### 
################################
boot_pnd_year <- boot(data = all_mafs_001, statistic = jrNe2boot, R = 1000, gen = years) # GenTime = 1 year

# Ne @ t0 =  at GenTime = 1 year
print(boot_pnd_year)
# original    bias    std. error
# 

# 95% Confidence Interval: () 
boot.ci(boot_pnd_year, type='perc') 

# Bias: 
bias <- boot_pnd_year$t0 - mean(boot_pnd_year$t)
print(bias)
