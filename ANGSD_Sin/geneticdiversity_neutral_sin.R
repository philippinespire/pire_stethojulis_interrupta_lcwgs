## Wrangling, analyzing, and plotting genetic diversity metrics: nucleotide diversity (pi), Watterson's theta, Tajima's D

####################
#### INITIALIZE ####
####################
# set working directory

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))



##################
#### PACKAGES ####
##################
packages_used <- 
  c("tidyverse",
    "cowplot",
    "boot",
    "Cairo",
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

options(bitmapType = "cairo")  # Set Cairo as the default graphics device


######################
#### READ IN DATA ####
######################
##Load in theta outputs by population (abol, amta, cbol, cmta)
apnd_thetas_notrans <- read_table("APnd_notrans_neutral_fdr.thetas.idx.pestPG")
cpnd_thetas_notrans <- read_table("CPnd_notrans_neutral_fdr.thetas.idx.pestPG")

##Import depth information
angsd_depth_notrans <- read_table("combined_sites_neutral_fdr.pos.gz")
#This is by site, we need it by chromosome to match with the theta calculations
apnd_depth_notrans <- read_table("APnd_sites_notrans_neutral_fdr.pos.gz") 
cpnd_depth_notrans <- read_table("CPnd_sites_notrans_neutral_fdr.pos.gz")

# Read the BAM list file
bamlist <- read.table("bam_list_all.txt")
# Ensure it's treated as a vector
bamlist <- bamlist$V1  # Assuming the BAM file names are in the first column



################################
#### USER DEFINED VARIABLES ####
################################
# change your spp_code (e.g. Sob, Aen, Pbb)
spp_code="Sin"

# location longform
site_long = "Pandanon"

# change your site_A_code to the 3 letter site code of the Albatross (historical) population (e.g. Pnd, Gal, Mvi)
site_A_code="Pnd"

# change your site_C_code to the 3 letter site code of the contemporary (modern) population (e.g. Pnd, Gal, Mvi)
site_C_code="Pnd"

# era site pattern (e.g. APnd, CPal). do not change. 
spp_era_A_site_pattern=paste0(spp_code,"A",site_A_code)
spp_era_C_site_pattern=paste0(spp_code,"C",site_C_code)



#####################
#### SAMPLE SIZE ####
#####################
# Count the number of albatross and contemporary individuals based on the patterns
albatross_n <- as.numeric(sum(grepl(paste0(spp_era_A_site_pattern, ".*\\.bam$"), bamlist)))  # Count lines matching albatross pattern
contemporary_n <- as.numeric(sum(grepl(paste0(spp_era_C_site_pattern, ".*\\.bam$"), bamlist)))  # Count lines matching contemporary pattern
albatross_n_plus_1 <- as.numeric(albatross_n + 1)
total_n <- as.numeric(sum(grepl(paste0(".*\\.bam$"), bamlist)))  # Count all lines matching *.bam

# Display the counts
cat("Number of Albatross (historical) BAM files:", albatross_n, "\n")
cat("Number of Contemporary (modern) BAM files:", contemporary_n, "\n")
cat("Total number of BAM files:", total_n, "\n")



##########################
#### WRANGLE RAW DATA ####
##########################
## THETA
#Add a column for site to each dataset
apnd_thetas_notrans$Site <- "APnd"
cpnd_thetas_notrans$Site <- "CPnd"

#Add a column for era to each dataset
apnd_thetas_notrans$Era <- "Historical"
cpnd_thetas_notrans$Era <- "Modern"

#Merge datasets for plotting
angsd_thetas_notrans <- rbind(apnd_thetas_notrans, cpnd_thetas_notrans)


## DEPTH
#Take the average of total Depth for all the sites within a chromosome
angsd_avgdepth_notrans <- angsd_depth_notrans %>% group_by(chr) %>% summarise(avg_Depth = mean(totDepth))
#This gets us average total depth (summed across individuals) for each chromosome

#Add a column with average depth by individual
angsd_avgdepth_notrans$ind_depth <- angsd_avgdepth_notrans$avg_Depth/total_n

#Rename Chr column to match angsd_thetas dataframe
angsd_avgdepth_notrans <- angsd_avgdepth_notrans %>%
  rename(Chr = chr)
# names(angsd_avgdepth_notrans)[1] <- "Chr"

#Merge with angsd_thetas dataframe
angsd_thetas_depth_notrans <- merge(angsd_thetas_notrans, angsd_avgdepth_notrans, by="Chr")

#Add a column with theta by site (theta for the contig divided by number of sites on the contig)
angsd_thetas_depth_notrans$tW_bysite <- angsd_thetas_depth_notrans$tW/angsd_thetas_depth_notrans$nSites

#Add a column with pi (nucleotide diversity) by site (theta for the contig divided by number of sites on the contig)
angsd_thetas_depth_notrans$tP_bysite <- angsd_thetas_depth_notrans$tP/angsd_thetas_depth_notrans$nSites

#Reorder for plotting
angsd_thetas_depth_notrans$Site <- factor(angsd_thetas_depth_notrans$Site, levels=c("APnd", "CPnd"))

#Subset by population
apnd_angsd_thetas_depth_notrans <- subset(angsd_thetas_depth_notrans, Era=="Historical")
cpnd_angsd_thetas_depth_notrans <- subset(angsd_thetas_depth_notrans, Era=="Modern")

# filter out any NaN
apnd_angsd_thetas_depth_notrans <- apnd_angsd_thetas_depth_notrans %>%
  filter(!is.na(tP_bysite) & !is.na(tW_bysite))
cpnd_angsd_thetas_depth_notrans <- cpnd_angsd_thetas_depth_notrans %>%
  filter(!is.na(tP_bysite) & !is.na(tW_bysite))


################################
#### SAVE RAW WRANGLED DATA ####
################################
# Ensure the 'out' directory exists
# if (!dir.exists("output")) {
#   dir.create("output")
# }

# # Outfile pattern all
# outfile_all <- paste0("output/", spp_code, "_angsd_thetas_depth_notrans_subset3_neutral_fdr_", Sys.Date(), ".rds")
# 
# # Save the all dataframe as an RDS file
# saveRDS(angsd_thetas_depth_notrans, file = outfile_all)
# 
# # Outfile pattern apnd
# outfile_apnd <- paste0("output/", spp_code, "_apnd_angsd_thetas_depth_notrans_subset3_neutral_fdr_", Sys.Date(), ".rds")
# 
# # Save the all dataframe as an RDS file
# saveRDS(apnd_angsd_thetas_depth_notrans, file = outfile_apnd)
# 
# # Outfile pattern cpnd
# outfile_cpnd <- paste0("output/", spp_code, "_cpnd_angsd_thetas_depth_notrans_subset3_neutral_fdr_", Sys.Date(), ".rds")
# 
# # Save the all dataframe as an RDS file
# saveRDS(cpnd_angsd_thetas_depth_notrans, file = outfile_cpnd)



####################################
#### PLOTS: PI & THETA VS DEPTH ####
####################################

## DEFINE COLOR SCHEME ##
# Define custom color scheme for historical and modern eras
era_colors <- c(
  "Historical" = "#F8766D",  # red/pink
  "Modern"     = "#00BFC4"   # blue
)


## PLOT: Theta vs Depth 
plot_theta_depth <- angsd_thetas_depth_notrans %>%
  filter(!is.na(tW_bysite)) %>%
  ggplot(aes(x=ind_depth, y=tW_bysite, color=Era), show.legend=FALSE) +
  labs(
    title =paste0(spp_code, " ", site_long, ": Mean Depth per Individual vs Theta"),
    x="Mean Depth Per Individual",
    y="Theta"
  ) +
  theme_classic() +
  theme(
    legend.position = "right",
    legend.text  = element_text(family = "Times New Roman", size = 12),
    axis.title   = element_text(family = "Times New Roman", size = 12, face = "bold"),  # Font for axis titles
    axis.text.x  = element_text(size = 12, family = "Times New Roman"),
    axis.text.y  = element_text(size = 12, family = "Times New Roman"),
    plot.title   = element_text(family = "Times New Roman", face = "bold")) +
  geom_point(size=1.5, alpha=0.5) +
  geom_smooth() +
  scale_color_manual(values = era_colors) 

print(plot_theta_depth)

# plot_theta_depth + 
#   scale_y_continuous(
#     limits = c(0, 0.125),
#     breaks = seq(0, 0.12, by = 0.03)#,
#     #expand = expansion(mult = c(0, 0))
#   )

# outFile pattern
outFile_plot_theta_depth <- paste0("plots/", spp_code, "_plot_theta_depth_neutral_fdr_leg.png")

# Save the plot to a file
ggsave(filename = outFile_plot_theta_depth, plot = plot_theta_depth, width = 2.15, height = 2.5)


## PLOT: Pi vs Depth
plot_pi_depth <- angsd_thetas_depth_notrans %>%
  filter(!is.na(tP_bysite)) %>%
  ggplot(aes(x=ind_depth, y=tP_bysite, color=Era)) +
  labs(
    # title =paste0(spp_code, " ", site_long, ": Mean Depth per Individual vs Pi"),
    x="Mean Depth Per Individual",
    y="Nucleotide Diversity") +
  theme_classic() +
  theme(
    legend.position = "none",
    legend.text  = element_text(family = "Times New Roman", size = 12),
    axis.title   = element_text(family = "Times New Roman", size = 12, face = "bold"),  # Font for axis titles
    axis.text.x  = element_text(size = 12, family = "Times New Roman"),
    axis.text.y  = element_text(size = 12, family = "Times New Roman"),
    plot.title   = element_text(family = "Times New Roman", face = "bold")) +
  geom_point(size=1.5, alpha=0.5) +
  geom_smooth() +
  scale_color_manual(values = era_colors)

print(plot_pi_depth)

# plot_pi_depth +
#   scale_y_continuous(
#     limits = c(0, 0.131),
#     breaks = seq(0, 0.12, by = 0.03)#,
#     #expand = expansion(mult = c(0, 0))
#   )

# outFile pattern
outFile_plot_pi_depth <- paste0("plots/", spp_code, "_plot_pi_depth_neutral_fdr.png")

# Save the plot to a file
ggsave(filename = outFile_plot_pi_depth, plot = plot_pi_depth, width = 2.15, height = 2.5)



###########################
#### STATS: PI NEUTRAL ####
###########################
# Test to see if theta is normally distributed
pnd_thetas_depth <- rbind(apnd_angsd_thetas_depth_notrans, cpnd_angsd_thetas_depth_notrans)
hist(apnd_angsd_thetas_depth_notrans$tP_bysite) # right skewed
hist(cpnd_angsd_thetas_depth_notrans$tP_bysite) # right skewed 

plot_hist_pi <- 
  ggplot(pnd_thetas_depth, aes(x = tP_bysite, fill = Era, color = Era)) +
  labs(
    title =paste0(spp_code, " ", site_long, ": Histogram of Mean Pi per Site"),
    x="Nucleotide Diversity",
    y="Count") +
  geom_histogram(position = "identity", alpha = 0.5, bins = 10) +
  theme_classic() + 
  theme(legend.position = "right") +
  scale_color_manual(values = era_colors) +
  scale_fill_manual(values  = era_colors)

print(plot_hist_pi)
# looks right skewed. REPORT NONPARAMETRIC
# run both t.test and wilcoxon

# outFile pattern
outFile_hist_pi <- paste0("plots/", spp_code, "_hist_pi_neutral_fdr_leg", ".png")

# Save the plot to a file
ggsave(filename = outFile_hist_pi, plot = plot_hist_pi, width = 2.15, height = 2.5)

## PARAMETRIC
# Paired t-test
t.test(apnd_angsd_thetas_depth_notrans$tP_bysite, cpnd_angsd_thetas_depth_notrans$tP_bysite, paired=TRUE)
# data:  apnd_angsd_thetas_depth_notrans$tP_bysite and cpnd_angsd_thetas_depth_notrans$tP_bysite
# t = -0.39137, df = 88, p-value = 0.6965
# alternative hypothesis: true mean difference is not equal to 0
# 95 percent confidence interval:
#   -0.01766245  0.01185037
# sample estimates:
#   mean difference 
# -0.00290604  

## NONPARAMETRIC
# Paired Wilcoxon test
wilcox.test(apnd_angsd_thetas_depth_notrans$tP_bysite, cpnd_angsd_thetas_depth_notrans$tP_bysite, paired = TRUE)
# data:  apnd_angsd_thetas_depth_notrans$tP_bysite and cpnd_angsd_thetas_depth_notrans$tP_bysite
# V = 1223, p-value = 0.001437
# alternative hypothesis: true location shift is not equal to 0

## BOOTSTRAPPING ##
# function
samplemean <- function(x, d) {
  return(mean(x[d]))
}

## HISTORICAL Bootstrapping of pi
x = as.vector(apnd_angsd_thetas_depth_notrans$tP_bysite)
apnd_boot_pi = boot(x, samplemean, R=1000)
apnd_boot_pi
plot(apnd_boot_pi)
# Bootstrap Statistics :
#   original        bias    std. error
# t1* 0.08228507 -0.0001504296  0.01526804

# check type = norm not type = bca
# boot.ci(boot.out=apnd_boot_pi, type="norm") #95%   (  ) 
boot.ci(boot.out=apnd_boot_pi, type="bca") #95%   (  0.0586,  0.1220 ) 

## MODERN Bootstrapping of pi
x = as.vector(cpnd_angsd_thetas_depth_notrans$tP_bysite)
cpnd_boot_pi = boot(x, samplemean, R=1000)
cpnd_boot_pi
plot(cpnd_boot_pi)
# Bootstrap Statistics :
#   original       bias    std. error
# t1* 0.08519111 -0.0008998075  0.01437166

# check type = norm not type = bca
# boot.ci(boot.out=cpnd_boot_pi, type="norm") #95%   (  )
boot.ci(boot.out=cpnd_boot_pi, type="bca") #95%   ( 0.0628,  0.1184 )

## Save values to create a dataframe for plotting
species              <- c(spp_code, spp_code)
population           <- c("APnd","CPnd")
location             <- c("Pandanon Island", "Pandanon Island")
era                  <- c("Historical", "Modern")
pi_neutral_pval      <- c(0.6965, 0.6965)
pi_neutral_pval_wil  <- c(0.001437, 0.001437)
pi_neutral_mean      <- c(0.08228507, 0.08519111)
pi_neutral_se        <- c(0.01526804, 0.01437166)
pi_neutral_lower_bca <- c(0.0586 , 0.0628)
pi_neutral_upper_bca <- c(0.1220 , 0.1184)



##############################
#### STATS: THETA NEUTRAL ####
##############################
# Test to see if theta is normally distributed
hist(apnd_angsd_thetas_depth_notrans$tW_bysite) # Looks right skewed
hist(cpnd_angsd_thetas_depth_notrans$tW_bysite, bins = 20) # looks multimodal  

plot_histo_pnd_thetas <- 
  ggplot(pnd_thetas_depth, aes(x = tW_bysite, fill = Era, color = Era)) +
  geom_histogram(position = "identity", alpha = 0.5, bins = 10) +
  labs(
    title =paste0(spp_code, " ", site_long, ": Histogram of Mean Theta per Site"),
    x="Mean Theta",
    y="Count") +
  theme(legend.position = "right") +
  theme_classic() + 
  scale_color_manual(values = era_colors) +
  scale_fill_manual(values  = era_colors)

print(plot_histo_pnd_thetas)

# calculate both t.test and wilcoxon. Sample size is 20 per era. REPORT NONPARAMETRIC. 
# outFile pattern
outFile_hist_pi <- paste0("plots/", spp_code, "_hist_pi_neutral_fdr_leg", ".png")

# Save the plot to a file
ggsave(filename = outFile_hist_pi, plot = plot_histo_pnd_thetas, width = 2.15, height = 2.5)


## PARAMETRIC
# Paired t-test
t.test(apnd_angsd_thetas_depth_notrans$tW_bysite, cpnd_angsd_thetas_depth_notrans$tW_bysite, paired=TRUE)
# data:  apnd_angsd_thetas_depth_notrans$tW_bysite and cpnd_angsd_thetas_depth_notrans$tW_bysite
# t = -7.3979, df = 88, p-value = 7.726e-11
# alternative hypothesis: true mean difference is not equal to 0
# 95 percent confidence interval:
#   -0.05866671 -0.03382157
# sample estimates:
#   mean difference 
# -0.04624414 


## NONPARAMETRIC
# Paired Wilcoxon test
wilcox.test(apnd_angsd_thetas_depth_notrans$tW_bysite, cpnd_angsd_thetas_depth_notrans$tW_bysite, paired = TRUE)
# data:  apnd_angsd_thetas_depth_notrans$tW_bysite and cpnd_angsd_thetas_depth_notrans$tW_bysite
# V = 515, p-value = 1.168e-09
# alternative hypothesis: true location shift is not equal to 0

## BOOTSTRAP FUNCTION
samplemean <- function(x, d) {
  return(mean(x[d]))
}

## HISTORICAL Bootstrapping of theta
x = as.vector(apnd_angsd_thetas_depth_notrans$tW_bysite)
apnd_boot_theta = boot(x, samplemean, R=1000)
apnd_boot_theta
plot(apnd_boot_theta)
# original        bias     std. error
# t1* 0.04655963 0.0002274872 0.007959185
# use type bca
# boot.ci(boot.out=apnd_boot_theta, type="norm") #95%   (  ) 
boot.ci(boot.out=apnd_boot_theta, type="bca") #95%   ( 0.0324,  0.0649 )


## MODERN Bootstrapping of theta
x = as.vector(cpnd_angsd_thetas_depth_notrans$tW_bysite)
cpnd_boot_theta = boot(x, samplemean, R=1000)
cpnd_boot_theta
plot(cpnd_boot_theta)
# original        bias     std. error
# t1* 0.09280377 -0.0002037061 0.006295492
# use type bca
boot.ci(boot.out=cpnd_boot_theta, type="norm") #95%   ( 0.0807,  0.1053 ) 

##Create data frame with means and 95% CI for plotting
era                     <- c("Historical", "Modern")
theta_neutral_pval      <- c(7.726e-11, 7.726e-11)
theta_neutral_pval_wil  <- c(1.168e-09, 1.168e-09)
theta_neutral_mean      <- c(0.04655963, 0.09280377)
theta_neutral_se        <- c(0.007959185, 0.006295492)
theta_neutral_lower_bca <- c(0.0324 , 0.0807)
theta_neutral_upper_bca <- c(0.0649 , 0.1053)

## CREATE PI THETA DATAFRAME ##
df_neutral_theta_pi <- data.frame(species, population, location, era, 
                                  pi_neutral_mean, pi_neutral_se, pi_neutral_pval, pi_neutral_pval_wil, pi_neutral_lower_bca, pi_neutral_upper_bca,
                                  theta_neutral_mean, theta_neutral_se, theta_neutral_pval, theta_neutral_pval_wil, theta_neutral_lower_bca, theta_neutral_upper_bca)

print(df_neutral_theta_pi)

# Outfile pattern
outfile_pi_theta <- paste0("output/", spp_code, "_gendiv_stats_depth_notrans_neutral_fdr_", Sys.Date(), ".rds")

# Save the all dataframe as an RDS file
saveRDS(df_neutral_theta_pi, file = outfile_pi_theta)



####################################
########### FUNCTION ###############
####################################
# USE THE MANUAL VERSION ABOVE

# function to do the above sections: STATS PI & THETA NEUTRAL

# Function to bootstrap mean and extract mean, SE, and 95% CI
bootstrap_mean_ci <- function(x, R = 1000) {
  boot_result <- boot(x, statistic = function(data, i) mean(data[i]), R = R)
  ci <- boot.ci(boot_result, type = "norm")  # 95% CI using normal approximation
  
  list(
    mean     = boot_result$t0,
    se       = boot_result$stderr,
    ci_lower = ci$normal[2],  # Lower 95% CI
    ci_upper = ci$normal[3]   # Upper 95% CI
  )
}

# Wrapper to compute paired t-test and bootstrap stats for historical and modern
compute_pi_theta_summary <- function(var_his, var_mod, R = 1000) {
  t_test <- t.test(var_his, var_mod, paired = TRUE)
  
  boot_his <- bootstrap_mean_ci(var_his, R)
  boot_mod <- bootstrap_mean_ci(var_mod, R)
  
  list(
    pval          = t_test$p.value,
    his_mean      = boot_his$mean,
    his_se        = boot_his$se,
    his_ci_lower  = boot_his$ci_lower,
    his_ci_upper  = boot_his$ci_upper,
    mod_mean      = boot_mod$mean,
    mod_se        = boot_mod$se,
    mod_ci_lower  = boot_mod$ci_lower,
    mod_ci_upper  = boot_mod$ci_upper
  )
}

# PI
neutral_pi <- compute_pi_theta_summary(
  apnd_angsd_thetas_depth_notrans$tP_bysite,
  cpnd_angsd_thetas_depth_notrans$tP_bysite
)

# THETA
neutral_theta <- compute_pi_theta_summary(
  apnd_angsd_thetas_depth_notrans$tW_bysite,
  cpnd_angsd_thetas_depth_notrans$tW_bysite
)


# Setup constant metadata
species    <- rep(spp_code, 2)
population <- c("APnd", "CPnd")  # or spp_era_A_site_pattern if preferred
location   <- rep("Pandanon Island", 2)
era        <- c("Historical", "Modern")

df_fun_neutral_theta_pi <- data.frame(
  species    = species,
  population = population,
  location   = location,
  era        = era,
  
  # PI
  pi_mean    = c(neutral_pi$his_mean, neutral_pi$mod_mean),
  pi_se      = c(neutral_pi$his_se,   neutral_pi$mod_se),
  pi_ci_lo   = c(neutral_pi$his_ci_lower, neutral_pi$mod_ci_lower),
  pi_ci_hi   = c(neutral_pi$his_ci_upper, neutral_pi$mod_ci_upper),
  pi_pval    = rep(neutral_pi$pval, 2),
  
  # THETA
  theta_mean   = c(neutral_theta$his_mean, neutral_theta$mod_mean),
  theta_se     = c(neutral_theta$his_se,   neutral_theta$mod_se),
  theta_ci_lo  = c(neutral_theta$his_ci_lower, neutral_theta$mod_ci_lower),
  theta_ci_hi  = c(neutral_theta$his_ci_upper, neutral_theta$mod_ci_upper),
  theta_pval   = rep(neutral_theta$pval, 2)
)

print(df_fun_neutral_theta_pi)



###################
#### PI: PLOTS ####
###################
plot_pi <- df_neutral_theta_pi %>%
  ggplot(aes(x=era, y=pi_neutral_mean, color=era)) +
  labs(y="Mean Pi") +
  theme_classic() +
  theme(legend.position="none") +
  geom_point(size=2) +
  geom_errorbar(aes(ymin=pi_neutral_mean-1.96*pi_neutral_se, ymax=pi_neutral_mean+1.96*pi_neutral_se), width=0.0) +
  # ylim(0.07, 0.10) +
  scale_color_manual(values = era_colors)
print(plot_pi)

# FORMATTED
plot_pi <- df_neutral_theta_pi %>%
  ggplot(aes(x = era, y = pi_neutral_mean, color = era)) +
  labs(
    # title = paste0(spp_code, " ", site_long, ": Mean Pi of Neutral SNPs by Era"),
    y = "Mean Pi") +
  theme_classic() +
  theme(legend.position = "none",
        legend.text  = element_text(family = "Times New Roman", size = 12),
        axis.text.x = element_blank(),  # Hides x-axis labels
        axis.title.x = element_blank(),  # Hides x-axis title
        axis.ticks.x = element_blank(),  # Hides x-axis ticks
        axis.text.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis values
        axis.title.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis title
        axis.ticks.length = unit(3, "pt"),  # Small tick marks
        axis.ticks = element_line(color = "black")) +  # Black tick mark
  geom_point(size = 2, position = position_dodge(width = 0.3)) +  
  geom_errorbar(aes(ymin = pi_neutral_mean - 1.96 * pi_neutral_se, ymax = pi_neutral_mean + 1.96 * pi_neutral_se),
                width = 0.1, position = position_dodge(width = 0.3)) +  
  # ylim(0.0, 0.2) +  # Adjusted to fit your data
  scale_color_manual(values = era_colors) 
print(plot_pi)

# outFile pattern
outFile_plot_pi <- paste0("plots/", spp_code, "_plot_pi_neutral_fdr.png")  

# Save the plot to a file
ggsave(filename = outFile_plot_pi, plot = plot_pi, width = 2.15, height = 2.5)



######################
#### PLOTS: THETA ####
######################
# FORMATTED
plot_theta <- df_neutral_theta_pi %>%
  ggplot(aes(x = era, y = theta_neutral_mean, color = era)) +
  labs(
    # title = paste0(spp_code, " ", site_long, ": Mean Theta of Neutral SNPs by Era"),
    y = "Mean Theta") +
  theme_classic() +
  theme(legend.position = "none",
        legend.text  = element_text(family = "Times New Roman", size = 12),
        axis.text.x = element_blank(),  # Hides x-axis labels
        axis.title.x = element_blank(),  # Hides x-axis title
        axis.ticks.x = element_blank(),  # Hides x-axis ticks
        axis.text.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis values
        axis.title.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis title
        axis.ticks.length = unit(3, "pt"),  # Small tick marks
        axis.ticks = element_line(color = "black")) +  # Black tick mark
  geom_point(size = 2, position = position_dodge(width = 0.3)) +  
  geom_errorbar(aes(ymin = theta_neutral_mean - 1.96 * theta_neutral_se, ymax = theta_neutral_mean + 1.96 * theta_neutral_se),
                width = 0.1, position = position_dodge(width = 0.3)) +  
  # ylim(0.00, 0.20) +  # Adjusted to fit your data
  scale_color_manual(values = era_colors)
print(plot_theta)

# outFile pattern
outFile_plot_theta <- paste0("plots/", spp_code, "_plot_theta_neutral_fdr.png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta, plot = plot_theta, width = 2.15, height = 2.5)


## GRID PLOT WITH THETA & PI NEUTRAL
# Remove legends from each plot first
plot_theta_nolegend <- plot_theta + theme(legend.position = "none")
plot_pi_nolegend <- plot_pi + theme(legend.position = "none")

# Then combine the two plots in the plot area
plot_theta_pi <- plot_grid(
  plot_theta_nolegend,
  plot_pi_nolegend,
  # labels = c('A', 'B'),
  ncol = 2  # ensures 2 plots side by side
)

print(plot_theta_pi)

# outFile pattern
outFile_plot_theta_pi <- paste0("plots/", spp_code, "_plot_theta_pi_neutral_fdr", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta_pi, plot = plot_theta_pi, width = 2.15, height = 2.5)



###########################
#### PLOTS: TAJIMA'S D ####
###########################
# Remove any sites without Pi or Theta
# Tajima can be = 0.0 without any data (aka when nSites = 0)
angsd_thetas_depth_notrans <- angsd_thetas_depth_notrans %>%
  filter(!is.na(tP_bysite) & !is.na(tW_bysite))

# Function to compute mean and 95% CI
calculate_mean_ci <- function(data) {
  n <- sum(!is.na(data$Tajima))  # Count non-NA values
  mean_val <- mean(data$Tajima, na.rm = TRUE)
  se_val <- sd(data$Tajima, na.rm = TRUE) / sqrt(n)  # Standard Error (SE)
  ci_lower <- mean_val - 1.96 * se_val  # Lower bound of 95% CI
  ci_upper <- mean_val + 1.96 * se_val  # Upper bound of 95% CI
  
  return(data.frame(mean_Tajima = mean_val, lower_CI = ci_lower, upper_CI = ci_upper))
}

# Apply the function to each Era
tajima_summary <- angsd_thetas_depth_notrans %>%
  group_by(Era) %>%
  summarise(mean_Tajima = mean(Tajima, na.rm = TRUE),
            lower_CI = mean_Tajima - 1.96 * (sd(Tajima, na.rm = TRUE) / sqrt(n())),
            upper_CI = mean_Tajima + 1.96 * (sd(Tajima, na.rm = TRUE) / sqrt(n())))

# Print result
print(tajima_summary)
# Era        mean_Tajima lower_CI upper_CI
# <chr>            <dbl>    <dbl>    <dbl>
# 1 Historical       0.352    0.211,   0.492 
# 2 Modern          -0.210   -0.385,  -0.0352

# Tajima's D Density Plot with Mean and 95% CI Lines FORMATTED 
plot_tajima_density <- angsd_thetas_depth_notrans %>%
  ggplot(aes(x = Tajima, fill = Era)) +
  labs(x = "Tajima's D", y = "Density") +
  theme_classic() +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis values
        axis.title.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis title
        axis.ticks.x = element_blank(),  # Hides x-axis ticks
        axis.text.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis values
        axis.title.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis title
        axis.ticks.length = unit(3, "pt"),  # Small tick marks
        axis.ticks = element_line(color = "black")) +  # Black tick mark
  geom_density(alpha = 0.65) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +  # Vertical dashed line at x=0
  # Add Mean Lines
  geom_vline(data = tajima_summary, aes(xintercept = mean_Tajima, color = Era), 
             linetype = "solid", alpha = 0.75, linewidth = 1) + 
  # Add 95% CI Lines
  geom_vline(data = tajima_summary, aes(xintercept = lower_CI, color = Era), 
             linetype = "dotted", alpha = 0.5, linewidth = 1) +
  geom_vline(data = tajima_summary, aes(xintercept = upper_CI, color = Era), 
             linetype = "dotted", alpha = 0.5, linewidth = 1) +
  scale_fill_manual(values = era_colors) +  # Match density fill color
  scale_color_manual(values = era_colors)   # Match vertical line color

# Print the plot
print(plot_tajima_density)

plot_tajima_density <- plot_tajima_density + 
  scale_x_continuous(breaks = seq(-2, 2, by = 2),
                     limits = c(-4, 4),
                     labels = scales::number_format(accuracy = 1)) +  # Round to 0 decimal places
  scale_y_continuous(breaks = seq(0, 1.0, by = 0.25),
                     limits = c(0, 1.0),
                     labels = scales::number_format(accuracy = 0.01))  # Round to 1 decimal place

# outFile pattern
outFile_plot_tajima <- paste0("plots/", spp_code, "_plot_tajima_neutral_mean_95", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_tajima, plot = plot_tajima_density, width = 2.15, height = 2.5)

## SCALED DENSITY
# Use stat_density() manually (advanced control)
# To normalize across all groups (so all densities share the same scaling reference)
# y range of both eras will be 0.0 to 1.0
plot_tajima_density_scale <- angsd_thetas_depth_notrans %>%
  ggplot(aes(x = Tajima, fill = Era)) +
  stat_density(
    aes(y = after_stat(density / max(density))),  # normalize to 0–1
    geom = "area", alpha = 0.65, position = "identity", color = "black", linewidth = 0.3
  ) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
  geom_vline(data = tajima_summary, aes(xintercept = mean_Tajima, color = Era),
             linetype = "solid", alpha = 0.75, linewidth = 1) +
  geom_vline(data = tajima_summary, aes(xintercept = lower_CI, color = Era),
             linetype = "dotted", alpha = 0.5, linewidth = 1) +
  geom_vline(data = tajima_summary, aes(xintercept = upper_CI, color = Era),
             linetype = "dotted", alpha = 0.5, linewidth = 1) +
  labs(x = "Tajima's D", y = "Scaled Density (0–1)") +
  theme_classic() +
  theme(
    legend.position = "none",
    axis.text.x  = element_text(family = "Times New Roman", size = 12),
    axis.title.x = element_text(family = "Times New Roman", size = 12),
    axis.ticks.x = element_blank(),
    axis.text.y  = element_text(family = "Times New Roman", size = 12),
    axis.title.y = element_text(family = "Times New Roman", size = 12),
    axis.ticks.length = unit(3, "pt"),
    axis.ticks   = element_line(color = "black")
  ) +
  scale_fill_manual(values = era_colors) +   # choose colors manually
  scale_color_manual(values = era_colors)

# Print the plot
print(plot_tajima_density_scale)

# plot_tajima_density_scale <- plot_tajima_density_scale + 
#   scale_x_continuous(breaks = seq(-2, 2, by = 2),
#                      limits = c(-4, 4),
#                      labels = scales::number_format(accuracy = 1)) +  # Round to 0 decimal places
#   scale_y_continuous(breaks = seq(0, 1.0, by = 0.25))
#                      # limits = c(0, 2.0),
#                      # labels = scales::number_format(accuracy = 0.2))  # Round to 1 decimal place

# outFile pattern
outFile_plot_tajima_scale <- paste0("plots/", spp_code, "_plot_tajima_neutral_mean_95_yscaled", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_tajima_scale, plot = plot_tajima_density_scale, width = 2.15, height = 2.5)


# FORMATTED
plot_tajima_density <- angsd_thetas_depth_notrans %>%
  ggplot(aes(x=Tajima, fill=Era)) +
  labs(x="Tajima's D",y="Density") +
  theme_classic() +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis values
        axis.title.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis title
        axis.ticks.x = element_blank(),  # Hides x-axis ticks
        axis.text.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis values
        axis.title.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis title
        axis.ticks.length = unit(3, "pt"),  # Small tick marks
        axis.ticks = element_line(color = "black")) +  # Black tick mark
  geom_density(alpha=0.65) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +  # Add vertical dashed line
  scale_fill_manual(values = c("#F8766D", "#00BFC4")) +
  scale_x_continuous(breaks = seq(-2, 2, by = 2), 
                     limits = c(-2.5, 2.5), 
                     # expand = c(0, 1.1),
                     labels = scales::number_format(accuracy = 1)) +  # Round to 0 decimal places
  scale_y_continuous(breaks = seq(0, 1.0, by = 0.2), 
                     limits = c(0, 1.1), 
                     #expand = c(0, 0.5),
                     labels = scales::number_format(accuracy = 0.1))  # Round to 1 decimal places
