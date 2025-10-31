#### Testing for Selection with χ² tests from the package ACER
# 1 species, 2 time points (modern = C, historical = A), 1 site
# only 1 site means that there are no temporal replicates 
# i.e. only 1 site means that there are no replicates
# no replicates means that the CMH Test cannot be conducted

####################
#### INITIALIZE ####
####################
# set working directory

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))



##################
#### PACKAGES ####
##################
#Adjusted chi-squared test using the ACER package
packages_used <- 
  c("ACER",
    "tidyverse",
    "cowplot",
    "Cairo",
    "ggplot2",
    "dplyr"
  )

# library(data.table)
# library(ggtext)
# library(purrr)

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



################################
#### USER DEFINED VARIABLES ####
################################
# SPECIES-SPECIFIC USER DEFINED ARGUMENTS FOR ADAPTED CHI SQUARED TEST
spp  = "sin"
site = "pnd"

## Effective population size (Ne)
# Jorde-Ryman estimates & number of generations based on difference between Historical & Modern sampling years
Ne = 100

## Generations (gen) based on sampling years 
a_year = 1909 # 3/24/1909
c_year = 2021 # 11/5/2021

# Generation time calculated from FishLife
gen_time = 2.89

# Generations. Round to the nearest whole number
max = round((c_year - a_year)/gen_time) # 39
min = 0  
# gen is a numeric vector with 0 for the first generation
gen <- c(min, max)
# gen <- c(0, 39)



#######################
#### READ IN FILES ####
#######################
## Minor allele frequency output files from ANGSD
apnd_mafs <- fread("APnd_sites_notrans.mafs.gz", header=TRUE)
cpnd_mafs <- fread("CPnd_sites_notrans.mafs.gz", header=TRUE)

# Create minor allele frequency matrix
apnd_cpnd_freq <- data.frame(apnd_maf = apnd_mafs$knownEM, 
                             cpnd_maf = cpnd_mafs$knownEM)

## Coverage output files from ANGSD
apnd_pos <- fread("APnd_sites_notrans.pos.gz", header=TRUE)
cpnd_pos <- fread("CPnd_sites_notrans.pos.gz", header=TRUE)

# Create coverage matrix
apnd_cpnd_cov_mat <- data.frame(apnd_totDepth = apnd_pos$totDepth,
                                cpnd_totDepth = cpnd_pos$totDepth)

## Load global SNP list output file from ANGSD
snp_list <- fread("global_snp_list_depth1_15_notrans.txt", header = FALSE)

## Load region list output file from ANGSD
reg_list <- fread("global_snp_list_depth1_15_notrans.regions", header = FALSE)


##########################
#### ADAPTED χ² TESTS ####
##########################
## ACER adpated chi-square test to generate p-values & test statistic for each SNP
pnd_pval <- data.frame(
  adapted.chisq.test(freq     = apnd_cpnd_freq,      # allele frequency matrix. rows are SNPs, columns are temporal populations
                     coverage = apnd_cpnd_cov_mat,  # coverage matrix. rows are SNPs, columns are temporal populations
                     Ne       = Ne,
                     gen      = gen,
                     IntGen   = FALSE, # Only two generations so this should be FALSE. If there are intermediate generations to the first & last then this would be TRUE
                     RetVal   = 2 # 2 = matrix of test statistic in 1st column and p-values in the 2nd. 1 = test statistic. 0 = p-values.
  ))

# Significant SNPS
pnd_sel_sig_pval_05_count   <- as.numeric(sum(pnd_pval$p.value < 0.05)) # 1740 SNPs with p-value <0.05 
pnd_sel_sig_pval_01_count   <- as.numeric(sum(pnd_pval$p.value < 0.01)) # 1614 SNPs with p-value <0.01


## FDR Adjustment
# Use p.adjust() function to perform an FDR correction on p-values
pnd_pval$fdr <- p.adjust(pnd_pval$p.value, method = "fdr") 

