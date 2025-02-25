#!/bin/bash

# Move files with the correct naming pattern
mv angsd_depth1_15_notrans.beagle.gz.pos.gz angsd_depth1_15_notrans_snplist.pos.gz
mv angsd_depth1_15_notrans.beagle.gz.beagle.gz angsd_depth1_15_notrans_snplist.beagle.gz
mv angsd_depth1_15_notrans.beagle.gz.mafs.gz angsd_depth1_15_notrans_snplist.mafs.gz
mv angsd_depth1_15_notrans.beagle.gz.saf.gz angsd_depth1_15_notrans_snplist.saf.gz
mv angsd_depth1_15_notrans.beagle.gz.saf.pos.gz angsd_depth1_15_notrans_snplist.saf.pos.gz
mv angsd_depth1_15_notrans.beagle.gz.saf.idx angsd_depth1_15_notrans_snplist.saf.idx
mv angsd_depth1_15_notrans.beagle.gz.arg angsd_depth1_15_notrans_snplist.arg
mv angsd_depth1_15_notrans.beagle.gz.depthSample angsd_depth1_15_notrans_snplist.depthSample
mv angsd_depth1_15_notrans.beagle.gz.depthGlobal angsd_depth1_15_notrans_snplist.depthGlobal

# Git add changes
git add angsd_depth1_15_notrans_snplist.arg angsd_depth1_15_notrans_snplist.depthSample angsd_depth1_15_notrans_snplist.depthGlobal

# Commit the changes with a detailed message
git commit -m "Renaming output files from the script get_beagle.gz to standardize the outfile pattern as 'angsd_depth1_15_notrans_snplist' instead of 'angsd_depth1_15_notrans.beagle.gz', which was confusing."

# Push changes to the repository
git push
