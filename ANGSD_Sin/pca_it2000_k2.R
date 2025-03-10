## This script contains some essential functions for the individual level PCA analysis and visualization
# These functions use a covariance matrix as the input
# Individual ID and population labels should also be supplied

#### INITIALIZE ####
# set working directory

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#### PACKAGES ####
packages_used <- 
  c("tidyverse",
    "dplyr",
    "cowplot",
    "RcppCNPy",
    "Cairo",
    "vegan"
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
# install.packages("tidyverse")
# install.packages("dplyr")
# install.packages("cowplot")
# install.packages("RcppCNPy")
# install.packages("Cairo")
# install.packages("vegan")

# load libraries
# library(tidyverse)
# library(dplyr)
# library(cowplot)
# library(RcppCNPy)
# library(Cairo)
# library(vegan)


#### USER DEFINED VARIABLES ####
# change your spp_code (e.g. Sob, Aen, Pbb)
spp_code="Sin"

# location longform
site_long = "Pandanon"

# change your site_A_code to the 3 letter site code of the Albatross (historical) population (e.g. Pnd, Gal, Mvi)
site_A_code="Pnd"

# change your site_C_code to the 3 letter site code of the contemporary (modern) population (e.g. Pnd, Gal, Mvi)
site_C_code="Pnd"

#### VARIABLES FROM USER INPUT  ####

# era site pattern (e.g. APnd, CPal). do not change. 
spp_era_A_site_pattern=paste0(spp_code,"A",site_A_code)
spp_era_C_site_pattern=paste0(spp_code,"C",site_C_code)


#### READ IN DATA ####

cov_matrix_angsd <- as.matrix(read.table("angsd_notrans_snps_it2000_pca.cov"))
#Matrix is in order 1-222 on each side
#sample_table <- read_table("sample_table_merged_allpop.tsv")

# Read the BAM list file
bamlist <- read.table("bam_list_all.txt")
# Ensure it's treated as a vector
bamlist <- bamlist$V1  # Assuming the BAM file names are in the first column


#### SAMPLE SIZE ####

# Count the number of albatross and contemporary individuals based on the patterns
albatross_n <- as.numeric(sum(grepl(paste0(spp_era_A_site_pattern, ".*\\.bam$"), bamlist)))  # Count lines matching albatross pattern
contemporary_n <- as.numeric(sum(grepl(paste0(spp_era_C_site_pattern, ".*\\.bam$"), bamlist)))  # Count lines matching contemporary pattern
albatross_n_plus_1 <- as.numeric(albatross_n + 1)
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

ind_label_angsd <- bamlist
pop_label_angsd <- meta.data$loc
x_axis <- 1
y_axis <- 2


#### PLOT PCA FORMATTED WITH 95% ELLIPSES (LINE) W/O TITLE & LEGEND ####

PCA <- function(cov_matrix_angsd, 
                ind_label_angsd, 
                pop_label_angsd, 
                x_axis, 
                y_axis, 
                show.point = TRUE, 
                show.label = FALSE, 
                show.ellipse = TRUE, 
                show.line = TRUE, 
                alpha = 0.2) {
  ## This function takes a covariance matrix and performs PCA.
  index_include <- ind_label_angsd
  m <- as.matrix(cov_matrix_angsd)
  e <- eigen(m)
  e_value <- e$values
  x_variance <- e_value[x_axis] / sum(e_value) * 100
  y_variance <- e_value[y_axis] / sum(e_value) * 100
  e <- as.data.frame(e$vectors)
  e <- cbind(ind_label_angsd, pop_label_angsd, e) 
  colnames(e)[3:(dim(e)[1])] <- paste0("PC", 1:(dim(e)[1] - 2)) 
  colnames(e)[1:2] <- c("individual", "population")
  assign("pca_table", e, .GlobalEnv)
  
  # Assigning 'Historical' and 'Contemporary' to the 'era' column
  e$era <- "Historical"
  e <- e %>% relocate(era, .after = population)
  
  # Update the 'era' column using the user-defined variables
  e[albatross_n_plus_1:total_n, "era"] <- "Contemporary"
  
  # Add location to e dataframe
  e$location <- site_long
  e <- e %>% relocate(location, .after = population)
  
  colnames(e)[3] <- "Location"
  colnames(e)[4] <- "Era"
  
  # Determine axis limits and breaks
  x_limits <- range(e$PC1, na.rm = TRUE)
  y_limits <- range(e$PC2, na.rm = TRUE)
  x_breaks <- seq(x_limits[1], x_limits[2], length.out = 4)  # 4 evenly spaced values
  y_breaks <- seq(y_limits[1], y_limits[2], length.out = 4)  # 4 evenly spaced values
  
  # Base PCA plot
  p <- ggplot(data = e, aes(x = PC1, y = PC2, color = Era, shape = Location)) +
    geom_point(size = 4, alpha = 0.4) +
    scale_color_manual(values = c("#00BFC4", "#F8766D")) +
    scale_x_continuous(labels = scales::number_format(accuracy = 0.01)) +  # Round to 2 decimal places
    scale_y_continuous(labels = scales::number_format(accuracy = 0.01)) +  # Round to 2 decimal places
    theme_classic() +
    theme(
      legend.position = "none",
      # legend.justification = "center",  # Center legend horizontally
      # legend.margin = margin(t = 5, b = 5),  # Adjust spacing above/below legend
      # legend.spacing.x = unit(5, "pt"),  # Adjust spacing between legend items
      axis.text = element_text(family = "Times New Roman", size = 12),  # Font for axis values
      axis.title = element_text(family = "Times New Roman", size = 12),  # Font for axis titles
      axis.ticks.length = unit(3, "pt"),  # Small tick marks
      axis.ticks = element_line(color = "black")  # Black tick marks
    ) +
    xlab(paste0("PC", x_axis, " (", round(x_variance, 2), "%)")) +
    ylab(paste0("PC", y_axis, " (", round(y_variance, 2), "%)"))
  
  # Add ellipses as outlines if requested
  if (show.ellipse) {
    p <- p + stat_ellipse(aes(color = Era), type = "norm", linetype = "solid", linewidth = 1, geom = "path")
  }
  
  return(p)
}

# Create PCA plot
pca <- PCA(cov_matrix_angsd, ind_label_angsd, pop_label_angsd, x_axis, y_axis)
print(pca)
# outFile pattern
outFile_plot_pca <- paste0("plots/", spp_code, "_plot_pca_FORMAT_angsd_notrans_snps_it2000_pca_cov", ".png")  

# Save the plot to a file
ggsave(filename = outFile_plot_pca, plot = pca, width = 2.15, height = 2.5)


#### PLOT PCA ####

# create pca plot function
PCA <- function(cov_matrix_angsd, ind_label_angsd, pop_label_angsd, x_axis, y_axis, show.point=T, show.label=F, show.ellipse=T, show.line=T, alpha=0)
{
  ## This function takes a covariance matrix and performs PCA.
  # cov_matrix: a square covariance matrix generated by most pca softwares
  # ind_label: a vector in the same order and length as cov_matrix; it contains the individual labels of the individuals represented in the covariance matrix
  # pop_label: a vector in the same order and length as cov_matrix; it contains the population labels of the individuals represented in the covariance matrix
  # x_axis: an integer that determines which principal component to plot on the x axis
  # y_axis: an integer that determines which principal component to plot on the y axis
  # show.point: whether to show individual points
  # show.label: whether to show population labels
  # show.ellipse: whether to show population-specific ellipses
  # show.line: whether to show lines connecting population means with each individual point
  # alpha: the transparency of ellipses
  # index_exclude: the indices of individuals to exclude from the analysis, deleted this for now, but code is index_exclude=vector()
  index_include <- ind_label_angsd
  m <- as.matrix(cov_matrix_angsd)
  e <- eigen(m)
  e_value<-e$values
  x_variance<-e_value[x_axis]/sum(e_value)*100
  y_variance<-e_value[y_axis]/sum(e_value)*100
  e <- as.data.frame(e$vectors)
  e <- cbind(ind_label_angsd, pop_label_angsd, e) 
  colnames(e)[3:(dim(e)[1])]<-paste0("PC",1:(dim(e)[1]-2)) ## with the above individuals removed
  colnames(e)[1:2]<-c("individual", "population")
  assign("pca_table", e, .GlobalEnv)
  
  # Assigning 'Historical' and 'Contemporary' to the 'era' column
  e$era <- "Historical"
  e <- e %>% relocate(era, .after = population)
  
  # Update the 'era' column using the user-defined variables
  e[albatross_n_plus_1:total_n, 3] <- "Contemporary"
  
  #Add location to e dataframe
  e$location <- site_long
  e <- e %>% relocate(location, .after=population)
  
  colnames(e)[3] <- "Location"
  colnames(e)[4] <- "Era"
  
  ggplot(data=e,aes(x=PC1, y=PC2, color=Era, shape=Location)) +
    geom_point(size=4, alpha=0.4) +
    scale_color_manual(values = c("#00BFC4", "#F8766D"), 
                       labels = c(paste0("Modern (",contemporary_n, ")"), 
                                  paste0("Historical (" , albatross_n, ")"))
    ) +
    theme_classic() +
    theme(
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 10),
      legend.key = element_rect(fill = "white", color = "black")) +
    theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank()
    ) +
    xlab(paste0("PC", x_axis, "(",round(x_variance,2),"%)")) +
    ylab(paste0("PC", y_axis ,"(",round(y_variance,2),"%)")) +
    labs(color="Era", 
         shape="Location",
         title = paste0(spp_code," ", site_long, " ANGSD PCA Plot")
    ) +
    guides(shape = "none")  # This hides the Location legend
}