# FDR-adjusted Significant SNPS
total_snps                <- as.numeric(nrow(apnd_cpnd_freq))    # total SNPs
pnd_sel_sig_fdr_05_count  <- as.numeric(sum(pnd_pval$fdr<0.05))  # SNPs with q-value <0.05
pnd_sel_sig_fdr_01_count  <- as.numeric(sum(pnd_pval$fdr<0.01))  # SNPs with p-value <0.01
pnd_sel_sig_fdr_05_per    <- as.numeric(100 * pnd_sel_sig_fdr_05_count / total_snps) # of SNPS
pnd_sel_sig_fdr_01_per    <- as.numeric(100 * pnd_sel_sig_fdr_01_count / total_snps) # of SNPS



##########################################################
#### COMBINE ACER OUTPUT WITH MAF & COVERAGE MATRICES ####
##########################################################
pnd_sel          <- cbind(pnd_pval, apnd_cpnd_freq)
pnd_sel$position <- cpnd_mafs$position
pnd_sel$chromo   <- cpnd_mafs$chromo

# Create chrpos identifiers for all SNPs. This is the same as the single column in the .regions files. 
pnd_sel <- pnd_sel %>%
  mutate(chrpos = paste(chromo, position, sep = ":"))

# Compute cumulative genomic position
pnd_sel <- pnd_sel  %>%
  group_by(chromo) %>%
  mutate(chr_len = max(position, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(chr_start = ave(chr_len, chromo, FUN = function(x)
    cumsum(c(0, head(x, -1))))[as.numeric(factor(chromo))],
    pos_cum = position + chr_start)

# calculate -log10 fdr for manhattan plot
pnd_sel <- pnd_sel  %>%
  mutate(neg_log_10_fdr = -log10(fdr))

# calculate change in minor allele frequency over time
pnd_sel$change       <- pnd_sel$cpnd_maf - pnd_sel$apnd_maf      # change (modern - historical) is relative
pnd_sel$change_abs   <- abs(pnd_sel$cpnd_maf - pnd_sel$apnd_maf) # absolute change is more informative

# Number of SNPs at each significance level
cat("Species: ", spp, " at Site: ", site, " has a total of ", total_snps, " SNPs, with ",
    pnd_sel_sig_fdr_05_count, " SNPs < 0.05 (", pnd_sel_sig_fdr_05_per, "% ) and", 
    pnd_sel_sig_fdr_01_count, " SNPs < 0.01 (", pnd_sel_sig_fdr_01_per, "% ) using FDR-corrected p-values.")
# Species:  sin  at Site:  pnd  has a total of  2106  SNPs, with  1730  SNPs < 0.05 ( 82.14625 % ) and 1572  SNPs < 0.01 ( 74.64387 % ) using FDR-corrected p-values.

# rename p.value
pnd_sel <- pnd_sel %>%
  rename(p_value = p.value)

# reorder
pnd_sel <- pnd_sel %>%
  dplyr::select(apnd_maf, cpnd_maf, change_abs, change, 
         chrpos, chromo, position, chr_len, chr_start, pos_cum, 
         fdr, neg_log_10_fdr, p_value, test_statistic)

# Pivot to long format
pnd_sel_long <- pnd_sel %>%
  pivot_longer(cols = c(apnd_maf, cpnd_maf), 
               names_to = "era", 
               values_to = "allele_freq") %>%
  mutate(
    era = recode(era, apnd_maf = "Historical", cpnd_maf = "Modern")) %>%
  # Add allele frequency 3 bins
  mutate(
    allele_freq_bin_3 = case_when(
      allele_freq < 0.25 ~ "< 0.25",
      allele_freq >= 0.25 & allele_freq <= 0.75 ~ "0.25–0.75",
      allele_freq > 0.75 ~ "> 0.75",
      TRUE ~ NA_character_
    )) %>%
  # Add allele frequency 5 bins
  mutate( 
    allele_freq_bin_5 = case_when(
      allele_freq == 0                           ~ "= 0.00",
      allele_freq > 0 & allele_freq < 0.25       ~ "< 0.25",
      allele_freq >= 0.25 & allele_freq <= 0.75  ~ "0.25–0.75",
      allele_freq > 0.75 & allele_freq < 1.0     ~ "> 0.75",
      allele_freq == 1.0                         ~ "= 1.00",
      TRUE ~ NA_character_
    ))


## SUMMARY TABLE W/ 3 BINS
# Counts for all SNPs by 3-bin scheme
counts_all_bin3 <- pnd_sel_long %>%
  group_by(allele_freq_bin_3, era) %>%
  summarise(n_all = n(), .groups = "drop") %>%
  pivot_wider(names_from = era, values_from = n_all,
              names_prefix = "n_", values_fill = 0) %>%
  rename(n_his_all = n_Historical, n_mod_all = n_Modern)

# Counts for significant SNPs by 3-bin scheme
counts_sig_bin3 <- pnd_sel_long %>%
  filter(fdr < 0.05) %>%
  group_by(allele_freq_bin_3, era) %>%
  summarise(n_sig = n(), .groups = "drop") %>%
  pivot_wider(names_from = era, values_from = n_sig,
              names_prefix = "n_", values_fill = 0) %>%
  rename(n_his_sig = n_Historical, n_mod_sig = n_Modern)

# Join into one table
final_maf_bin_summary_3 <- counts_all_bin3 %>%
  full_join(counts_sig_bin3, by = "allele_freq_bin_3") %>%
  arrange(factor(allele_freq_bin_3, levels = c("< 0.25", "0.25–0.75", "> 0.75")))

print(final_maf_bin_summary_3)
# fwrite(final_maf_bin_summary_3, paste0("./output/", spp, "_pnd_selection_snps_maf_bins_3.txt"), sep = "\t")


## SUMMARY TABLE W/ 5 BINS
# Counts for all SNPs by 5-bin scheme
counts_all_bin5 <- pnd_sel_long %>%
  group_by(allele_freq_bin_5, era) %>%
  summarise(n_all = n(), .groups = "drop") %>%
  pivot_wider(names_from = era, values_from = n_all,
              names_prefix = "n_", values_fill = 0) %>%
  rename(n_his_all = n_Historical, n_mod_all = n_Modern)

# Counts for significant SNPs by 5-bin scheme
counts_sig_bin5 <- pnd_sel_long %>%
  filter(fdr < 0.05) %>%
  group_by(allele_freq_bin_5, era) %>%
  summarise(n_sig = n(), .groups = "drop") %>%
  pivot_wider(names_from = era, values_from = n_sig,
              names_prefix = "n_", values_fill = 0) %>%
  rename(n_his_sig = n_Historical, n_mod_sig = n_Modern)

# Join into one table
final_maf_bin_summary_5 <- counts_all_bin5 %>%
  full_join(counts_sig_bin5, by = "allele_freq_bin_5") %>%
  arrange(factor(allele_freq_bin_5, 
                 levels = c("= 0.00", "< 0.25", "0.25–0.75", "> 0.75", "= 1.00")))

print(final_maf_bin_summary_5)
# fwrite(final_maf_bin_summary_5, paste0("./output/", spp, "_pnd_selection_snps_maf_bins_5.txt"), sep = "\t")


## Create significant (FDR) matrices
# Filter site-delimited frequency matrix for SNPs with an FDR-adjusted p-value < 0.05 
pnd_sel_sig_fdr_05 <- pnd_sel %>% filter(fdr < 0.05)

# Filter site-era delimited frequency matrix for SNPs with an FDR-adjusted p-value < 0.05 
pnd_sel_sig_fdr_05_long <- pnd_sel_long %>% filter(fdr < 0.05)

# reorder
pnd_sel_sig_fdr_05_long <- pnd_sel_sig_fdr_05_long %>%
  dplyr::select(era, allele_freq, allele_freq_bin_3, allele_freq_bin_5,
                chrpos, chromo, position, chr_len, chr_start, pos_cum, 
                fdr, neg_log_10_fdr, p_value, test_statistic)

## SAVE FREQUENCY MATRICES ##
# fwrite(pnd_sel,                 paste0("./output/", spp, "_pnd_selection_snps_all.txt"), sep = "\t")
# fwrite(pnd_sel_long,            paste0("./output/", spp, "_pnd_selection_snps_all_long.txt"), sep = "\t")
# fwrite(pnd_sel_sig_fdr_05,      paste0("./output/", spp, "_pnd_selection_snps_sig_pval_fdr_05.txt"), sep = "\t")
# fwrite(pnd_sel_sig_fdr_05_long, paste0("./output/", spp, "_pnd_selection_snps_sig_pval_fdr_05_long.txt"), sep = "\t")



##############################
#### MANHATTAN PLOT (FDR) ####
##############################
# Generate cumulative genomic position dataframe for the x-axis of the manhattan plot 
axis_df <- pnd_sel  %>%
  group_by(chromo) %>%
  summarize(center = mean(pos_cum, na.rm = TRUE))

#Significance threshold for plot
sig_threshold_05 <- 0.05
sig_line_05      <- -log10(sig_threshold_05)
sig_threshold_01 <- 0.01
sig_line_01      <- -log10(sig_threshold_01)

## Manhattan plot: sig threshold = 0.05, no y-axis adjustment
# color should not be the same as the eras because color is by position (chromo)
manhattan_plot <- ggplot(pnd_sel, aes(x = pos_cum, y = -log10(fdr), color = as.factor(chromo))) +
  geom_point(alpha = 0.6, size = 0.8) +
  scale_color_manual(values = rep(c("#0a057d", "#b87005"), length(unique(pnd_sel$chromo)))) +
  scale_x_continuous(
    breaks = axis_df$center,
    labels = as.numeric(gsub("[^0-9]", "", axis_df$chromo)),  # extract numbers only
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  geom_hline(yintercept = sig_line_05, color = "black", linetype = "dashed", linewidth = 0.7) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(
    x = "Position",
    y = expression(-log[10](FDR)),
    title = paste0(spp, " ", site, ": Manhattan Plot - Genome-wide χ² Test")) +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "none",
    panel.border = element_rect(color = "black"),
    axis.title   = element_text(family = "Times New Roman", size = 12, face = "bold"),  # Font for axis titles
    axis.text.x  = element_text(size = 10, angle = 90, family = "Times New Roman"),
    axis.text.y  = element_text(size = 10, family = "Times New Roman"),
    plot.title   = element_text(face = "bold", hjust = 0.5)
  )

print(manhattan_plot)
# ggsave(paste0("./plots/", spp, "_plot_manhattan_fdr_05.png"), manhattan_plot, width = 20, height = 10, dpi = 300)


## Manhattan plot: sig threshold = 0.05, ylim = 10
# color should not be the same as the eras because color is by position (chromo)
manhattan_plot <- ggplot(pnd_sel, aes(x = pos_cum, y = -log10(fdr), color = as.factor(chromo))) +
  geom_point(alpha = 0.6, size = 0.8) +
  scale_color_manual(values = rep(c("#0a057d", "#b87005"), length(unique(pnd_sel$chromo)))) +
  scale_x_continuous(
    breaks = axis_df$center,
    labels = as.numeric(gsub("[^0-9]", "", axis_df$chromo)),  # extract numbers only
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  geom_hline(yintercept = sig_line_05, color = "black", linetype = "dashed", linewidth = 0.7) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(
    x = "Position",
    y = expression(-log[10](FDR)),
    title = paste0(spp, " ", site, ": Manhattan Plot - Genome-wide χ² Test")) +
  coord_cartesian(ylim = c(0, 10)) +
  # annotate("text", x = 0, y = sig_line + 0.5, label = "FDR-adjusted p-value = 0.05",  size = 4, color = "black", hjust = 0, family = "Times New Roman") +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "none",
    panel.border = element_rect(color = "black"),
    axis.title   = element_text(family = "Times New Roman", size = 12, face = "bold"),  # Font for axis titles
    axis.text.x  = element_text(size = 10, angle = 90, family = "Times New Roman"),
    axis.text.y  = element_text(size = 10, family = "Times New Roman"),
    plot.title   = element_text(face = "bold", hjust = 0.5)
  )

print(manhattan_plot)
# ggsave(paste0("./plots/", spp, "_plot_manhattan_fdr_05_ylim_10.png"), manhattan_plot, width = 20, height = 10, dpi = 300)



###################################
#### CMH Test Across All Sites ####
###################################

# DOES NOT APPLY BECAUSE ONLY 1 SITE
# THIS MEANS THERE ARE NO REPLICATES



###############################################
#### PLOTS - ALLELE FREQUENCY DISTRIBUTION ####
###############################################
# Generate density plots & histograms for significant loci (FDR-adjusted p-values < 0.05)
# use site-era delimited long format dataframe: pnd_sel_sig_fdr_05_long

# Plot Historical over Modern
# pnd_sel_sig_fdr_05_long$era <- factor(pnd_sel_sig_fdr_05_long$era, levels = c("Modern", "Historical"))

# Plot Modern over Historical
# pnd_sel_sig_fdr_05_long$era <- factor(pnd_sel_sig_fdr_05_long$era, levels = c("Historical", "Modern"))


## DENSITY ##
plot_density_afd_fdr <- 
  ggplot(pnd_sel_sig_fdr_05_long, aes(x = allele_freq, color = era, fill = era)) +
  # geom_density(alpha = 0.4) +
  geom_density(alpha = 0.5, linewidth = 1, bw = 0.04) +
  theme_classic() +
  labs(title = paste0(spp, " ", site, ": Allele Frequency Distribution of SNPs Putatively Under Selection by Era (bw = 0.04)"),
       x = "Allele Frequency",
       y = "Density") +
  scale_fill_manual(values  = c("Historical" = "#F8766D", "Modern" = "#00BFC4")) +
  scale_color_manual(values = c("Historical" = "#F8766D", "Modern" = "#00BFC4")) +
  scale_y_continuous(breaks = seq(0, 10, by = 2.5),
                     limits = c(0, 10)) +
  scale_x_continuous(breaks = seq(0, 1.0, by = 0.25),
                     limits = c(0, 1)) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.title = element_blank(),
    legend.position = "right",
    legend.text = element_text(family = "Times New Roman", size = 12),
    axis.text   = element_text(family   = "Times New Roman", size = 12),  # Font for axis values
    axis.title  = element_text(family  = "Times New Roman", size = 12, face = "bold"),  # Font for axis titles
  )

print(plot_density_afd_fdr)
# ggsave(paste0("./plots/", spp, "_plot_selection_afd_density_fdr_05_mod.png"), plot_density_afd_fdr, width = 20, height = 10, dpi = 300)


## HISTOGRAM ##
plot_histo_afd_fdr <- 
  ggplot(pnd_sel_sig_fdr_05_long, aes(x = allele_freq, fill = era, color = era)) +
  geom_histogram(position = "identity", alpha = 0.5, bins = 20) +
  theme_classic() +
  labs(title = paste0(spp, " ", site, ": Allele Frequency Distribution of SNPs Putatively Under Selection by Era (bins = 20)"),
       x = "Allele Frequency",
       y = "Count") +
  scale_color_manual(values = c("Historical" = "#F8766D", "Modern" = "#00BFC4")) +
  scale_fill_manual(values  = c("Historical" = "#F8766D", "Modern" = "#00BFC4")) +
  # scale_y_continuous(breaks = seq(0, 30, by = 5),
  #                    limits = c(0, 30)) +
  # coord_cartesian(xlim = c(0, 1)) +
  # scale_x_continuous(breaks = seq(0, 1.0, by = 0.25),
  #                    limits = c(0, 1)) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.title = element_blank(),
    legend.position = "right",
    legend.text = element_text(family = "Times New Roman", size = 12),
    axis.text = element_text(family   = "Times New Roman", size = 12),  # Font for axis values
    axis.title = element_text(family  = "Times New Roman", size = 12, face = "bold"),  # Font for axis titles
  )

