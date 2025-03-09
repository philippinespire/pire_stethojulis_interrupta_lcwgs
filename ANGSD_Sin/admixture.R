##PCAngsd Admixture Results##

#### INITIALIZE ####
# set working directory

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### PACKAGES ####
packages_used <- 
  c("Cairo",
    "devtools",
    "pophelper",
    "ggplot2"
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
# install.packages("devtools")
# install.packages("pophelper") #v.2.3.1
# devtools::install_github("royfrancis/pophelper")
# install.packages("Cairo")
# install.packages("ggplot2")

# load libraries
# library(devtools)
# library(pophelper) #v.2.3.1
# library(Cairo)
# library(ggplot2)

#### USER DEFINED VARIABLES ####
# change your spp_code (e.g. Sob, Aen, Pbb)
spp_code="Sin"

# change your site_A_code to the 3 letter site code of the Albatross (historical) population (e.g. Pnd, Gal, Mvi)
site_A_code="Pnd"

# change your site_C_code to the 3 letter site code of the contemporary (modern) population (e.g. Pnd, Gal, Mvi)
site_C_code="Pnd"

#### VARIABLES FROM USER INPUT  ####

# era site pattern (e.g. APnd, CPal). do not change. 
spp_era_A_site_pattern=paste0(spp_code,"A",site_A_code)
spp_era_C_site_pattern=paste0(spp_code,"C",site_C_code)


#### READ IN DATA ####

# K=2

# Define the input file with the full directory path
k2_angsd_not <- read.table("angsd_admix_notrans_it500.admix.2.Q")
k2_angsd_not <- as.data.frame(k2_angsd_not) # is this data read in alphanumerically?

# Read the BAM list file
bamlist <- read.table("bam_list_all.txt")
# Ensure it's treated as a vector
bamlist <- bamlist$V1  # Assuming the BAM file names are in the first column


#### SAMPLE SIZE ####

# Count the number of albatross and contemporary individuals based on the patterns
albatross_n <- as.numeric(sum(grepl(paste0(spp_era_A_site_pattern, ".*\\.bam$"), bamlist)))  # Count lines matching albatross pattern
contemporary_n <- as.numeric(sum(grepl(paste0(spp_era_C_site_pattern, ".*\\.bam$"), bamlist)))  # Count lines matching contemporary pattern
# albatross_n_plus_1 <- as.numeric(albatross_n + 1)
total_n <- as.numeric(sum(grepl(paste0(".*\\.bam$"), bamlist)))  # Count all lines matching *.bam

# Display the counts
cat("Number of Albatross (historical) BAM files:", albatross_n, "\n")
cat("Number of Contemporary (modern) BAM files:", contemporary_n, "\n")
cat("Total number of BAM files:", total_n, "\n")


#### ADD POP LABELS ####

#meta.data <- data.frame(loc=pop_label_angsd)
meta.data <- data.frame(matrix(ncol=1,nrow=total_n)) # total number of individuals (*.bam files) 
colnames(meta.data)="loc"
meta.data$loc <- c(
  rep("Albatross",albatross_n), # 
  rep("Contemporary",contemporary_n)
)

#### CREATE PLOT ####

q2_not <- list(k2_angsd_not)
plot_q2_not <- 
  plotQ(as.qlist(q2_not), imgoutput = "sep", returnplot = TRUE, exportpath=getwd(), dpi=1000,
        clustercol = c("#00BFC4", "#F8766D"),
        showsp = TRUE, spbgcol = "white", splab = "K = 2", splabsize = 10,
        showyaxis = TRUE, showticks = FALSE, indlabsize = 10, ticksize = 0.5,
        grplab = meta.data, linesize = 0.2, pointsize = 2, showgrplab = FALSE, grplabspacer = 0.1,)
print(plot_q2_not) # save to your directory
