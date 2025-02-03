#### INSTRUCTIONS ####

# Some scripts for handling the output from ATLAS task=theta.
# It assumes windowed theta, will probably have to modify if genome-wide theta is calculated.
# This script (wrangle_theta.R) should be run in the scripts directory. 
# The *theta.txt.gz files are the input files, which are in the theta directory.
# It wrangles data to create the dataframe theta_data.rds. 
# theta_data.rds can be used by visualize_theta.R to make plots & run stats on theta and depth.
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

# specify input directory path with the *theta.txt.gz files and this script 
# replace the string in quotes with the absolute path of your directory
inDir = ""

# # specify output directory path for plots
# outDir = ""
# # if the outDir is not yet created this will create it. 
# if (!dir.exists(outDir)) {
#   dir.create(outDir)
# }

# If the 'out' directory does not exist, create it.
if (!dir.exists("../out/")) {
  dir.create("../out/")
}

outFile = str_c("../out/",
                spp_code,
                "_theta_data",
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

# specify the input file pattern. do not change. 
inFilepattern = "*theta.txt.gz"


#### READ IN RAW THETA DATA ####

# get list of filenames
files <- list.files(path=inDir, pattern=inFilepattern, full.names=TRUE, recursive=FALSE)

# create a dataframe to hold your data
theta_data<-data.frame(matrix(ncol=10,nrow=length(files)))
names(theta_data)=c(
  "file",
  "Era",
  "recal",
  "avg_theta",
  "avg_A",
  "avg_C",
  "avg_T",
  "avg_G",
  "avg_depth",
  "avg_missing"
)

# populate dataframe with data
# note you may need to change the first argument to grepl() based on the site/naming conventions for your data
# you can potentially repeat this loop command if you have data in multiple folders
for(fnum in 1:length(files)) {
  t <- read.table(gzfile(files[fnum]), header=TRUE) # load file
  # apply function
  theta_data$file[fnum]<-files[fnum]
  theta_data$Era[fnum]<-ifelse(grepl(era_A_site_pattern,files[fnum]),"Albatross - ATLAS GERP recalibration","Contemporary - ATLAS GERP recalibration")
  theta_data$recal[fnum]<-"Recalibrated/SSL"
  theta_data$avg_theta[fnum] <- mean(t$p1.0_thetaMLE, na.rm = TRUE)
  theta_data$avg_A[fnum] <- mean(t$p1.0_piA, na.rm = TRUE)
  theta_data$avg_C[fnum] <- mean(t$p1.0_piC, na.rm = TRUE)
  theta_data$avg_T[fnum] <- mean(t$p1.0_piT, na.rm = TRUE)
  theta_data$avg_G[fnum] <- mean(t$p1.0_piG, na.rm = TRUE)
  theta_data$avg_depth[fnum] <- mean(t$p1.0_depth, na.rm = TRUE)
  theta_data$avg_missing[fnum] <- mean(t$p1.0_fracMissing, na.rm = TRUE)
}

#### DEPRECATED ####
# deprecated format that caused any individual with an NA in the dataframe to not be able to calculate a mean.
# for(fnum in 1:length(files)) {
#   t <- read.table(gzfile(files[fnum]), header=TRUE) # load file
#   # apply function
#   theta_data$file[fnum]<-files[fnum]
#   theta_data$Era[fnum]<-ifelse(grepl(era_A_site_pattern,files[fnum]),"Albatross - ATLAS GERP recalibration","Contemporary - ATLAS GERP recalibration")
#   theta_data$recal[fnum]<-"Recalibrated/SSL"
#   theta_data$avg_theta[fnum]=mean(t$p1.0_thetaMLE)
#   theta_data$avg_A[fnum]=mean(t$p1.0_piA)
#   theta_data$avg_C[fnum]=mean(t$p1.0_piC)
#   theta_data$avg_T[fnum]=mean(t$p1.0_piT)
#   theta_data$avg_G[fnum]=mean(t$p1.0_piG)
#   theta_data$avg_depth[fnum]=mean(t$p1.0_depth)
#   theta_data$avg_missing[fnum]=mean(t$p1.0_fracMissing)
# }

#### FILTER THETA DATA BY NAs ####

## Check files and logs for the files that had a non-finite avg_theta
# List file names with non-finite avg_theta
non_finite_files <- theta_data %>%
  filter(!is.finite(avg_theta)) %>%
  mutate(file_name = basename(file))  # Extract the file name from the path

# Count files with "A" in the 4th character
a_count <- non_finite_files %>%
  filter(substr(file_name, 4, 4) == "A") %>%
  nrow()

# Count files with "C" in the 4th character
c_count <- non_finite_files %>%
  filter(substr(file_name, 4, 4) == "C") %>%
  nrow()

# Total count of files with non-finite avg_theta
total_non_finite <- nrow(non_finite_files)

# Print the results
cat("Total number of files with non-finite avg_theta:", total_non_finite, "\n")
cat("Number of Albatross files:", a_count, "\n")
cat("Number of Conemporary files:", c_count, "\n")

# Print file names
cat("Files with a non-finite avg_theta:\n")
non_finite_files %>%
  pull(file_name) %>%
  cat(sep = "\n")

# Filter out rows with non-finite avg_theta
theta_data <- theta_data %>%
  filter(is.finite(avg_theta))


#### SUMMARY STATS: FILTERED THETA DATA (NAs) ####

# Calculate mean, standard deviation, and standard error of avg_theta and avg_depth by Era
theta_data_summary_rmna <- theta_data %>%  
  group_by(Era) %>%  
  summarise(
    avg_theta_mean = mean(avg_theta, na.rm = TRUE),  # Mean of avg_theta
    avg_theta_n = n(),                               # Sample size for avg_theta
    avg_theta_sd = sd(avg_theta, na.rm = TRUE),      # Standard deviation of avg_theta
    avg_theta_se = avg_theta_sd / sqrt(avg_theta_n), # Standard error of avg_theta
    avg_depth_mean = mean(avg_depth, na.rm = TRUE),  # Mean of avg_depth
    avg_depth_n = n(),                               # define sample size for avg_depth
    avg_depth_sd = sd(avg_depth, na.rm = TRUE),      # Standard deviation of avg_depth
    avg_depth_se = avg_depth_sd / sqrt(avg_depth_n), # Standard error of avg_depth
    .groups = "drop"  # Ensures the result is not grouped
  )

# View the result  
print(theta_data_summary_rmna)

# outFile pattern
outFile_theta_data_summary_rmna <- paste0("../out/",
                                          spp_code,
                                          "_table_theta_data_summary_rmna",
                                          ".csv") 

# Save table of avg_theta & avg_depth  w/ sample size
write.csv(theta_data_summary_rmna, 
          outFile_theta_data_summary_rmna, 
          row.names = FALSE)


#### FILTER THETA DATA BY OUTLIERS (3xSD) ####
# avg_theta
# Identify file names that have an avg_theta greater than 3 standard deviations above the mean  
theta_data_avg_theta_greater_3sd_outliers <- theta_data %>%  
  inner_join(theta_data_summary_rmna, by = "Era") %>%  
  filter(avg_theta > avg_theta_mean + 3 * avg_theta_sd) %>%  
  mutate(file_name = basename(file))  

# Print the file names of the avg_theta > 3sd outliers  
print(theta_data_avg_theta_greater_3sd_outliers$file_name) 

# Identify file names that have an avg_theta less than 3 standard deviations below the mean  
theta_data_avg_theta_less_3sd_outliers <- theta_data %>%  
  inner_join(theta_data_summary_rmna, by = "Era") %>%  
  filter(avg_theta < avg_theta_mean - 3 * avg_theta_sd) %>%  
  mutate(file_name = basename(file))  

# Print the file names of the avg_theta < 3sd outliers
print(theta_data_avg_theta_less_3_outliers$file_name)

#avg_depth
# Identify file names that have an avg_theta greater than 3 standard deviations above the mean  
theta_data_avg_depth_greater_3sd_outliers <- theta_data %>%  
  inner_join(theta_data_summary_rmna, by = "Era") %>%  
  filter(avg_depth > avg_depth_mean + 3 * avg_depth_sd) %>%  
  mutate(file_name = basename(file))  

# Print the file names of the avg_depth > 3sd outliers  
print(theta_data_avg_depth_greater_3sd_outliers$file_name) 

# Identify file names that have an avg_theta less than 3 standard deviations below the mean  
theta_data_avg_depth_less_3sd_outliers <- theta_data %>%  
  inner_join(theta_data_summary_rmna, by = "Era") %>%  
  filter(avg_depth < avg_depth_mean - 3 * avg_depth_sd) %>%  
  mutate(file_name = basename(file))  

# Print the file names of the avg_depth < 3sd outliers
print(theta_data_avg_depth_less_3_outliers$file_name)

# Combine all outlier dataframes into one with distinct file names
all_outliers <- bind_rows(
  theta_data_avg_theta_greater_3sd_outliers %>% select(file_name),
  theta_data_avg_theta_less_3sd_outliers %>% select(file_name),
  theta_data_avg_depth_greater_3sd_outliers %>% select(file_name),
  theta_data_avg_depth_less_3sd_outliers %>% select(file_name)
) %>% 
  distinct(file_name)

# Apply filter
# Filter theta_data to exclude rows with file names in the outliers list
theta_data <- theta_data %>% 
  mutate(file_name = basename(file)) %>% 
  filter(!file_name %in% all_outliers$file_name)


#### SUMMARY STATS: FILTERED THETA DATA (NAs & OUTLIERS) ####

# Compute averages of avg_depth and avg_theta and count sample sizes by Era after removal of NAs & outliers
theta_data_summary_rmna_rmout <- theta_data %>%  
  group_by(Era) %>%  
  summarise(
    avg_theta_mean = mean(avg_theta, na.rm = TRUE),  # Mean of avg_theta
    avg_theta_n = n(),                               # Sample size for avg_theta
    avg_theta_sd = sd(avg_theta, na.rm = TRUE),      # Standard deviation of avg_theta
    avg_theta_se = avg_theta_sd / sqrt(avg_theta_n), # Standard error of avg_theta
    avg_depth_mean = mean(avg_depth, na.rm = TRUE),  # Mean of avg_depth
    avg_depth_sd = sd(avg_depth, na.rm = TRUE),      # Standard deviation of avg_depth
    avg_depth_se = avg_depth_sd / sqrt(avg_theta_n), # Standard error of avg_depth
    .groups = "drop"  # Ensures the result is not grouped
  )

# Print the summary table
print(theta_data_summary_rmna_rmout)

# outFile pattern
outFile_theta_data_summary_rmna_rmout <- paste0("../out/",
                                                spp_code,
                                                "_table_theta_data_summary_rmna_rmout",
                                                ".csv") 

# Save table of avg_theta & avg_depth  w/ sample size
write.csv(theta_data_summary_rmna_rmout, 
          outFile_theta_data_summary_rmna_rmout, 
          row.names = FALSE)


#### WRITE FILTERED THETA DATA ####

theta_data %>%
  write_rds(file = outFile,
            compress = "gz")
