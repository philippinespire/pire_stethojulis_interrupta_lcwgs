#!/bin/bash

# Script to rename duplicate headers in a FASTA file
# Usage: ./rename_duplicate_fasta_headers.sh input.fasta output_cleaned.fasta

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.fasta output_cleaned.fasta"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

declare -A header_count
touch "$OUTPUT_FILE"

while IFS= read -r line; do
    if [[ "$line" == ">"* ]]; then
        if [[ -v header_count["$line"] ]]; then
            ((header_count["$line"]++))
            new_header="${line}_dup${header_count["$line"]}"
            echo "$new_header" >> "$OUTPUT_FILE"
        else
            header_count["$line"]=0
            echo "$line" >> "$OUTPUT_FILE"
        fi
    else
        echo "$line" >> "$OUTPUT_FILE"
    fi
done < "$INPUT_FILE"

echo "Processing complete. Cleaned FASTA saved as: $OUTPUT_FILE"