print(plot_histo_afd_fdr)
# ggsave(paste0("./plots/", spp, "_plot_selection_afd_histo_fdr_05_bins_20_mod.png"), plot_histo_afd_fdr, width = 20, height = 10, dpi = 300)



#################################
#### CREATE NEUTRAL SNP LIST ####
#################################
## Use Global SNP list output file (snp_list) from ANGSD with all SNPs
# Create unique chrpos (regions) identifiers
snp_list$chrpos <- paste(snp_list$V1, snp_list$V2, sep = ":")

# rename V1 to chrpos in reg_list
reg_list <- reg_list %>%
  rename(chrpos = V1)

# count SNPs in snp_list and pnd_sel
n_distinct(snp_list$chrpos) # 2108
n_distinct(reg_list$chrpos) # 2108
n_distinct(pnd_sel$chrpos)  # 2106


## Check missing SNPs
# Check which SNPs are missing from pnd_sel that are in snp_list
missing_snps <- setdiff(snp_list$chrpos, pnd_sel$chrpos)
print(missing_snps)
# missing 2 SNPs
# NODE_1864_length_30503_cov_9.525359:20265, NODE_1864_length_30503_cov_9.525359:20266

# Check which SNPs are missing from pnd_sel that are in reg_list
missing_snps_reg <- setdiff(reg_list$chrpos, pnd_sel$chrpos)
print(missing_snps_reg)
# missing 2 SNPs
# NODE_1864_length_30503_cov_9.525359:20265, NODE_1864_length_30503_cov_9.525359:20266

