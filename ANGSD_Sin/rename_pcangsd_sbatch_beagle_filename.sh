#!/bin/bash

# Ensure the loop does not run if no files match
shopt -s nullglob

# Find all .sbatch files that match the pattern pcangsd_*.sbatch
for file in pcangsd_*.sbatch; do
    # Replace '.beagle.gz' with '_snplist.beagle.gz' in the file content
    sed -i 's/\.beagle\.gz/_snplist.beagle.gz/g' "$file"
    echo "Updated: $file"
done

echo "All matching pcangsd_*.sbatch scripts have been updated."

# Check for changes before committing
if git diff --quiet; then
    echo "No changes detected, skipping commit."
else
    git add pcangsd_*.sbatch
    git commit -m "Replaced '.beagle.gz' with '_snplist.beagle.gz' as the '-b beagle.gz' input file. This is the correct file (angsd_depth1_15_notrans_snplist.beagle.gz) created from get_beagle.sbatch not the one created from snp_calling.sbatch (angsd_depth1_15_notrans.beagle.gz)."
    git push
fi
