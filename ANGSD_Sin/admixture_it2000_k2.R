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

# K = 2

# Define the input file with the full directory path
k2_angsd_not <- read.table("angsd_notrans_snps_it2000_admix.admix.2.Q")
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

# Combine ancestry proportions with population labels
admixture_data <- cbind(meta.data, k2_angsd_not)

# Rename columns in k2_angsd_not to represent ancestry clusters
colnames(admixture_data) <- c("population","cluster1", "cluster2")


#### PLOT ADMIXTURE ####

q2_not <- list(k2_angsd_not)
plot_q2_not <- 
  plotQ(as.qlist(q2_not), imgoutput = "sep", returnplot = TRUE, exportpath=getwd(), dpi=1000,
        clustercol = c("#F8766D", "#00BFC4"),
        showsp = TRUE, spbgcol = "white", splab = "K = 2", splabsize = 12,
        showyaxis = TRUE, showticks = FALSE, indlabsize = 12, ticksize = 0.5,
        grplab = meta.data, linesize = 0.2, pointsize = 2, showgrplab = FALSE, grplabspacer = 0.1,)
print(plot_q2_not) # save to your directory



q2_not <- list(k2_angsd_not)
plot_q2_not <- 
  plotQ(as.qlist(q2_not), imgoutput = "sep", returnplot = TRUE, exportpath=getwd(), dpi=1000,
        clustercol = c("#F8766D", "#00BFC4"),
        showsp = FALSE, spbgcol = "white", splab = "K = 2", splabsize = 12,
        showyaxis = TRUE, showticks = FALSE, indlabsize = 12, ticksize = 0.5,
        grplab = meta.data, linesize = 0.2, pointsize = 2, showgrplab = FALSE, grplabspacer = 0.1,)
print(plot_q2_not) # save to your directory



#### BOXPLOT ANCESTRY PROPORTIONS BY POPULATION ####

# Convert population column to factor for proper plotting
admixture_data$population <- as.factor(admixture_data$population)

# Boxplot for Cluster1
ggplot(admixture_data, aes(x = population, y = cluster1, fill = population)) +
  geom_boxplot() +
  scale_fill_manual(values = c("#F8766D", "#00BFC4")) +
  theme_minimal() +
  ylab("Ancestry Proportion (Cluster1)") +
  xlab("Population") +
  ggtitle("Cluster1 Ancestry Proportion by Population")

# Boxplot for Cluster2
ggplot(admixture_data, aes(x = population, y = cluster2, fill = population)) +
  geom_boxplot() +
  scale_fill_manual(values = c("#F8766D", "#00BFC4")) +
  theme_minimal() +
  ylab("Ancestry Proportion (Cluster2)") +
  xlab("Population") +
  ggtitle("Cluster2 Ancestry Proportion by Population")

# Boxplot for Cluster3
# ggplot(admixture_data, aes(x = population, y = cluster3, fill = population)) +
#   geom_boxplot() +
#   scale_fill_manual(values = c("#F8766D", "#00BFC4")) +
#   theme_minimal() +
#   ylab("Ancestry Proportion (Cluster3)") +
#   xlab("Population") +
#   ggtitle("Cluster3 Ancestry Proportion by Population")


#### PLOT: DISTRUBTION OF ANCESTRY PROPORTIONS BY POPULATION ####

# Density plot for Cluster1
ggplot(admixture_data, aes(x = cluster1, fill = population)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("#F8766D", "#00BFC4")) +
  theme_minimal() +
  xlab("Ancestry Proportion (Cluster1)") +
  ggtitle("Density Plot of Cluster1 Ancestry Proportion by Population")

# Density plot for Cluster2
ggplot(admixture_data, aes(x = cluster2, fill = population)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("#F8766D", "#00BFC4")) +
  theme_minimal() +
  xlab("Ancestry Proportion (Cluster2)") +
  ggtitle("Density Plot of Cluster2 Ancestry Proportion by Population")

# Density plot for Cluster3
# ggplot(admixture_data, aes(x = cluster3, fill = population)) +
#   geom_density(alpha = 0.5) +
#   scale_fill_manual(values = c("#F8766D", "#00BFC4")) +
#   theme_minimal() +
#   xlab("Ancestry Proportion (Cluster3)") +
#   ggtitle("Density Plot of Cluster3 Ancestry Proportion by Population")


#### STATISTICS: MANOVA ####

# Check for linear dependence
admixture_data$sum_check <- rowSums(admixture_data[, c("cluster1", "cluster2")])
summary(admixture_data$sum_check)
# If all values in sum_check are 1.0, then one of the clusters is redundant and needs to be removed for MANOVA.

# check for zero variance
apply(admixture_data[, c("cluster1", "cluster2")], 2, var)
# If any cluster has zero or extremely low variance, it does not provide useful information and should be removed before running MANOVA.

# MANOVA to test differences in 2 clusters together
manova_result <- manova(cbind(cluster1, cluster2) ~ population, data = admixture_data)
# Run MANOVA using Pillai's trace
summary(manova_result, test = "Pillai")

# cluster 1 & cluster 2 are linearly dependent, which violates MANOVA's assumption of independence between dependent variables. 
# Run an ANOVA, t-test, F-test on cluster 1.


#### STATISTICS: ANOVA ####

anova_cluster1 <- aov(cluster1 ~ population, data = admixture_data)
summary(anova_cluster1)


#### STATISTICS: t-TEST ####
# t-Test for Ancestry Proportions

# Assuming admixture results are stored in a dataframe 'admixture_data'
t.test(admixture_data$cluster1[admixture_data$population == "Albatross"], 
       admixture_data$cluster1[admixture_data$population == "Contemporary"])

t.test(admixture_data$cluster2[admixture_data$population == "Albatross"], 
       admixture_data$cluster2[admixture_data$population == "Contemporary"])

# t.test(admixture_data$cluster3[admixture_data$population == "Albatross"], 
#        admixture_data$cluster3[admixture_data$population == "Contemporary"])


#### STATISTICS: F-TEST ####
# F-Test for Variance in Admixture Proportions

var.test(admixture_data$cluster1[admixture_data$population == "Albatross"], 
         admixture_data$cluster1[admixture_data$population == "Contemporary"])

var.test(admixture_data$cluster2[admixture_data$population == "Albatross"], 
         admixture_data$cluster2[admixture_data$population == "Contemporary"])

# var.test(admixture_data$cluster3[admixture_data$population == "Albatross"], 
#          admixture_data$cluster3[admixture_data$population == "Contemporary"])