# filter out missing SNPs from snp_list
snp_list <- snp_list %>%
  filter(!(chrpos %in% missing_snps))

# filter out missing SNPs from reg_list
reg_list <- reg_list %>%
  filter(!(chrpos %in% missing_snps_reg))


### Create neutral lists
## SNPs
# Rename significant SNPs dataframe to sig_snps
sig_snps <- pnd_sel_sig_fdr_05
n_distinct(sig_snps$chrpos)  # 1730

# Filter out significant SNPs to keep only neutral ones
snp_list_neutral <- snp_list %>%
  filter(!(chrpos %in% sig_snps$chrpos))
n_distinct(snp_list_neutral$chrpos)  # 376

# Check how many SNPs were filtered
cat("Original SNPs:", nrow(snp_list), "\n")
# Original SNPs: 2106
cat("Significant SNPs (FDR < 0.05):", nrow(sig_snps), "\n")
# Significant SNPs (FDR < 0.05): 1730
cat("Neutral SNPs remaining:", nrow(snp_list_neutral), "\n")
# Neutral SNPs remaining: 376

# Export the neutral SNP list (first 4 columns only)
neutral_outfile <- "neutral_fdr_snp_list_depth1_15_notrans.txt"
# write.table(
#   snp_list_neutral[, 1:4],
#   neutral_outfile,
#   sep = "\t",
#   row.names = FALSE,
#   col.names = FALSE,
#   quote = FALSE
# )
cat("Neutral SNP list saved as:", neutral_outfile, "\n")


