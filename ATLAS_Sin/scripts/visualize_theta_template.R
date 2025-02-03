#### INSTRUCTIONS ####

# Some scripts for handling the output from ATLAS task=theta.
# It assumes windowed theta, will probably have to modify if genome-wide theta is calculated.
# This script (visualize_theta.R) should be run in the scripts directory. 
# It uses the input file theta_data.rds, which was made from wrangle_theta.R
# This script makes plots & runs stats on theta and depth.
# This script can be run through the RStudio Server on ODU RCC OnDemand.
# https://ondemand.wahab.hpc.odu.edu/
# Alternatively this can be run on your personal computer by downloading the theta_data.rds file.

#### INITIALIZE ####
# load required package (tidyverse)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### PACKAGES ####
packages_used <- 
  c("tidyverse",
    "dplyr",
    "effsize",
    "Cairo",
    "brms",
    "posterior",
    "bridgesampling"
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
# library(effsize)
# library(Cairo)
# library(brms)
# library(posterior)
# library(bridgesampling)

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


#### VARIABLES FROM USER INPUT  ####
# do not change the variables below. 
# they are made from the above user-defined variables.
# era codes. do not change. 
era_A_code="A"
era_C_code="C"

# era site pattern (e.g. APnd, CPal). do not change. 
era_A_site_pattern=paste0(era_A_code,site_A_code)
era_C_site_pattern=paste0(era_C_code,site_C_code)


#### READ IN FILTERED THETA DATA (REMOVED NAs & OUTLIERS) ####
# define the inFile pattern
inFile = str_c("../out/",
               spp_code,
               "_theta_data",
               ".rds") #visualize_theta.R depends on this path and name

# read in your species' data created from the wrangle_theta.R script
theta_data <- 
  read_rds(file = inFile)


#### VISUALIZE THETA DATA ####

# Create labels with sample sizes for the plot legends
# Calculate sample sizes by Era (after filtering)
era_sample_sizes <- theta_data %>%
  group_by(Era) %>%
  summarize(sample_size = n(), .groups = "drop")

# Define Era labels with sample sizes
era_labels <- c(
  "Albatross - ATLAS GERP recalibration" = paste0("Historical (n = ", era_sample_sizes$sample_size[era_sample_sizes$Era == "Albatross - ATLAS GERP recalibration"], ")"),
  "Contemporary - ATLAS GERP recalibration" = paste0("Modern (n = ", era_sample_sizes$sample_size[era_sample_sizes$Era == "Contemporary - ATLAS GERP recalibration"], ")")
)

# Create labels for the legend
# era_labels <- era_sample_sizes %>%
#   mutate(label = paste(Era, "( n =", sample_size, ")")) %>%
#   pull(label)

# Map Era to the labels
# names(era_labels) <- era_sample_sizes$Era

# PLOT: plot theta by era
plot_theta <- theta_data %>% 
  ggplot(aes(
    x = Era, 
    y = avg_theta, 
    fill = Era
  )) +
  labs(
    x = "Era",
    y = "Estimated Heterozygosity (Theta)",
    title = paste(spp_code, "- Theta")
  ) +
  theme_bw() +
  geom_boxplot() +
  scale_x_discrete(labels = era_labels) +  # Rename x-axis labels with sample sizes
  scale_fill_manual(values = scales::hue_pal()(length(era_labels))) +
  theme(legend.position = "none")  # Remove legend
print(plot_theta)

# outFile pattern
outFile_plot_theta_rmna_rmout <- paste0(outDir, "/", spp_code, "_plot_theta", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta_rmna_rmout, plot = plot_theta, width = 6, height = 6)


# PLOT: boxplot of depth
plot_depth <- theta_data %>% 
  ggplot(aes(
    x = Era,  # Change x from recal to Era
    y = avg_depth, 
    fill = Era
  )) +
  labs(
    x = "Era",
    y = "Depth",
    title = paste(spp_code, "- Depth")
  ) +
  theme_bw() +
  scale_y_continuous(trans = 'log10') +  # Log10 scale for depth
  geom_boxplot() +
  scale_x_discrete(labels = era_labels) +  # Rename x-axis labels with sample sizes
  scale_fill_manual(values = scales::hue_pal()(length(era_labels))) +
  theme(legend.position = "none")  # Remove legend
print(plot_depth)

# outFile pattern
outFile_plot_depth_rmna_rmout <- paste0(outDir, "/", spp_code, "_plot_depth", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_depth_rmna_rmout, plot = plot_depth, width = 6, height = 6)


# PLOT: theta vs depth
plot_theta_depth <- theta_data %>% 
  ggplot(aes(
    x=avg_depth, 
    y=avg_theta, 
    color=Era
  )) +
  labs(
    y = "Average Depth",
    x = "Estimated Heterozygosity (Theta)",
    title = paste(spp_code,"- Read Number Variation")
  ) +
  theme_bw() +
  scale_x_continuous(trans='log10') +
  geom_point() +
  geom_smooth() +
  scale_color_manual(values = scales::hue_pal()(length(era_labels)), labels = era_labels)
print(plot_theta_depth)

# outFile pattern
outFile_plot_theta_depth_rmna_rmout <- paste0(outDir, "/", spp_code, "_plot_theta_depth", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta_depth_rmna_rmout, plot = plot_theta_depth, width = 9, height = 6)


# PLOT: density plot of theta
plot_theta_density <- theta_data %>%
  ggplot(aes(
    x = avg_theta, 
    fill = Era  # Ensure you are using fill, not color
  )) +
  geom_density(alpha = 0.5) +
  theme_bw() +
  labs(
    title = paste(spp_code, "Density Plot of Theta by Era"), 
    x = "Estimated Heterozygosity (Theta)", 
    y = "Density",
    fill = "Era"  # Label for the legend
  ) +
  scale_fill_manual(
    values = scales::hue_pal()(length(era_labels)),  # Ensure consistent colors
    labels = era_labels  # Apply custom labels in the legend
  )
print(plot_theta_density)

# outFile pattern
outFile_plot_theta_density_rmna_rmout <- paste0(outDir, "/", spp_code, "_plot_theta_density", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_theta_density_rmna_rmout, plot = plot_theta_density, width = 9, height = 6)


#### STATISTICAL TEST: MANN-WHITNEY U ####

# Perform Mann-Whitney U test (Wilcoxon rank-sum test) on theta estimates
# Separate theta estimates by Era
theta_modern <- theta_data %>%
  filter(Era == 'Contemporary - ATLAS GERP recalibration') %>%
  pull(avg_theta)

theta_historical <- theta_data %>%
  filter(Era == 'Albatross - ATLAS GERP recalibration') %>%
  pull(avg_theta)

# Run the test
wilcox_test_results <- wilcox.test(theta_modern, theta_historical, exact = FALSE)

# Print the results
print(wilcox_test_results)

# Compute additional statistics
n_modern <- length(theta_modern)
n_historical <- length(theta_historical)
median_modern <- median(theta_modern, na.rm = TRUE)
median_historical <- median(theta_historical, na.rm = TRUE)

# Compute effect size (Cliff's Delta)
effect_size <- cliff.delta(theta_modern, theta_historical)$estimate  # Effect size measure

# Compute rank-biserial correlation (effect size for Wilcoxon test).
# rank_biserial_corr <- wilcoxonR(theta_modern, theta_historical) #can't seem to install.packages("rcompanion")

# Construct summary table
wilcox_test_summary <- data.frame(
  statistic = wilcox_test_results$statistic,  # Wilcoxon W statistic
  p_value = wilcox_test_results$p.value,  # p-value
  method = wilcox_test_results$method,  # Test method used
  alternative_hypothesis = wilcox_test_results$alternative,  # One-tailed or two-tailed test (alternative)
  n_modern = n_modern,  # Sample size for modern
  n_historical = n_historical,  # Sample size for historical
  median_modern = median_modern,  # Median avg_theta for modern
  median_historical = median_historical,  # Median avg_theta for historical
  effect_size_cliffs_delta = effect_size# ,  # Cliff’s Delta effect size
  # rank_biserial_correlation = rank_biserial_corr  # Rank-biserial correlation effect size
)
print(wilcox_test_summary)

# outFile pattern
outFile_wilcox_test_summary <- paste0("../out/", spp_code, "_table_wilcox_test_summary.csv") 

# Save the summary as a CSV file
write.csv(wilcox_test_summary, outFile_wilcox_test_summary, row.names = FALSE)


#### STATISTICAL TEST: PERMUTATION TEST ####

# Permutation Test with Bootstrapping
set.seed(123)  # For reproducibility
n_permutations <- 10000  # Number of iterations

# Combine all data into one pool
theta_pool <- c(theta_modern, theta_historical)

# Get group sizes
n_modern <- length(theta_modern)
n_historical <- length(theta_historical)

# Initialize a vector to store permuted differences
perm_diffs <- numeric(n_permutations)

# Perform permutations
for (i in 1:n_permutations) {
  permuted_data <- sample(theta_pool)  # Shuffle all values
  perm_modern <- permuted_data[1:n_modern]  # First n_modern elements
  perm_historical <- permuted_data[(n_modern + 1):length(theta_pool)]  # Remaining elements
  # Compute permuted mean difference
  perm_diffs[i] <- mean(perm_modern, na.rm = TRUE) - mean(perm_historical, na.rm = TRUE)
}

# Compute observed difference in means
obs_diff <- mean(theta_modern, na.rm = TRUE) - mean(theta_historical, na.rm = TRUE)
# Compute two-tailed p-value
p_value <- mean(abs(perm_diffs) >= abs(obs_diff))

# Display results
cat("Observed Difference in Means:", obs_diff, "\n")
cat("Permutation Test p-value:", p_value, "\n")

# Create a summary table
perm_test_summary <- data.frame(
  Test = "Permutation Test with Bootstrapping",
  Statistic = "Observed Mean Difference",
  Value = obs_diff,
  P_Value = p_value,
  Permutations = n_permutations
)

print(perm_test_summary)

# outFile pattern
outFile_perm_test_summary <- paste0("../out/", spp_code, "_table_permutation_test_summary.csv") 

# Save the summary as a CSV file
write.csv(perm_test_summary, outFile_perm_test_summary, row.names = FALSE)


# PLOT: A histogram of permutation results to show the null distribution.

plot_perm_test_distribution <- 
ggplot(data.frame(perm_diffs), aes(x = perm_diffs)) +
  geom_histogram(binwidth = 0.005, fill = "lightblue", color = "black") +
  geom_vline(xintercept = obs_diff, color = "red", linetype = "dashed", linewidth = 1) + # Observed difference line
  theme_bw() +
  labs(title = "Permutation Test Distribution",
       x = "Mean Difference",
       y = "Frequency")

print(plot_perm_test_distribution)

# outFile pattern
outFile_plot_perm_test_distribution <- paste0(outDir, "/", spp_code, "_plot_perm_test_distribution", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_perm_test_distribution, plot = plot_perm_test_distribution, width = 6, height = 6)


#### STATISTICAL TEST: BAYESIAN MODEL ####
# ---- 1️⃣ Fit the Bayesian Model ----
bayesian_model <- brm(
  avg_theta ~ Era,  # Predict avg_theta based on Era
  data = theta_data,
  family = gaussian(),  # Assume normal distribution
  prior = c(
    prior(normal(0, 1), class = "b"),  # Prior for regression coefficients
    prior(cauchy(0, 1), class = "Intercept")  # Prior for intercept
  ),
  chains = 4, iter = 4000, warmup = 1000, cores = 4
)

# ---- 2️⃣ Extract Fixed Effects ----
fixef_table <- as.data.frame(fixef(bayesian_model))

print(fixef_table)

# Define output file
outFile_fixef <- paste0("../out/", spp_code, "_table_bayesian_fixef.csv")

# Save fixed effects summary as CSV
write.csv(fixef_table, outFile_fixef, row.names = TRUE)

# ---- 3️⃣ Print & Save Model Summary ----
bayesian_model_summary <- summary(bayesian_model)

print(bayesian_model_summary)

# Extract summary statistics (as text)
summary_text <- capture.output(print(bayesian_model_summary))

# Define output file
outFile_bayesian_model_summary <- paste0("../out/", spp_code, "_table_bayesian_model_summary.txt")

# Save the summary as a text file
writeLines(summary_text, outFile_bayesian_model_summary)

# ---- 4️⃣ Bayesian Hypothesis Test ----
bayesian_model_result <- hypothesis(bayesian_model, "EraContemporaryMATLASGERPrecalibration < 0", class = "b")

# Convert to a dataframe
table_bayesian_model_result <- as.data.frame(bayesian_model_result$hypothesis)

print(table_bayesian_model_result)

# Define output file
outFile_table_bayesian_model_result <- paste0("../out/", spp_code, "_table_bayesian_model_result.csv")

# Save the hypothesis test results as a CSV file
write.csv(table_bayesian_model_result, outFile_table_bayesian_model_result, row.names = FALSE)

# ---- 5️⃣ Compute Bayes Factor (Comparing Full vs. Null Model) ----
# Fit the null model (no Era predictor)
bayesian_model_null <- brm(
  avg_theta ~ 1,  # Null model with no predictor
  data = theta_data,
  family = gaussian(),
  prior = c(
    prior(cauchy(0, 1), class = "Intercept")  # Match the full model’s prior
    ),
  chains = 4, iter = 4000, warmup = 1000, cores = 4
)

# Compute Bayes Factor comparing full vs. null model
bf_bayesian <- bayes_factor(bayesian_model, bayesian_model_null)

print(bf_bayesian)  # Check full output of Bayes Factor computation
print(bf_bayesian$bf)  # Check if Bayes Factor exists
print(bf_bayesian$logbf)  # Check if log(BF) exists

# Extract Bayes Factor values safely
bf_value <- ifelse(is.null(bf_bayesian$bf), NA, bf_bayesian$bf)
log_bf_value <- ifelse(is.null(bf_bayesian$logbf), NA, bf_bayesian$logbf)

# Convert to a dataframe
bf_table <- data.frame(
  Full_Model = "avg_theta ~ Era",
  Null_Model = "avg_theta ~ 1",
  Bayes_Factor = bf_value,
  Log_Bayes_Factor = log_bf_value
)

print(bf_table)

# Define output file
outFile_bayes_factor <- paste0("../out/", spp_code, "_table_bayes_factor.csv")

# Save Bayes Factor results as a CSV file
write.csv(bf_table, outFile_bayes_factor, row.names = FALSE)


# PLOT: posterior distributions
plot(bayesian_model)


# PLOT: posterior predictive check
plot_bayesian_pp_check <- pp_check(bayesian_model)
print(plot_bayesian_pp_check)

# outFile pattern
outFile_plot_bayesian_pp_check <- paste0(outDir, "/", spp_code, "_plot_bayesian_pp_check", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_bayesian_pp_check, plot = plot_bayesian_pp_check, width = 6, height = 6)


#### PLOT: Posterior Distribution of Theta Difference ####

# ---- 1️⃣ Extract Posterior Samples ----
posterior_samples <- as_draws_df(bayesian_model)  # Extract full posterior draws

# Select only the parameter of interest while keeping draws_df structure
posterior_df <- subset_draws(posterior_samples, variable = "b_EraContemporaryMATLASGERPrecalibration")

# Rename the column safely
colnames(posterior_df) <- "theta_difference"

# ---- 2️⃣ Generate Posterior Density Plot ----
posterior_plot <- ggplot(posterior_df, aes(x = theta_difference)) +
  geom_density(fill = "blue", alpha = 0.3) +  # Density plot
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +  # Reference at 0
  geom_vline(xintercept = quantile(posterior_df$theta_difference, probs = c(0.025, 0.975)), 
             color = "black", linetype = "dotted", linewidth = 1) +  # 95% Credible Interval
  labs(title = "Posterior Distribution of Theta Difference",
       x = "Difference in Average Theta (Modern - Historical)",
       y = "Density") +
  theme_bw()

# Print the plot
print(posterior_plot)

# ---- 3️⃣ Save the Plot to a File ----
# Define output file path
outFile_posterior_plot <- paste0(outDir, "/", spp_code, "_posterior_distribution_plot.png")

# Save the plot
ggsave(filename = outFile_posterior_plot, plot = posterior_plot, width = 6, height = 6, dpi = 300)