# create pca plot
PCA(cov_matrix_angsd, ind_label_angsd, pop_label_angsd,x_axis,y_axis)


#### PLOT PCA W/O TITLE & LEGEND ####
PCA <- function(cov_matrix_angsd, ind_label_angsd, pop_label_angsd, x_axis, y_axis, show.point = TRUE, show.label = FALSE, show.ellipse = TRUE, show.line = TRUE, alpha = 0) {
  ## This function takes a covariance matrix and performs PCA.
  index_include <- ind_label_angsd
  m <- as.matrix(cov_matrix_angsd)
  e <- eigen(m)
  e_value <- e$values
  x_variance <- e_value[x_axis] / sum(e_value) * 100
  y_variance <- e_value[y_axis] / sum(e_value) * 100
  e <- as.data.frame(e$vectors)
  e <- cbind(ind_label_angsd, pop_label_angsd, e)
  colnames(e)[3:(dim(e)[1])] <- paste0("PC", 1:(dim(e)[1] - 2))
  colnames(e)[1:2] <- c("individual", "population")
  assign("pca_table", e, .GlobalEnv)
  
  # Assigning 'Historical' and 'Contemporary' to the 'era' column
  e$era <- "Historical"
  e <- e %>% relocate(era, .after = population)
  
  # Update the 'era' column using the user-defined variables
  e[albatross_n_plus_1:total_n, 3] <- "Contemporary"
  
  # Add location to e dataframe
  e$location <- site_long
  e <- e %>% relocate(location, .after = population)
  
  colnames(e)[3] <- "Location"
  colnames(e)[4] <- "Era"
  
  ggplot(data = e, aes(x = PC1, y = PC2, color = Era, shape = Location)) +
    geom_point(size = 4, alpha = 0.4) +
    scale_color_manual(values = c("#00BFC4", "#F8766D"),
                       labels = c(paste0("Modern (", contemporary_n, ")"),
                                  paste0("Historical (", albatross_n, ")"))) +
    theme_classic() +
    theme(
      legend.position = "none",  # Hide the entire legend
      axis.text.x = element_blank(),
      axis.text.y = element_blank()
    ) +
    xlab(paste0("PC", x_axis, " (", round(x_variance, 2), "%)")) +
    ylab(paste0("PC", y_axis, " (", round(y_variance, 2), "%)"))
}