print(plot_tajima_density)

# outFile pattern
outFile_plot_tajima <- paste0("plots/", spp_code, "_plot_tajima_neutral_FORMAT", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_tajima, plot = plot_tajima_density, width = 2.15, height = 2.5)


# TAJIMA'S D PEAK DENSITY VALUE
# Compute density estimate for Historical
density_historical <- density(angsd_thetas_depth_notrans$Tajima[angsd_thetas_depth_notrans$Era == "Historical"], na.rm = TRUE)
peak_historical <- density_historical$x[which.max(density_historical$y)]

# Compute density estimate for Modern
density_modern <- density(angsd_thetas_depth_notrans$Tajima[angsd_thetas_depth_notrans$Era == "Modern"], na.rm = TRUE)
peak_modern <- density_modern$x[which.max(density_modern$y)]

# Print peak values
print(paste("Peak of Historical:", peak_historical)) 
# Peak of Historical: -0.00645445632998887
print(paste("Peak of Modern:", peak_modern))
# Peak of Modern: -0.594196287090002


#### FILTER: DEPTH ####

# Create a depth filter. 
# This will be different for each dataset, but modern and historical should be treated the same.
# Cha is set to 40-280X.
min_depth <- 40
max_depth <- 280


#### WRANGLE FILTERED DATA ####

