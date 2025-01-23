#!/bin/bash

# This script creates an output file of all of the original and new file names of the fq_raw/*.fq.gz from multiple sequencing runs. 


# User-defined variables for species and species code (Spp). 
# For species use lowercase and an underscore so the directory path can be identified (e.g. lethrinus_variegatus)
species="stethojulis_interrupta"
# For Spp, this is the three letter species code. Capitalize the first letter.
Spp="Sin"

# Define the lcwgs & ssl directory path using the species variable. Edit if necessary. Check SSL.
lcwgs_path=$"/archive/carpenterlab/pire/pire_${species}_lcwgs"
ssl_path=$"/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/${species}"

# Define the input files. Edit if necessary. Check SSL.
file1="${lcwgs_path}/1st_sequencing_run/fq_raw/old_new_filenames.log"
file2="${lcwgs_path}/2nd_sequencing_run/fq_raw/old_new_filenames.log"
file3="${lcwgs_path}/3rd_sequencing_run/fq_raw/old_new_filenames.log"
file4="${ssl_path}/fq_raw_shotgun/old_new_filenames.log"


# Define the output file
output_file="${lcwgs_path}/GenErode_${Spp}_20k/config/old_new_lane_GenErode_${Spp}_config.log"

# Create the output file with the header
echo "origFileNames newFileNames lane" > "$output_file"

# Function to check if a file exists, extract lane info, and append to output
append_file() {
    local file=$1
    if [ -e "$file" ]; then
        echo "Including file: $file"
        
        # Read each line of the file and process it
        while read -r line; do
            # Skip lines that start with "preview"
            if [[ $line == preview* ]]; then
                continue
            fi
            
			# Skip lines that start with "Undetermined"
            if [[ $line == Undetermined* ]]; then
                continue
            fi
			
            # Extract the lane information
            origFileName=$(echo "$line" | awk '{print $1}')
            newFileName=$(echo "$line" | awk '{print $2}')

            # Extract lane info: pattern "_L[0-9]_" and remove the underscores
            lane=$(echo "$origFileName" | grep -o '_L[0-9]_' | sed 's/_//g')

            # Append the data to the output file
            echo "$origFileName $newFileName $lane" >> "$output_file"
        done < "$file"
    else
        echo "File not found: $file"
    fi
}

# Process each input file
append_file "$file1"
append_file "$file2"
append_file "$file3"
append_file "$file4"

# Completion message
echo "Concatenation completed. Output saved to $output_file"
