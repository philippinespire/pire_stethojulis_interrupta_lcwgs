#!/bin/bash

# Define input and output file names
input_file="historical_samples.txt"
output_file="historical_rescaled_samplenames.txt"

# Create or clear the output file
> "$output_file"

# Create a temporary file to hold unique sample names
temp_file=$(mktemp)

# Read the input file line by line
while read -r line; do
    # Skip the header row
    if [[ "$line" == samplename_index_lane* ]]; then
        continue
    fi

    # Extract the first column
    first_column=$(echo "$line" | awk '{print $1}')

    # Get the part before the first underscore
    first_part=$(echo "$first_column" | cut -d'_' -f1)

    # Append the first part to the temporary file
    echo "$first_part" >> "$temp_file"
done < "$input_file"

# Remove duplicate entries and format the output
sort "$temp_file" | uniq | awk '{printf "\"%s\",", $0}' > "$output_file"

# Remove the trailing comma and add the final double quotation mark
sed -i 's/,$//' "$output_file"

# Clean up temporary file
rm "$temp_file"