angsd_thetas_depth_notrans_dp_fltr <- subset(angsd_thetas_depth_notrans, ind_depth >= min_depth & ind_depth<= max_depth)

#Subset by population
apnd_angsd_thetas_depth_notrans_dp_fltr <- subset(angsd_thetas_depth_notrans_dp_fltr, Era=="Historical")
cpnd_angsd_thetas_depth_notrans_dp_fltr <- subset(angsd_thetas_depth_notrans_dp_fltr, Era=="Modern")

# filter out any NaN
apnd_angsd_thetas_depth_notrans_dp_fltr <- apnd_angsd_thetas_depth_notrans_dp_fltr %>%
  filter(!is.na(tP_bysite) & !is.na(tW_bysite))
cpnd_angsd_thetas_depth_notrans_dp_fltr <- cpnd_angsd_thetas_depth_notrans_dp_fltr %>%
  filter(!is.na(tP_bysite) & !is.na(tW_bysite))


#### SAVE FILTERED WRANGLED DATA ####
# Ensure the 'out' directory exists
if (!dir.exists("output")) {
  dir.create("output")
}

# Outfile pattern all
outfile_all <- paste0("out/", spp_code, "_angsd_thetas_depth_notrans_dp_fltr_", Sys.Date(), ".rds")

# Save the all dataframe as an RDS file
# saveRDS(angsd_thetas_depth_notrans_dp_fltr, file = outfile_all)

