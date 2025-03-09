#!/bin/bash

# Script to concatenate two .gz files, remove duplicates while preserving the header, and compress the output.

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <inputfile1.gz> <inputfile2.gz> <outputfile.gz>"
    exit 1
fi

# Assign command line arguments to variables
inputfile1=$1
inputfile2=$2
outputfile=$3

# Extract the header from the first file
header=$(zcat "$inputfile1" | head -n 1)

# Concatenate, sort, remove duplicates, preserve the header, and compress
{
    echo "$header"
    (zcat "$inputfile1" "$inputfile2" | grep -v "^$header" | sort | uniq)
} | gzip > "$outputfile"

echo "Operation completed. Output is in $outputfile"
