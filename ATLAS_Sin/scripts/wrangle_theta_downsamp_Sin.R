#### INSTRUCTIONS ####

# Some scripts for handling the output from ATLAS task=theta.
# It assumes windowed theta, will probably have to modify if genome-wide theta is calculated.
# It wrangles data for visualize_theta_downsamp.R to plot theta downsampled by depth. 
# The ATLAS theta output files (*theta.txt.gz) should be in the theta directory within the species' ATLAS directory (ATLAS_Spp).
# This script (wrangle_theta_downsamp.R) should be run in the scripts directory. 
# The *theta.txt.gz files in the theta directory will be the input files for this script. 
# This script can be run through the RStudio Server on ODU RCC OnDemand.
# https://ondemand.wahab.hpc.odu.edu/
# Alternatively this can be run on your personal computer by downloading the *theta.txt.gz files.

#### INITIALIZE ####
# load required package (tidyverse)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### PACKAGES ####
packages_used <- 
  c("tidyverse",
    "dplyr"
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

# library(tidyverse)
# library(dplyr)

#### USER DEFINED VARIABLES ####
# change your spp_code (e.g. Sob, Aen, Pbb)
spp_code="Spp"

# change your site_A_code to the 3 letter site code of the Albatross (historical) population (e.g. Pnd, Gal, Mvi)
site_A_code=""

# change your site_C_code to the 3 letter site code of the contemporary (modern) population (e.g. Pnd, Gal, Mvi)
site_C_code=""

# specify input directory path with the *theta.txt.gz files
# replace the string in quotes with the absolute path of your directory
inDir = ""

# If the 'out' directory does not exist, create it.
if (!dir.exists("../out/")) {
  dir.create("../out/")
}

# Create the outFile pattern
outFile = str_c("../out/",
                spp_code,
                "_theta_data_downsamp",
                ".rds") #visualize_theta_downsamp.R depends on this path and name


#### VARIABLES FROM USER INPUT  ####
# do not change the variables below. 
# they are made from the above user-defined variables.
# era codes. do not change. 
era_A_code="A"
era_C_code="C"

# era site pattern (e.g. APnd, CPal). do not change. 
era_A_site_pattern=paste0(era_A_code,site_A_code)
era_C_site_pattern=paste0(era_C_code,site_C_code)

# individual pattern. do not change. 
ind_pattern <- paste0(spp_code, "\\s*(.*?)\\s*_theta")

# specify the input file pattern. do not change. 
inFilepattern = "*theta.txt.gz"

#### READ IN DOWNSAMPLED DATA ####
# create a dataframe for downsampled theta

# get list of filenames
files <- list.files(path=inDir, pattern=inFilepattern, full.names=TRUE, recursive=FALSE)

theta_data_downsamp<-data.frame(matrix(ncol=16,nrow=length(files)))

names(theta_data_downsamp)=c(
  "ind",
  "Era",
  "d1_theta",
  "d05_theta",
  "d02_theta",
  "d01_theta",
  "d005_theta",
  "d002_theta",
  "d001_theta",
  "d1_depth",
  "d05_depth",
  "d02_depth",
  "d01_depth",
  "d005_depth",
  "d002_depth",
  "d001_depth"
)

for (fnum in 1:length(files)) {
  t <- read.table(gzfile(files[fnum]), header = TRUE)  # Load file
  # Apply function
  theta_data_downsamp$ind[fnum] <- str_match(files[fnum], ind_pattern)[, 2] 
  theta_data_downsamp$Era[fnum] <- ifelse(grepl(era_A_site_pattern, files[fnum]), 
                                          "Albatross - ATLAS recalibration", 
                                          "Contemporary - no recalibration")
  # Compute mean theta values, ensuring NA removal
  theta_data_downsamp$d1_theta[fnum]   <- mean(t$p1.0_thetaMLE, na.rm = TRUE)
  theta_data_downsamp$d05_theta[fnum]  <- mean(t$p0.5_thetaMLE, na.rm = TRUE)
  theta_data_downsamp$d02_theta[fnum]  <- mean(t$p0.2_thetaMLE, na.rm = TRUE)
  theta_data_downsamp$d01_theta[fnum]  <- mean(t$p0.1_thetaMLE, na.rm = TRUE)
  theta_data_downsamp$d005_theta[fnum] <- mean(t$p0.05_thetaMLE, na.rm = TRUE)
  theta_data_downsamp$d002_theta[fnum] <- mean(t$p0.02_thetaMLE, na.rm = TRUE)
  theta_data_downsamp$d001_theta[fnum] <- mean(t$p0.01_thetaMLE, na.rm = TRUE)
  # Compute mean depth values, ensuring NA removal
  theta_data_downsamp$d1_depth[fnum]   <- mean(t$p1.0_depth, na.rm = TRUE)
  theta_data_downsamp$d05_depth[fnum]  <- mean(t$p0.5_depth, na.rm = TRUE)
  theta_data_downsamp$d02_depth[fnum]  <- mean(t$p0.2_depth, na.rm = TRUE)
  theta_data_downsamp$d01_depth[fnum]  <- mean(t$p0.1_depth, na.rm = TRUE)
  theta_data_downsamp$d005_depth[fnum] <- mean(t$p0.05_depth, na.rm = TRUE)
  theta_data_downsamp$d002_depth[fnum] <- mean(t$p0.02_depth, na.rm = TRUE)
  theta_data_downsamp$d001_depth[fnum] <- mean(t$p0.01_depth, na.rm = TRUE)
}


#### DEPRECATED ####
# original format, which did not properly handle NAs
# for(fnum in 1:length(files)) {
#   t <- read.table(gzfile(files[fnum]), header=TRUE) # load file
#   # apply function
#   theta_data_downsamp$ind[fnum]<-str_match(files[fnum], ind_pattern)[,2] 
#   theta_data_downsamp$Era[fnum]<-ifelse(grepl(era_A_site_pattern,files[fnum]),"Albatross - ATLAS recalibration","Contemporary - no recalibration")
#   theta_data_downsamp$d1_theta[fnum]=mean(t$p1.0_thetaMLE)
#   theta_data_downsamp$d05_theta[fnum]=mean(t$p0.5_thetaMLE)
#   theta_data_downsamp$d02_theta[fnum]=mean(t$p0.2_thetaMLE)
#   theta_data_downsamp$d01_theta[fnum]=mean(t$p0.1_thetaMLE)
#   theta_data_downsamp$d005_theta[fnum]=mean(t$p0.05_thetaMLE)
#   theta_data_downsamp$d002_theta[fnum]=mean(t$p0.02_thetaMLE)
#   theta_data_downsamp$d001_theta[fnum]=mean(t$p0.01_thetaMLE)
#   theta_data_downsamp$d1_depth[fnum]=mean(t$p1.0_depth)
#   theta_data_downsamp$d05_depth[fnum]=mean(t$p0.5_depth)
#   theta_data_downsamp$d02_depth[fnum]=mean(t$p0.2_depth)
#   theta_data_downsamp$d01_depth[fnum]=mean(t$p0.1_depth)
#   theta_data_downsamp$d005_depth[fnum]=mean(t$p0.05_depth)
#   theta_data_downsamp$d002_depth[fnum]=mean(t$p0.02_depth)
#   theta_data_downsamp$d001_depth[fnum]=mean(t$p0.01_depth)
# }

#### WRITE THETA DATA DOWNSAMP ####

theta_data_downsamp %>%
  write_rds(file = outFile,
            compress = "gz")