# Outfile pattern apnd
outfile_all <- paste0("out/", spp_code, "_apnd_angsd_thetas_depth_notrans_dp_fltr_", Sys.Date(), ".rds")

# Save the all dataframe as an RDS file
# saveRDS(apnd_angsd_thetas_depth_notrans_dp_fltr, file = outfile_all)

# Outfile pattern cpnd
outfile_all <- paste0("out/", spp_code, "_cpnd_angsd_thetas_depth_notrans__dp_fltr_", Sys.Date(), ".rds")

# Save the all dataframe as an RDS file
# saveRDS(cpnd_angsd_thetas_depth_notrans_dp_fltr, file = outfile_all)


#### PLOTS: PI & THETA VS FILTERED DEPTH ####

# Plot of theta vs filtered depth
plot_theta_dp_fltr <- angsd_thetas_depth_notrans_dp_fltr %>%
  ggplot(aes(x=ind_depth, y=tW_bysite, color=Era)) +
  labs(x="Mean Depth per Individual",y="Theta") +
  theme_classic() +
  geom_point(size=1.5, alpha=0.5) +
  geom_smooth() +
  theme(legend.position = "none") +
  scale_color_manual(values = c("#00BFC4", "#F8766D"))

print(plot_theta_dp_fltr)

plot_grid(plot_theta_dp_fltr, plot_theta_depth,
          labels=c('A', 'B'))

