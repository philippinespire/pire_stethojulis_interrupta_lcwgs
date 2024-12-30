#!/bin/bash

# This script will generate the modern_samples.txt config file for GenErode.
# It should be run in the species' config GenErode directory. The modern directory should have all of the modern *.fq.gz files.
# example: /archive/carpenterlab/pire/pire_lethrinus_variegatus_lcwgs/GenErode_Lva_20k/modern
# Edit the definitions below before running.

# User-defined variables for species and species code (Spp). 
# For species use lowercase and an underscore so the directory path can be identified (e.g. lethrinus_variegatus)
species="lethrinus_variegatus"
# For Spp, this is the three letter species code. Capitalize the first letter.
Spp="Lva"

# Define the base path to the GenErode directory using the species variable. Edit if necessary. 
base_path=$"/archive/carpenterlab/pire/pire_${species}_lcwgs/GenErode_${Spp}_20k"

# Define the input files
input_file="${base_path}/config/old_new_lane_GenErode_${Spp}_config.log"

# Define the output files
output_file_modern="${base_path}/config/modern_samples.txt"
error_file_modern="${base_path}/config/error_modern.out"

# Create or clear the output files and add the header line
echo "samplename_index_lane readgroup_id readgroup_platform path_to_R1_fastq_file path_to_R2_fastq_file" > "$output_file_modern"

# Loop over each *1.fq.gz file in the modern directory
for r1file in ../modern/*1.fq.gz; do
    # Check if the file exists to handle cases where no files match the pattern
    if [ -e "$r1file" ]; then
        # Extract the filename only (remove relative path)
        r1file_name=$(basename "$r1file")
        r2file_name=${r1file_name/1.fq.gz/2.fq.gz}  # Derive R2 file name

        # Check if the R2 file exists
        if [ -e "../modern/$r2file_name" ]; then
            # modify file names by replacing all dashes with underscores
			r1file_modifiedname=$(echo "$r1file_name" | sed 's/-/_/g')
			r2file_modifiedname=$(echo "$r2file_name" | sed 's/-/_/g')
			
			# samplename_index_lane
			
			# samplename
			samplename=$(echo "$r1file_modifiedname" | sed 's/_//1;s/_//1' | cut -c 1-10)
			
			# index (extraction ID + well ID)
			# Validation of matching indices
			# Extract and validate indices
            r1_index=$(echo "$r1file_modifiedname" | sed 's/_//4' | awk -F'_' '{print $4}')
            r2_index=$(echo "$r2file_modifiedname" | sed 's/_//4' | awk -F'_' '{print $4}')

            if [ "$r1_index" != "$r2_index" ]; then
                echo "Warning: Index mismatch for $samplename illumina modern/$r1file_name modern/$r2file_name" >> "$error_file_modern"
                continue
            fi
            index="$r1_index"
			
			# lane
			# Validation of matching lanes	
			r1_lane=$(awk -v r1="$r1file_name" '$2 == r1 {print $3}' "$input_file")
			r2_lane=$(awk -v r2="$r2file_name" '$2 == r2 {print $3}' "$input_file")
			if [ -n "$r1_lane" ] && [ -n "$r2_lane" ]; then
				if [ "$r1_lane" != "$r2_lane" ]; then
					echo "Warning: Lane mismatch for $samplename illumina modern/$r1file_name modern/$r2file_name" >> "$error_file_modern"
					continue
				fi
				lane="$r1_lane"
			else
				echo "Warning: Lane information missing for $samplename illumina modern/$r1file_name modern/$r2file_name" >> "$error_file_modern"
			fi
						
			# concatenate samplename_index_lane
			samplename_index_lane=${samplename}_${index}_${lane}

            ## readgroup_id
            first_line=$(zcat "$r1file" | head -n 1)
            readgroup_id=$(echo "$first_line" | awk -F':' '{print $3":"$4}')

            ## readgroup_platform
            readgroup_platform="illumina"

            # Output to modern_samples.txt with only
            echo "$samplename_index_lane $readgroup_id $readgroup_platform modern/$r1file_name modern/$r2file_name" >> "$output_file_modern"
        else
            echo "Warning: Corresponding R2 file for $r1file_name not found." >> "$error_file_modern"
        fi
    fi
done

# Completion message
echo "Modern samples processing completed. Output saved to modern_samples.txt"

# Count the lines in the output file excluding the header
count_output=$(($(wc -l < "$output_file_modern") - 1))

# Count the number of R1 files
count_r1=$(find ../modern/ -name "*1.fq.gz" | wc -l)

# Count the number of R2 files
count_r2=$(find ../modern/ -name "*2.fq.gz" | wc -l)

# Verify if all counts match
if [ "$count_output" -eq "$count_r1" ] && [ "$count_output" -eq "$count_r2" ]; then
    echo "All $count_r1 1.fq.gz and $count_r2 2.fq.gz files were incorporated into modern_samples.txt"
else
    echo "Mismatch detected:"
    echo "- Lines in modern_samples.txt (excluding header): $count_output"
    echo "- R1 files found: $count_r1"
    echo "- R2 files found: $count_r2"
    echo "Check error_modern.out for details."
fi
