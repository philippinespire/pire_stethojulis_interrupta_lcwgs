#### INSTRUCTIONS ####

# Some scripts for handling the output from ATLAS task=theta.
# It assumes windowed theta, will probably have to modify if genome-wide theta is calculated.
# It visualizes theta downsampled by depth.
# This script (visualize_theta_downsamp.R) should be run in the scripts directory. 
# The Spp_theta_data_downsamp.rds file in the plots directory is the input file.
# The Spp_theta_data_downsamp.rds file was created by wrangle_theta_downsamp.R
# This script can be run through the RStudio Server on ODU RCC OnDemand.
# https://ondemand.wahab.hpc.odu.edu/
# Alternatively this can be run on your personal computer by downloading the Spp_theta_data_downsamp.rds file.

#### INITIALIZE ####
# load required package (tidyverse)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### PACKAGES ####
packages_used <- 
  c("tidyverse",
    "dplyr",
    "Cairo"
  )

options(bitmapType = "cairo")  # Set Cairo as the default graphics device

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

# specify output directory path for plots
outDir = ""
# if the outDir is not yet created this will create it. 
if (!dir.exists(outDir)) {
  dir.create(outDir)
}


#### READ IN THETA DATA DOWNSAMP ####
# define the inFile pattern
inFile = str_c("../out/",
                spp_code,
                "_theta_data_downsamp",
                ".rds") #visualize_theta_downsamp.R depends on this path and name

# read in your species' data created from the wrangle_theta_downsamp.R script
theta_data_downsamp <- 
  read_rds(file = inFile)

#### FILTER DOWNSAMP DATA ####
# filter to samples with depth higher than a certain value and pivot/group by individual.
# the default was 3, but you may have to change this for other species. 
# adjust filter depth if necessary.
fltr_d1_depth = 0.05

theta_data_downsamp %>% 
  filter(d1_depth > fltr_d1_depth) %>% 
  pivot_longer(-c(ind, Era),
               names_to = c("Category",".value"), 
               names_sep = "_") %>%
  group_by(ind) -> theta_data_downsamp

# Set an upper threshold for theta values
theta_threshold <- 1.0

# Filter out the outlier from the data
theta_data_downsamp <- theta_data_downsamp %>%
  filter(theta < theta_threshold)

#### VISUALIZE DOWNSAMPLED DATA ####
# plot individual downsampling curves
plot_downsample <- 
  ggplot(theta_data_downsamp,aes(
    x=depth, 
    y=theta, 
    color=Era
  )) +
  labs(
    x="Average Depth",
    y="Theta",
    title = paste0("Sphyraena obtusata: Downsampling d1_depth > ",fltr_d1_depth) 
  ) +
  theme_bw() +
  scale_x_continuous(trans='log10') +
  geom_point(position=position_dodge(width=0.1)) +
  geom_line(aes(group=ind),position=position_dodge(width=0.1))
print(plot_downsample)

# outFile pattern
outFile_plot_downsample <- paste0(outDir, "/", spp_code, "_plot_downsample_d1depth_", fltr_d1_depth,".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_downsample, plot = plot_downsample, width = 9, height = 6)