# Plot of pi vs filtered depth
plot_pi_dp_fltr <- angsd_thetas_depth_notrans_dp_fltr %>%
  ggplot(aes(x=ind_depth, y=tP_bysite, color=Era)) +
  labs(x="Mean Depth per Individual",y="Nucleotide Diversity") +
  theme_classic() +
  geom_point(size=1.5, alpha=0.5) +
  geom_smooth() +
  theme(legend.position = "none") +
  scale_color_manual(values = c("#00BFC4", "#F8766D"))

print(plot_pi_dp_fltr)

plot_grid(plot_pi_dp_fltr, plot_pi_depth,
          labels=c('A', 'B'))


#### STATS: PI W/ FILTERED DEPTH ####
#Test to see if theta is normally distributed
hist(apnd_angsd_thetas_depth_notrans_dp_fltr$tP_bysite)
hist(cpnd_angsd_thetas_depth_notrans_dp_fltr$tP_bysite)
#Look's normally distributed

##Paired t-test

t.test(apnd_angsd_thetas_depth_notrans_dp_fltr$tP_bysite, cpnd_angsd_thetas_depth_notrans_dp_fltr$tP_bysite, paired=TRUE)
# Paired t-test
# 
# data:  apnd_angsd_thetas_depth_notrans_dp_fltr$tP_bysite and cpnd_angsd_thetas_depth_notrans_dp_fltr$tP_bysite
# t = 8.096, df = 114, p-value = 6.929e-13
# alternative hypothesis: true mean difference is not equal to 0
# 95 percent confidence interval:
#   0.003880103 0.006394059
# sample estimates:
#   mean difference 
# 0.005137081

