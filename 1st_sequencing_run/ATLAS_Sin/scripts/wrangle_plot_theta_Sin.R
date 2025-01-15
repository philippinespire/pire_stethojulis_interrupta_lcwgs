# Some scripts for handling the output from ATLAS task=theta.
# It assumes windowed theta, will probably have to modify if genome-wide theta is calculated.
# It creates plots of theta and depth. 
# Plots will be automatically saved as .png to a new ../plots directory.
# The ATLAS theta output files (*theta.txt.gz) should be in the theta directory within the species' ATLAS directory (ATLAS_Spp).
# This script (wrangle_plot_theta_template.R) should be run in the theta directory with the ATLAS theta output files. 
# These *theta.txt.gz files will be the input files for this script. 
# This script can be run through the RStudio Server on ODU RCC OnDemand.
# https://ondemand.wahab.hpc.odu.edu/
# Alternatively this can be run on your personal computer by downloading the *theta.txt.gz files.

#### INITIALIZE ####
# load required package (tidyverse)

library(tidyverse)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### USER DEFINED VARIABLES ####

# specify input directory path with the *theta.txt.gz files and this script 
# replace the string in quotes with the absolute path of your directory
inDir = "/archive/carpenterlab/pire/pire_lethrinus_variegatus_lcwgs/ATLAS_Lva/theta"

# specify output directory path for plots
outDir = "/archive/carpenterlab/pire/pire_lethrinus_variegatus_lcwgs/ATLAS_Lva/plots"
# if the outDir is not yet created this will create it. 
if (!dir.exists(outDir)) {
  dir.create(outDir)
}

# change your spp_code (e.g. Sob, Aen, Pbb)
spp_code="Lva"

# change your site_code (e.g. Pnd, Gal, Mvi)
site_code="Pnd"

# do not change the user-defined variables below
# era codes. do not change. 
era_A_code="A"
era_C_code="C"

# specify the input file pattern. do not change. 
inFilepattern = "*theta.txt.gz"

# era site pattern (e.g. APnd, CPal). do not change. 
era_site_pattern=paste0(era_A_code,site_code)

# individual pattern. do not change. 
ind_pattern <- paste0(spp_code, "\\s*(.*?)\\s*_theta")

#### READ IN THETA DATA ####

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
  theta_data$Era[fnum]<-ifelse(grepl(era_site_pattern,files[fnum]),"Albatross - ATLAS GERP recalibration","Contemporary - ATLAS GERP recalibration")
  theta_data$recal[fnum]<-"Recalibrated/SSL"
  theta_data$avg_theta[fnum]=mean(t$p1.0_thetaMLE)
  theta_data$avg_A[fnum]=mean(t$p1.0_piA)
  theta_data$avg_C[fnum]=mean(t$p1.0_piC)
  theta_data$avg_T[fnum]=mean(t$p1.0_piT)
  theta_data$avg_G[fnum]=mean(t$p1.0_piG)
  theta_data$avg_depth[fnum]=mean(t$p1.0_depth)
  theta_data$avg_missing[fnum]=mean(t$p1.0_fracMissing)
}

## Examine your data ##
# set the avg_theta filter to list Albatross files with an avg_theta less than alb_fltr_avg_theta.
alb_fltr_avg_theta <- 0.01
# identify the Albatross file names with an avg_theta less than alb_fltr_avg_theta.
alb_0.01_theta <- theta_data %>%
  filter(Era == 'Albatross - ATLAS GERP recalibration') %>%
  filter(avg_theta < alb_fltr_avg_theta) %>%
  mutate(file_name = basename(file))  # Extract the file name from the path

# Print the file names
cat("Albatross files with an avg_theta less than", alb_fltr_avg_theta)
alb_0.01_theta %>%
  pull(file_name) %>%
  cat(sep = "\n")

## Check files and logs for the files that had a low avg_theta

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
non_finite_files %>%
  pull(file_name) %>%
  cat(sep = "\n")

## Check files and logs for the files that had a non-finite avg_theta

# Filter out rows with non-finite avg_theta
theta_data <- theta_data %>%
  filter(is.finite(avg_theta))

# Average of avg_depth grouped by Era
theta_data %>%
  group_by(Era) %>%
  summarize(avg_avg_depth = mean(avg_depth, na.rm = TRUE)) %>%
  print()

# Average of avg_theta grouped by Era
theta_data %>%
  group_by(Era) %>%
  summarize(avg_avg_theta = mean(avg_theta, na.rm = TRUE)) %>%
  print()

# Calculate sample sizes by Era (after filtering)
era_sample_sizes <- theta_data %>%
  group_by(Era) %>%
  summarize(sample_size = n(), .groups = "drop")

# Create labels for the legend
era_labels <- era_sample_sizes %>%
  mutate(label = paste(Era, "( n =", sample_size, ")")) %>%
  pull(label)

# Map Era to the labels
names(era_labels) <- era_sample_sizes$Era