# Create PCA plot
PCA(cov_matrix_angsd, ind_label_angsd, pop_label_angsd, x_axis, y_axis)


#### PLOT PCA WITH 95% ELLIPSES (LINE) ####

# create pca plot function
PCA <- function(cov_matrix_angsd, 
                ind_label_angsd, 
                pop_label_angsd, 
                x_axis, 
                y_axis, 
                show.point = TRUE, 
                show.label = FALSE, 
                show.ellipse = TRUE, 
                show.line = TRUE, 
                alpha = 0.2) {
  ## This function takes a covariance matrix and performs PCA.
  index_include <- ind_label_angsd
  m <- as.matrix(cov_matrix_angsd)
  e <- eigen(m)
  e_value <- e$values
  x_variance <- e_value[x_axis] / sum(e_value) * 100
  y_variance <- e_value[y_axis] / sum(e_value) * 100
  e <- as.data.frame(e$vectors)
  e <- cbind(ind_label_angsd, pop_label_angsd, e) 
  colnames(e)[3:(dim(e)[1])] <- paste0("PC", 1:(dim(e)[1] - 2)) 
  colnames(e)[1:2] <- c("individual", "population")
  assign("pca_table", e, .GlobalEnv)
  
  # Assigning 'Historical' and 'Contemporary' to the 'era' column
  e$era <- "Historical"
  e <- e %>% relocate(era, .after = population)
  
  # Update the 'era' column using the user-defined variables
  e[albatross_n_plus_1:total_n, "era"] <- "Contemporary"
  
  # Add location to e dataframe
  e$location <- site_long
  e <- e %>% relocate(location, .after = population)
  
  colnames(e)[3] <- "Location"
  colnames(e)[4] <- "Era"
  
  # Base PCA plot
  p <- ggplot(data = e, aes(x = PC1, y = PC2, color = Era, shape = Location)) +
    geom_point(size = 4, alpha = 0.4) +
    scale_color_manual(values = c("#00BFC4", "#F8766D"), 
                       labels = c(paste0("Modern (", contemporary_n, ")"), 
                                  paste0("Historical (", albatross_n, ")"))) +
    theme_classic() +
    theme(
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 10),
      legend.key = element_rect(fill = "white", color = "black"),
      axis.text.x = element_blank(),
      axis.text.y = element_blank()
    ) +
    xlab(paste0("PC", x_axis, " (", round(x_variance, 2), "%)")) +
    ylab(paste0("PC", y_axis, " (", round(y_variance, 2), "%)")) +
    labs(color = "Era", 
         shape = "Location",
         title = paste0(spp_code, " ", site_long, " ANGSD PCA Plot")) +
    guides(shape = "none")  # Hide the Location legend
  
  # Add ellipses as outlines if requested
  if (show.ellipse) {
    p <- p + stat_ellipse(aes(color = Era), type = "norm", linetype = "solid", linewidth = 1, geom = "path")
  }
  
  return(p)
}