#Bootstrapping of pi
x = as.vector(apnd_angsd_thetas_depth_notrans_dp_fltr$tP_bysite)

samplemean <- function(x, d) {
  return(mean(x[d]))
}

apnd_boot_dp_fltr = boot(x, samplemean, R=1000)

apnd_boot_dp_fltr
plot(apnd_boot_dp_fltr)
# Bootstrap Statistics :
# original       bias    std. error
# t1* 0.08410675 6.436687e-06 0.001257345

boot.ci(boot.out=apnd_boot_dp_fltr, type="norm") #95%   ( 0.0816,  0.0866 ) 
boot.ci(boot.out=apnd_boot_dp_fltr, type="bca") #95%   ( 0.0818,  0.0866 )

x = as.vector(cpnd_angsd_thetas_depth_notrans_dp_fltr$tP_bysite)
cpnd_boot_dp_fltr = boot(x, samplemean, R=1000)

cpnd_boot_dp_fltr
plot(cpnd_boot_dp_fltr)
# Bootstrap Statistics :
# original        bias    std. error
# t1* 0.07896967 -5.063318e-05 0.001314533

boot.ci(boot.out=cpnd_boot_dp_fltr, type="norm") #95%   ( 0.0764,  0.0816 )
boot.ci(boot.out=cpnd_boot_dp_fltr, type="bca") #95%   ( 0.0764,  0.0815 )

