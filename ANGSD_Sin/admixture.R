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
spp_code="Cha"

# change your site_A_code to the 3 letter site code of the Albatross (historical) population (e.g. Pnd, Gal, Mvi)
site_A_code="Pnd"

# change your site_C_code to the 3 letter site code of the contemporary (modern) population (e.g. Pnd, Gal, Mvi)
site_C_code="Pnd"

#### VARIABLES FROM USER INPUT  ####

# era site pattern (e.g. APnd, CPal). do not change. 
spp_era_A_site_pattern=paste0(spp_code,"A",site_A_code)
spp_era_C_site_pattern=paste0(spp_code,"C",site_C_code)

# Count the number of *.bam files matching the patterns
albatross_n <- as.numeric(length(list.files(pattern = paste0(spp_era_A_site_pattern, ".*\\.bam$")))) # number of albatross individuals (*A*.bam files)
contemporary_n <- as.numeric(length(list.files(pattern = paste0(spp_era_C_site_pattern, ".*\\.bam$")))) # number of contemporary individuals (*C*.bam files)
# albatross_n_plus_1 <- as.numeric(albatross_n + 1)
total_n <- as.numeric(albatross_n + contemporary_n) # total number of individuals (*.bam files)  

# Display the counts
cat("Number of Albatross (historical) BAM files:", albatross_n, "\n")
cat("Number of Contemporary (modern) BAM files:", contemporary_n, "\n")
cat("Total number of BAM files", total_n, "\n")

#### READ IN angsd_admix_notrans*.admix.3.Q ####

# K=3

# Define the input file with the full directory path
k3_angsd_not <- read.table("/archive/carpenterlab/pire/pire_corythoichthys_haematopterus_lcwgs/ANGSD_Cha/angsd_admix_notrans_it500.admix.3.Q")
k3_angsd_not <- as.data.frame(k3_angsd_not) # is this data read in alphanumerically?

#### ADD POP LABELS ####

#meta.data <- data.frame(loc=pop_label_angsd)
meta.data <- data.frame(matrix(ncol=1,nrow=total_n)) # total number of individuals (*.bam files) 
colnames(meta.data)="loc"
meta.data$loc <- c(
  rep("Albatross",albatross_n), # 
  rep("Contemporary",contemporary_n)
)

#### CREATE PLOT ####

q3_not <- list(k3_angsd_not)
plot_q3_not <- 
  plotQ(as.qlist(q3_not), imgoutput = "sep", returnplot = TRUE, exportpath=getwd(), dpi=1000,
        clustercol = c("#00BFC4", "#F8766D","#AB82FF"),
        showsp = TRUE, spbgcol = "white", splab = "K = 3", splabsize = 10,
        showyaxis = TRUE, showticks = FALSE, indlabsize = 10, ticksize = 0.5,
        grplab = meta.data, linesize = 0.2, pointsize = 2, showgrplab = FALSE, grplabspacer = 0.1,)
print(plot_q3_not) # save to your directory