# create pca plot
PCA(cov_matrix_angsd, ind_label_angsd, pop_label_angsd,x_axis,y_axis)


#### PLOT PCA WITH 95% ELLIPSES (LINE) W/O TITLE & LEGEND ####

# Create PCA plot function without title and legend
PCA <- function(cov_matrix_angsd, 
                ind_label_angsd, 
                pop_label_angsd, 
                x_axis, 
                y_axis, 
                show.point = TRUE, 
                show.label = FALSE, 
                show.ellipse = TRUE, 
                show.line = TRUE, 
                alpha = 0.2) {
  ## This function takes a covariance matrix and performs PCA.
  index_include <- ind_label_angsd
  m <- as.matrix(cov_matrix_angsd)
  e <- eigen(m)
  e_value <- e$values
  x_variance <- e_value[x_axis] / sum(e_value) * 100
  y_variance <- e_value[y_axis] / sum(e_value) * 100
  e <- as.data.frame(e$vectors)
  e <- cbind(ind_label_angsd, pop_label_angsd, e) 
  colnames(e)[3:(dim(e)[1])] <- paste0("PC", 1:(dim(e)[1] - 2)) 
  colnames(e)[1:2] <- c("individual", "population")
  assign("pca_table", e, .GlobalEnv)
  
  # Assigning 'Historical' and 'Contemporary' to the 'era' column
  e$era <- "Historical"
  e <- e %>% relocate(era, .after = population)
  
  # Update the 'era' column using the user-defined variables
  e[albatross_n_plus_1:total_n, "era"] <- "Contemporary"
  
  # Add location to e dataframe
  e$location <- site_long
  e <- e %>% relocate(location, .after = population)
  
  colnames(e)[3] <- "Location"
  colnames(e)[4] <- "Era"
  
  # Base PCA plot
  p <- ggplot(data = e, aes(x = PC1, y = PC2, color = Era, shape = Location)) +
    geom_point(size = 4, alpha = 0.4) +
    scale_color_manual(values = c("#00BFC4", "#F8766D")) +
    theme_classic() +
    theme(
      legend.position = "none",  # Hide the entire legend
      axis.text.x = element_blank(),
      axis.text.y = element_blank()
    ) +
    xlab(paste0("PC", x_axis, " (", round(x_variance, 2), "%)")) +
    ylab(paste0("PC", y_axis, " (", round(y_variance, 2), "%)"))
  
  # Add ellipses as outlines if requested
  if (show.ellipse) {
    p <- p + stat_ellipse(aes(color = Era), type = "norm", linetype = "solid", linewidth = 1, geom = "path")
  }
  
  return(p)
}