##Create data frame with means and 95% CI for plotting
population <- c("APnd","CPnd")
location <- c("Pandanon Island", "Pandanon Island")
mean_pi <- c(0.08410675, 0.07896967)
se_pi <- c(0.001257345, 0.001314533)
era <- c("Historical", "Modern")


#### PLOTS: PI W/ FILTERED DEPTH ####
df_neutral_theta_pi <- data.frame(era, location, mean_pi, se_pi)
df_neutral_theta_pi$location <- factor(df_neutral_theta_pi$location, levels=c("Pandanon Island"))
df_neutral_theta_pi$era <- factor(df_neutral_theta_pi$era, levels=c("Historical", "Modern"))

plot_pi <- df_neutral_theta_pi %>%
  ggplot(aes(x=era, y=mean_pi, color=era)) +
  labs(y="Mean Pi") +
  theme_classic() +
  theme(legend.position="none") +
  geom_point(size=2) +
  geom_errorbar(aes(ymin=mean_pi-1.96*se_pi, ymax=mean_pi+1.96*se_pi), width=0.0) +
  ylim(0.07, 0.09) +
  scale_color_manual(values = c("#F8766D", "#00BFC4"))
print(plot_pi)

# FORMATTED
plot_pi <- df_neutral_theta_pi %>%
  ggplot(aes(x = era, y = mean_pi, color = era)) +
  labs(y = "Mean Pi") +
  theme_classic() +
  theme(legend.position = "none",
        axis.text.x = element_blank(),  # Hides x-axis labels
        axis.title.x = element_blank(),  # Hides x-axis title
        axis.ticks.x = element_blank(),  # Hides x-axis ticks
        axis.text.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis values
        axis.title.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis title
        axis.ticks.length = unit(3, "pt"),  # Small tick marks
        axis.ticks = element_line(color = "black")) +  # Black tick mark
  geom_point(size = 2, position = position_dodge(width = 0.3)) +  
  geom_errorbar(aes(ymin = mean_pi - 1.96 * se_pi, ymax = mean_pi + 1.96 * se_pi),
                width = 0.1, position = position_dodge(width = 0.3)) +  
  ylim(0.0, 0.15) +  # Adjusted to fit your data
  scale_color_manual(values = c("#F8766D", "#00BFC4")) 
print(plot_pi)

# outFile pattern
outFile_plot_pi <- paste0("plots/", spp_code, "_plot_pi_FORMAT_dp_fltr", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_pi, plot = plot_pi, width = 2.15, height = 2.5)


#### STATS: THETA W/ FILTERED DEPTH ####
#Test to see if theta is normally distributed
hist(apnd_angsd_thetas_depth_notrans_dp_fltr$tW_bysite)
hist(cpnd_angsd_thetas_depth_notrans_dp_fltr$tW_bysite)
#Looks normally distributed

##Paired t-test
t.test(apnd_angsd_thetas_depth_notrans_dp_fltr$tW_bysite, cpnd_angsd_thetas_depth_notrans_dp_fltr$tW_bysite, paired=TRUE)

# Paired t-test
# 
# data:  apnd_angsd_thetas_depth_notrans_dp_fltr$tW_bysite and cpnd_angsd_thetas_depth_notrans_dp_fltr$tW_bysite
# t = -19.271, df = 114, p-value < 2.2e-16
# alternative hypothesis: true mean difference is not equal to 0
# 95 percent confidence interval:
#   -0.01257159 -0.01022786
# sample estimates:
#   mean difference 
# -0.01139972 

#Bootstrapping of theta
x = as.vector(apnd_angsd_thetas_depth_notrans_dp_fltr$tW_bysite)

samplemean <- function(x, d) {
  return(mean(x[d]))
}

apnd_boot_dp_fltr = boot(x, samplemean, R=1000)

apnd_boot_dp_fltr
plot(apnd_boot_dp_fltr)
# original       bias    std. error
# t1* 0.07493033 3.547239e-05 0.000797727

boot.ci(boot.out=apnd_boot_dp_fltr, type="norm") #95%   ( 0.0733,  0.0765 ) 
boot.ci(boot.out=apnd_boot_dp_fltr, type="bca") #95%   ( 0.0733,  0.0765 ) 

x = as.vector(cpnd_angsd_thetas_depth_notrans_dp_fltr$tW_bysite)
cpnd_boot_dp_fltr = boot(x, samplemean, R=1000)

cpnd_boot_dp_fltr
plot(cpnd_boot_dp_fltr)
# original        bias     std. error
# t1* 0.08633005 7.362039e-07 0.0007141357

boot.ci(boot.out=cpnd_boot_dp_fltr, type="norm") #95%   ( 0.0849,  0.0877 ) 
boot.ci(boot.out=cpnd_boot_dp_fltr, type="bca") #95%   ( 0.0849,  0.0878 )

##Create data frame with means and 95% CI for plotting
population <- c("APnd","CPnd")
location <- c("Pandanon Island", "Pandanon Island")
mean_theta <- c(0.07493033, 0.08633005)
se_theta <- c(0.000797727, 0.0007141357)
era <- c("Historical", "Modern")


#### PLOTS: THETA W/ FILTERED DEPTH ####
theta_plotting <- data.frame(population, era, location, mean_theta, se_theta)
theta_plotting$location <- factor(theta_plotting$location, levels=c("Pandanon Island"))
theta_plotting$era <- factor(theta_plotting$era, levels=c("Historical", "Modern"))

# FORMATTED
plot_theta <- theta_plotting %>%
  ggplot(aes(x = era, y = mean_theta, color = era)) +
  labs(y = "Mean Theta") +
  theme_classic() +
  theme(legend.position = "none",
        axis.text.x = element_blank(),  # Hides x-axis labels
        axis.title.x = element_blank(),  # Hides x-axis title
        axis.ticks.x = element_blank(),  # Hides x-axis ticks
        axis.text.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis values
        axis.title.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis title
        axis.ticks.length = unit(3, "pt"),  # Small tick marks
        axis.ticks = element_line(color = "black")) +  # Black tick mark
  geom_point(size = 2, position = position_dodge(width = 0.3)) +  
  geom_errorbar(aes(ymin = mean_theta - 1.96 * se_pi, ymax = mean_theta + 1.96 * se_theta),
                width = 0.1, position = position_dodge(width = 0.3)) +  
  ylim(0.00, 0.15) +  # Adjusted to fit your data
  scale_color_manual(values = c("#F8766D", "#00BFC4")) 