#### VISUALIZE THETA DATA ####
# boxplot of theta
plot_theta <- theta_data %>% 
  ggplot(aes(
    x = recal, 
    y = avg_theta, 
    fill = Era
    )) +
  labs(
    x="Recalibration",
    y="Theta",
    title = paste(spp_code,"- Theta")
  ) +
  theme_bw() +
  geom_boxplot() +
  scale_fill_manual(values = scales::hue_pal()(length(era_labels)), labels = era_labels)
print(plot_theta)

# outFile pattern
outFile_plot_theta <- paste0(outDir, "/", spp_code, "_plot_theta", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta, plot = plot_theta, width = 9, height = 6)

# boxplot of depth
plot_depth <- theta_data %>% 
  ggplot(aes(
    x=recal, 
    y=avg_depth, 
    fill=Era
    )) +
  labs(
    x = "Recalibration",
    y = "Depth",
    title = paste(spp_code,"- Depth")
    ) +
  theme_bw() +
  scale_y_continuous(trans='log10') +
  geom_boxplot() +
  scale_fill_manual(values = scales::hue_pal()(length(era_labels)), labels = era_labels)
print(plot_depth)

# outFile pattern
outFile_plot_depth <- paste0(outDir, "/", spp_code, "_plot_depth", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_depth, plot = plot_depth, width = 9, height = 6)

# theta vs depth
plot_theta_depth <- theta_data %>% 
  ggplot(aes(
    x=avg_depth, 
    y=avg_theta, 
    color=Era
    )) +
  labs(
    x = "Average Depth",
    y = "Theta",
    title = paste(spp_code,"- Read Number Variation")
    ) +
  theme_bw() +
  scale_x_continuous(trans='log10') +
  geom_point() +
  geom_smooth() +
  scale_color_manual(values = scales::hue_pal()(length(era_labels)), labels = era_labels)
print(plot_theta_depth)

# outFile pattern
outFile_plot_theta_depth <- paste0(outDir, "/", spp_code, "_plot_theta_depth", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta_depth, plot = plot_theta_depth, width = 9, height = 6)

#### THETA DATA FLTR AVG DEPTH ####
# If you don't want to apply a filter to remove low depth individuals move to section "READ IN DOWNSAMPLED DATA".
# View the plots that were created. 
# Consider filtering out individuals with a low average depth.
# Edit the user-defined low threshold (fltr_avg_depth) for filtering average depth based on the first set of plots. 
# If fltr_avg_depth is set to 0.10, then files with a depth less than 0.10 will be filtered out. 
fltr_avg_depth <- 0.07

# Filter rows with avg_depth < fltr_avg_depth
files_below_threshold <- theta_data %>%
  filter(avg_depth < fltr_avg_depth) %>%
  mutate(file_name = basename(file))  # Extract the file name from the path

# Total files with avg_depth < fltr_avg_depth
total_below_threshold <- nrow(files_below_threshold)

# Count files with "A" in the 4th character
a_count_below <- files_below_threshold %>%
  filter(substr(file_name, 4, 4) == "A") %>%
  nrow()

# Count files with "C" in the 4th character
c_count_below <- files_below_threshold %>%
  filter(substr(file_name, 4, 4) == "C") %>%
  nrow()

# Print the results
cat("Total number of files with avg_depth <", fltr_avg_depth, ":", total_below_threshold, "\n")
cat("Number of files with 'A' in the 4th character:", a_count_below, "\n")
cat("Number of files with 'C' in the 4th character:", c_count_below, "\n")

# Filter the dataframe based on avg_depth
theta_data_fltr_avg_depth <- theta_data %>%
  filter(avg_depth >= fltr_avg_depth)

# Average of avg_depth grouped by Era after depth filter
theta_data_fltr_avg_depth %>%
  group_by(Era) %>%
  summarize(avg_avg_depth = mean(avg_depth, na.rm = TRUE)) %>%
  print()

# Average of avg_theta grouped by Era after depth filter
theta_data_fltr_avg_depth %>%
  group_by(Era) %>%
  summarize(avg_avg_theta = mean(avg_theta, na.rm = TRUE)) %>%
  print()

# Calculate sample sizes by Era
era_sample_sizes <- theta_data_fltr_avg_depth %>%
  group_by(Era) %>%
  summarize(sample_size = n())

# Create labels for the legend
era_labels <- era_sample_sizes %>%
  mutate(label = paste(Era, "( n =", sample_size, ")")) %>%
  pull(label)

# Map Era to the labels
names(era_labels) <- era_sample_sizes$Era


#### VISUALIZE FLTR AVG DEPTH ####
# boxplot of theta
plot_theta_fltr_avg_depth <- theta_data_fltr_avg_depth %>% 
  ggplot(aes(
    x = recal, 
    y = avg_theta, 
    fill = Era
    )) +
  labs(
    x = "Recalibration",
    y = "Theta",
    title = paste(spp_code, "- Theta: fltr_avg_depth >= ", fltr_avg_depth)
  ) +
  theme_bw() +
  geom_boxplot() +
  scale_fill_manual(values = scales::hue_pal()(length(era_labels)), labels = era_labels)