# Create PCA plot
PCA(cov_matrix_angsd, ind_label_angsd, pop_label_angsd, x_axis, y_axis)


#### PLOT PCA WITH 95% ELLIPSES (POLYGON) ####

# create pca plot function
PCA <- function(cov_matrix_angsd, ind_label_angsd, pop_label_angsd, x_axis, y_axis, show.point = TRUE, show.label = FALSE, show.ellipse = TRUE, show.line = TRUE, alpha = 0.2) {
  ## This function takes a covariance matrix and performs PCA.
  index_include <- ind_label_angsd
  m <- as.matrix(cov_matrix_angsd)
  e <- eigen(m)
  e_value <- e$values
  x_variance <- e_value[x_axis] / sum(e_value) * 100
  y_variance <- e_value[y_axis] / sum(e_value) * 100
  e <- as.data.frame(e$vectors)
  e <- cbind(ind_label_angsd, pop_label_angsd, e) 
  colnames(e)[3:(dim(e)[1])] <- paste0("PC", 1:(dim(e)[1] - 2)) 
  colnames(e)[1:2] <- c("individual", "population")
  assign("pca_table", e, .GlobalEnv)
  
  # Assigning 'Historical' and 'Contemporary' to the 'era' column
  e$era <- "Historical"
  e <- e %>% relocate(era, .after = population)
  
  # Update the 'era' column using the user-defined variables
  e[albatross_n_plus_1:total_n, "era"] <- "Contemporary"
  
  # Add location to e dataframe
  e$location <- site_long
  e <- e %>% relocate(location, .after = population)
  
  colnames(e)[3] <- "Location"
  colnames(e)[4] <- "Era"
  
  # Base PCA plot
  p <- ggplot(data = e, aes(x = PC1, y = PC2, color = Era, shape = Location)) +
    geom_point(size = 4, alpha = 0.4) +
    scale_color_manual(values = c("#00BFC4", "#F8766D"), 
                       labels = c(paste0("Modern (", contemporary_n, ")"), 
                                  paste0("Historical (", albatross_n, ")"))) +
    theme_classic() +
    theme(
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 10),
      legend.key = element_rect(fill = "white", color = "black"),
      axis.text.x = element_blank(),
      axis.text.y = element_blank()
    ) +
    xlab(paste0("PC", x_axis, " (", round(x_variance, 2), "%)")) +
    ylab(paste0("PC", y_axis, " (", round(y_variance, 2), "%)")) +
    labs(color = "Era", 
         shape = "Location",
         title = paste0(spp_code, " ", site_long, " ANGSD PCA Plot")) +
    guides(shape = "none")  # Hide the Location legend
  
  # Add ellipses if requested
  if (show.ellipse) {
    p <- p + stat_ellipse(aes(fill = Era), type = "norm", alpha = alpha, geom = "polygon", color = NA) +
      scale_fill_manual(values = c("#00BFC4", "#F8766D"), guide = "none")  # Matching ellipse colors and hiding ellipse legend
  }
  
  return(p)
}

