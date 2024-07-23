# simple shell script to process MitoZ outputs
# copy this script to the folder fp1_clmp_fp2 folder where you ran the runMitoZ scripts
# and run (sh process_mitoZ_outsputs.sh)
# will output: 
# 1) a file with IDs for libraries that worked successfully (MitoZ_success.txt)
# 2) a file with IDs for libraries that failed because of low depth <10x of mitochondrial coverage (MitoZ_failure_lowdepth.txt)
# 3) a .fasta file with all of the successfully recovered COX1 sequences (MitoZ_output.fasta)
# A few analyses seem to fail because of reasons other than low coverage and I am not sure why
# Best option for batch IDing files is probably to use BOLD (boldsystems.org) - will need to create an account and sign in to batch search multiple files

grep -A1 "All done!" MitoZ*.out | grep "PNG" | sed 's/.*tmp//g' | sed 's/annotation\/visualization\/circos.png//g' | rev | cut -c2- | rev | cut -c2- > MitoZ_success.txt
grep -B5 "got no result!" MitoZ*.out | grep "fp1" | sed 's/.*tmp//g' | sed 's/assembly\/work71.scafSeq//g' | sed 's/-q work71.hmmtblout.besthit.sim -o work71.hmmtblout.besthit.sim.fa//g' | rev | cut -c3- | rev | cut -c2- > MitoZ_failure_lowdepth.txt
grep 'COX1' *MitoZ/*result/*.cds | sed 's/_MitoZ.*//g' | sed 's/^/>/g' > MitoZ_labels
grep -A1 'COX1' *MitoZ/*result/*.cds | grep 'cds-' | sed 's/.*cds-//g' > MitoZ_seqs
paste -d '\n' MitoZ_labels MitoZ_seqs > MitoZ_output.fasta
rm MitoZ_labels
rm MitoZ_seqs