## Chromosomes
# Check chromosome counts
cat("Original unique chromosomes:", length(unique(snp_list$V1)), "\n")
# Original unique chromosomes: 313
cat("Neutral unique chromosomes:", length(unique(snp_list_neutral$V1)), "\n")
# Neutral unique chromosomes: 197

# make neutral chr list
chr_list_neutral <- data.frame(chr = sort(unique(snp_list_neutral$V1)))
nrow(chr_list_neutral) # 197

# Export chromosome list for ANGSD input
neutral_chr_outfile <- "neutral_fdr_snp_list_depth1_15_notrans.chrs"
# write.table(
#   data.frame(chr_list_neutral$chr),
#   neutral_chr_outfile,
#   row.names = FALSE,
#   col.names = FALSE,
#   quote = FALSE
# )
cat("Neutral chromosome list saved as:", neutral_chr_outfile, "\n")


## Regions
# Filter out significant regions to keep only neutral ones
reg_list_neutral <- reg_list %>%
  filter(!(chrpos %in% sig_snps$chrpos))
n_distinct(reg_list_neutral$chrpos)  # 376

# Check region counts
cat("Original unique regions:", length(unique(reg_list$chrpos)), "\n")
# Original unique regions: 2106
cat("Neutral unique regions:", length(unique(reg_list_neutral$chrpos)), "\n")
# Neutral unique regions: 376

#Export regions list for ANGSD input
neutral_reg_outfile <- "neutral_fdr_snp_list_depth1_15_notrans.regions"
# write.table(
#   data.frame(reg_list_neutral$chrpos),
#   neutral_reg_outfile,
#   row.names = FALSE,
#   col.names = FALSE,
#   quote = FALSE
# )
cat("Neutral regions list saved as:", neutral_reg_outfile, "\n")