# create pca plot
PCA(cov_matrix_angsd, ind_label_angsd, pop_label_angsd,x_axis,y_axis)


#### PLOT PCA WITH 95% ELLIPSES (POLYGON) W/O TITLE & LEGEND ####

# Create PCA plot function without title and legend
PCA <- function(cov_matrix_angsd, ind_label_angsd, pop_label_angsd, x_axis, y_axis, show.point = TRUE, show.label = FALSE, show.ellipse = TRUE, show.line = TRUE, alpha = 0.2) {
  ## This function takes a covariance matrix and performs PCA.
  index_include <- ind_label_angsd
  m <- as.matrix(cov_matrix_angsd)
  e <- eigen(m)
  e_value <- e$values
  x_variance <- e_value[x_axis] / sum(e_value) * 100
  y_variance <- e_value[y_axis] / sum(e_value) * 100
  e <- as.data.frame(e$vectors)
  e <- cbind(ind_label_angsd, pop_label_angsd, e) 
  colnames(e)[3:(dim(e)[1])] <- paste0("PC", 1:(dim(e)[1] - 2)) 
  colnames(e)[1:2] <- c("individual", "population")
  assign("pca_table", e, .GlobalEnv)
  
  # Assigning 'Historical' and 'Contemporary' to the 'era' column
  e$era <- "Historical"
  e <- e %>% relocate(era, .after = population)
  
  # Update the 'era' column using the user-defined variables
  e[albatross_n_plus_1:total_n, "era"] <- "Contemporary"
  
  # Add location to e dataframe
  e$location <- site_long
  e <- e %>% relocate(location, .after = population)
  
  colnames(e)[3] <- "Location"
  colnames(e)[4] <- "Era"
  
  # Base PCA plot
  p <- ggplot(data = e, aes(x = PC1, y = PC2, color = Era, shape = Location)) +
    geom_point(size = 4, alpha = 0.4) +
    scale_color_manual(values = c("#00BFC4", "#F8766D")) +
    theme_classic() +
    theme(
      legend.position = "none",  # Hide the entire legend
      axis.text.x = element_blank(),
      axis.text.y = element_blank()
    ) +
    xlab(paste0("PC", x_axis, " (", round(x_variance, 2), "%)")) +
    ylab(paste0("PC", y_axis, " (", round(y_variance, 2), "%)"))
  
  # Add ellipses if requested
  if (show.ellipse) {
    p <- p + stat_ellipse(aes(fill = Era), type = "norm", alpha = alpha, geom = "polygon", color = NA) +
      scale_fill_manual(values = c("#00BFC4", "#F8766D"))  # Matching ellipse colors
  }
  
  return(p)
}

# Create PCA plot
PCA(cov_matrix_angsd, ind_label_angsd, pop_label_angsd, x_axis, y_axis)