print(plot_theta)

# outFile pattern
outFile_plot_theta <- paste0("plots/", spp_code, "_plot_theta_neutral_FORMAT_dp_fltr", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta, plot = plot_theta, width = 2.15, height = 2.5)


#### PLOTS: TAJIMA'S D W/ FILTERED DEPTH #### 
# Function to compute mean and 95% CI
calculate_mean_ci <- function(data) {
  n <- sum(!is.na(data$Tajima))  # Count non-NA values
  mean_val <- mean(data$Tajima, na.rm = TRUE)
  se_val <- sd(data$Tajima, na.rm = TRUE) / sqrt(n)  # Standard Error (SE)
  ci_lower <- mean_val - 1.96 * se_val  # Lower bound of 95% CI
  ci_upper <- mean_val + 1.96 * se_val  # Upper bound of 95% CI
  
  return(data.frame(mean_Tajima = mean_val, lower_CI = ci_lower, upper_CI = ci_upper))
}

# Apply the function to each Era
tajima_summary <- angsd_thetas_depth_notrans_dp_fltr %>%
  group_by(Era) %>%
  summarise(mean_Tajima = mean(Tajima, na.rm = TRUE),
            lower_CI = mean_Tajima - 1.96 * (sd(Tajima, na.rm = TRUE) / sqrt(n())),
            upper_CI = mean_Tajima + 1.96 * (sd(Tajima, na.rm = TRUE) / sqrt(n())))

# Print result
print(tajima_summary)

# Define colors to match the density fill but with lower transparency for lines
era_colors <- c("Historical" = "#F8766D", "Modern" = "#00BFC4")

# Tajima's D Density Plot with Mean and 95% CI Lines
plot_tajima_density <- angsd_thetas_depth_notrans_dp_fltr %>%
  ggplot(aes(x = Tajima, fill = Era)) +
  labs(x = "Tajima's D", y = "Density") +
  theme_classic() +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis values
        axis.title.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis title
        axis.ticks.x = element_blank(),  # Hides x-axis ticks
        axis.text.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis values
        axis.title.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis title
        axis.ticks.length = unit(3, "pt"),  # Small tick marks
        axis.ticks = element_line(color = "black")) +  # Black tick mark
  geom_density(alpha = 0.65) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +  # Vertical dashed line at x=0
  # Add Mean Lines
  geom_vline(data = tajima_summary, aes(xintercept = mean_Tajima, color = Era), 
             linetype = "solid", alpha = 0.75, linewidth = 1) + 
  # Add 95% CI Lines
  geom_vline(data = tajima_summary, aes(xintercept = lower_CI, color = Era), 
             linetype = "dotted", alpha = 0.5, linewidth = 1) +
  geom_vline(data = tajima_summary, aes(xintercept = upper_CI, color = Era), 
             linetype = "dotted", alpha = 0.5, linewidth = 1) +
  scale_fill_manual(values = era_colors) +  # Match density fill color
  scale_color_manual(values = era_colors) +  # Match vertical line color
  scale_x_continuous(breaks = seq(-2, 2, by = 2), 
                     limits = c(-2.5, 2.5), 
                     labels = scales::number_format(accuracy = 1)) +  # Round to 0 decimal places
  scale_y_continuous(breaks = seq(0, 1.0, by = 0.2), 
                     limits = c(0, 1.2), 
                     labels = scales::number_format(accuracy = 0.1))  # Round to 1 decimal place

# Print the plot
print(plot_tajima_density)

#FORMAT
plot_tajima_density <- angsd_thetas_depth_notrans %>%
  ggplot(aes(x=Tajima, fill=Era)) +
  labs(x="Tajima's D",y="Density") +
  theme_classic() +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis values
        axis.title.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis title
        axis.ticks.x = element_blank(),  # Hides x-axis ticks
        axis.text.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis values
        axis.title.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis title
        axis.ticks.length = unit(3, "pt"),  # Small tick marks
        axis.ticks = element_line(color = "black")) +  # Black tick mark
  geom_density(alpha=0.65) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black") +  # Add vertical dashed line
  scale_fill_manual(values = c("#F8766D", "#00BFC4")) +
  scale_x_continuous(breaks = seq(-2, 2, by = 2), 
                     limits = c(-2.5, 2.5), 
                     # expand = c(0, 1.1),
                     labels = scales::number_format(accuracy = 1)) +  # Round to 0 decimal places
  scale_y_continuous(breaks = seq(0, 1.0, by = 0.2), 
                     limits = c(0, 1.1), 
                     #expand = c(0, 0.5),
                     labels = scales::number_format(accuracy = 0.1))  # Round to 1 decimal places
print(plot_tajima_density)

# outFile pattern
outFile_plot_tajima <- paste0("plots/", spp_code, "_plot_tajima_neutral_FORMAT_dp_fltr_mean_95", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_tajima, plot = plot_tajima_density, width = 2.15, height = 2.5)


# TAJIMA'S D PEAK DENSITY VALUE
# Compute density estimate for Historical
density_historical <- density(angsd_thetas_depth_notrans$Tajima[angsd_thetas_depth_notrans$Era == "Historical"], na.rm = TRUE)
peak_historical <- density_historical$x[which.max(density_historical$y)]

# Compute density estimate for Modern
density_modern <- density(angsd_thetas_depth_notrans$Tajima[angsd_thetas_depth_notrans$Era == "Modern"], na.rm = TRUE)
peak_modern <- density_modern$x[which.max(density_modern$y)]

# Print peak values
print(paste("Peak of Historical:", peak_historical)) 
# Peak of Historical: 0.561361420722892
print(paste("Peak of Modern:", peak_modern))
# Peak of Modern: -0.427412044847865

plot_tajima <- angsd_thetas_depth_notrans %>%
  ggplot(aes(x=Tajima, fill=Era)) +
  labs(x="Tajima's D",y="Density") +
  theme_classic() +
  theme(legend.position = "none",
        axis.text.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis values
        axis.title.x = element_text(family = "Times New Roman", size = 12),  # Font for x-axis title
        axis.ticks.x = element_blank(),  # Hides x-axis ticks
        axis.text.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis values
        axis.title.y = element_text(family = "Times New Roman", size = 12),  # Font for y-axis title
        axis.ticks.length = unit(3, "pt"),  # Small tick marks
        axis.ticks = element_line(color = "black")) +  # Black tick mark
  geom_density(alpha=0.65) +
  scale_fill_manual(values = c("#F8766D", "#00BFC4")) +
  print(plot_tajima)

plot_grid(bol_tajima_all, mta_tajima_all,
          labels=c('A', 'B'))