print(plot_theta_fltr_avg_depth)

# outFile pattern
outFile_plot_theta_fltr_avg_depth <- paste0(outDir, "/", spp_code, "_plot_theta", "_fltr_avg_depth_", fltr_avg_depth, ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta_fltr_avg_depth, plot_theta_fltr_avg_depth, width = 9, height = 6)

# boxplot of depth
plot_depth_fltr_avg_depth <- theta_data_fltr_avg_depth %>% 
  ggplot(aes(
    x=recal, 
    y=avg_depth, 
    fill=Era
    )) +
  labs(
    x = "Recalibration",
    y = "Depth",
    title = paste(spp_code, "- Depth: fltr_avg_depth >= ", fltr_avg_depth)
  ) +
  theme_bw() +
  scale_y_continuous(trans='log10') +
  geom_boxplot() +
  scale_fill_manual(values = scales::hue_pal()(length(era_labels)), labels = era_labels) 
print(plot_depth_fltr_avg_depth)

# outFile pattern
outFile_plot_depth_fltr_avg_depth <- paste0(outDir, "/", spp_code, "_plot_depth", "_fltr_avg_depth_", fltr_avg_depth, ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_depth_fltr_avg_depth, plot = plot_depth_fltr_avg_depth, width = 9, height = 6)

# theta vs depth
plot_theta_depth_fltr_avg_depth <- theta_data_fltr_avg_depth %>% 
  ggplot(aes(
    x=avg_depth, 
    y=avg_theta, 
    color=Era
    )) +
  labs(
    x = "Average Depth",
    y = "Theta",
    title = paste(spp_code, "- Read Number Variation: fltr_avg_depth >= ", fltr_avg_depth)
  ) +
  theme_bw() +
  scale_x_continuous(trans='log10') +
  geom_point() +
  geom_smooth() + 
  scale_color_manual(values = scales::hue_pal()(length(era_labels)), labels = era_labels) 
print(plot_theta_depth_fltr_avg_depth)

# outFile pattern
outFile_plot_theta_depth_fltr_avg_depth <- paste0(outDir, "/", spp_code, "_plot_theta_depth", "_fltr_avg_depth_", fltr_avg_depth, ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta_depth_fltr_avg_depth, plot = plot_theta_depth_fltr_avg_depth, width = 9, height = 6)

#### READ IN DOWNSAMPLED DATA ####
# create a dataframe for downsampled theta
theta_data<-data.frame(matrix(ncol=16,nrow=length(files)))

names(theta_data)=c(
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

for(fnum in 1:length(files)) {
  t <- read.table(gzfile(files[fnum]), header=TRUE) # load file
  # apply function
  theta_data$ind[fnum]<-str_match(files[fnum], ind_pattern)[,2] 
  theta_data$Era[fnum]<-ifelse(grepl(era_site_pattern,files[fnum]),"Albatross - ATLAS recalibration","Contemporary - no recalibration")
  theta_data$d1_theta[fnum]=mean(t$p1.0_thetaMLE)
  theta_data$d05_theta[fnum]=mean(t$p0.5_thetaMLE)
  theta_data$d02_theta[fnum]=mean(t$p0.2_thetaMLE)
  theta_data$d01_theta[fnum]=mean(t$p0.1_thetaMLE)
  theta_data$d005_theta[fnum]=mean(t$p0.05_thetaMLE)
  theta_data$d002_theta[fnum]=mean(t$p0.02_thetaMLE)
  theta_data$d001_theta[fnum]=mean(t$p0.01_thetaMLE)
  theta_data$d1_depth[fnum]=mean(t$p1.0_depth)
  theta_data$d05_depth[fnum]=mean(t$p0.5_depth)
  theta_data$d02_depth[fnum]=mean(t$p0.2_depth)
  theta_data$d01_depth[fnum]=mean(t$p0.1_depth)
  theta_data$d005_depth[fnum]=mean(t$p0.05_depth)
  theta_data$d002_depth[fnum]=mean(t$p0.02_depth)
  theta_data$d001_depth[fnum]=mean(t$p0.01_depth)
}

# filter to samples with depth higher than a certain value and pivot/group by individual.
# the default was 3, but you may have to change this for other species. 
# adjust filter depth if necessary.
fltr_d1_depth = 0.3

theta_data %>% 
  filter(d1_depth > fltr_d1_depth) %>% 
  pivot_longer(-c(ind, Era),
               names_to = c("Category",".value"), 
               names_sep = "_") %>%
  group_by(ind) -> theta_downsamp_data


#### VISUALIZE DOWNSAMPLED DATA ####
# plot individual downsampling curves
plot_downsample <- 
  ggplot(theta_downsamp_data,aes(
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