#### STATISTICS: PERMANOVA ####
# Define group_factor for all statistical tests
group_factor <- pca_table$population  # Historical (Albatross) vs. Modern (Contemporary)

# Prepare PCA matrix
pca_matrix <- pca_table[, c("PC1", "PC2")]  # Use first 2 PCs

# Run PERMANOVA
permanova_result <- adonis2(pca_matrix ~ group_factor, method = "euclidean", permutations = 1000)

# Convert to a dataframe
table_permanova_result <- as.data.frame(permanova_result)

# Display result
print(table_permanova_result)

# Define output file
outFile_permanova_result <- paste0("./plots/", spp_code, "_pca_it2000_subset_permanova.csv")

# Save the hypothesis test results as a CSV file
write.csv(table_permanova_result, outFile_permanova_result, row.names = TRUE)


#### STATISTICS: MANOVA ####
manova_result <- manova(cbind(PC1, PC2) ~ population, data = pca_table)
summary(manova_result, test = "Pillai")

# save output


#### STATISTICS: BETADISPERSION ####
beta_disp <- betadisper(dist(pca_matrix), group_factor)
anova(beta_disp)

# Convert to a dataframe
table_betdisp_result <- as.data.frame(anova(beta_disp))

# Display result
print(table_betdisp_result)

# Define output file
outFile_betdisp_result <- paste0("./plots/", spp_code, "_pca_it2000_betdisp.csv")

# Save the hypothesis test results as a CSV file
write.csv(table_betdisp_result, outFile_betdisp_result, row.names = TRUE)


#### IDENTIFY OUTLIERS ####

# Print PCA Table
# Select columns: individual, population, PC1, PC2
pca_table_cleaned <- pca_table %>%
  select(individual, population, PC1, PC2) %>%
  mutate(individual = str_remove(individual, "\\..*"))  # Remove first period and everything after

# Write to CSV
write.csv(pca_table_cleaned, "pca_table_cleaned_subset_k3.csv", row.names = FALSE)

# Define outlier thresholds for PC1 and PC2
PC1_lower_threshold <- NA   # Set to NA if not applicable
PC1_upper_threshold <- NA   # Set to NA if not applicable
PC2_lower_threshold <- -0.8   # Set to NA if not applicable
PC2_upper_threshold <- NA   # Set to NA if not applicable

# Function to identify outliers for a given PC column
identify_outliers <- function(data, column, lower_threshold, upper_threshold) {
  if (is.na(lower_threshold) && is.na(upper_threshold)) {
    return(data.frame(individual = character()))  # Return empty dataframe if both thresholds are NA
  } else {
    return(
      data %>%
        filter(
          (if (!is.na(lower_threshold)) !!sym(column) < lower_threshold else FALSE) |
            (if (!is.na(upper_threshold)) !!sym(column) > upper_threshold else FALSE)
        ) %>%
        select(individual)
    )
  }
}

# Identify PC1 and PC2 outliers
PC1_outliers <- identify_outliers(pca_table, "PC1", PC1_lower_threshold, PC1_upper_threshold)
PC2_outliers <- identify_outliers(pca_table, "PC2", PC2_lower_threshold, PC2_upper_threshold)

# Combine PC1 and PC2 outliers
all_outliers <- unique(rbind(PC1_outliers, PC2_outliers))

# Display outliers
cat("PC1 Outliers:\n")
print(PC1_outliers)

cat("\nPC2 Outliers:\n")
print(PC2_outliers)

cat("\nAll Outliers:\n")
print(all_outliers)

# Export PC1_outliers to a text file (no header)
write.table(PC1_outliers$individual, 
            file = file.path(getwd(), "PC1_outliers.txt"), 
            quote = FALSE, 
            row.names = FALSE, 
            col.names = FALSE)

# Export PC2_outliers to a text file (no header)
write.table(PC2_outliers$individual, 
            file = file.path(getwd(), "PC2_outliers_2.txt"), 
            quote = FALSE, 
            row.names = FALSE, 
            col.names = FALSE)
