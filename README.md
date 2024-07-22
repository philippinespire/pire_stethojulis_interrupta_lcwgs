<img src="https://inaturalist-open-data.s3.amazonaws.com/photos/236392150/original.jpg" alt="Sor" width="300"/>

# _Stethojulis interrupta_ lcWGS

## 1st sequencing run (test lane)
---
Analysis of low-coverage whole genome sequencing data for Sin 1st_sequencing_run.

fq_gz processing being done by Gianna Mazzei (started 7/5/24).

---

<details><summary>1. fq.gz Pre-processing</summary>
	
## 1. fq.gz Pre-processing
→ (*) _denotes steps with MultiQC Report Analyses_
<details><summary>0. Set-up</summary>
<p>

## 0. Set-up

Began by making a new repo on Github titled "pire_stethojulis_interrupta_lcwgs" 

Then went to my terminal and cloned the repo
```
[hpc-0356@wahab-01 ~]$ cd /archive/carpenterlab/pire/
[hpc-0356@wahab-01 pire]$ git clone {https://github.com/philippinespire/pire_stethojulis_interrupta_lcwgs}
```
Get a .gitignore file from another PIRE species repo and copy it here, then push this file to github.
```
[hpc-0356@wahab-01 pire]$ cd pire_stethojulis_interrupta_lcwgs
[hpc-0356@wahab-01 pire_stethojulis_interrupta_lcwgs]$ cp ../pire_taeniamia_zosterophora_lcwgs/.gitignore .
[hpc-0356@wahab-01 pire_stethojulis_interrupta_lcwgs]$ git pull
[hpc-0356@wahab-01 pire_stethojulis_interrupta_lcwgs]$ git add .gitignore
[hpc-0356@wahab-01 pire_stethojulis_interrupta_lcwgs]$ git commit -m "add gitignore"
[hpc-0356@wahab-01 pire_stethojulis_interrupta_lcwgs]$ git push
```
Make 1st sequencing run directory
```
[hpc-0356@wahab-01 pire_stethojulis_interrupta_lcwgs]$ mkdir 1st_sequencing_run
```
</p>

---
</details>

<details><summary>1. Get raw data</summary>
<p>

## 1. Get raw data

```
[hpc-0356@wahab-01 pire_stethojulis_interrupta_lcwgs]$ cd 1st_sequencing_run
[hpc-0356@wahab-01 1st_sequencing_run]$ rsync -r /archive/carpenterlab/pire/downloads/stethojulis_interrupta/1st_sequencing_run-lcwgs/fq_raw 1st_sequencing_run
```

</p>

---
</details>

<details><summary>2. Proofread the decode file</summary>
<p>

## 2. Proofread the decode file

```
[hpc-0356@wahab-01 fq_raw]$ cat Sin_lcwgs-testlane_SequenceNameDecode.tsv
```
Checked that I have sequencing data for all individuals in the decode file:
```
salloc
bash

[hpc-0356@d5-w6420b-23 fq_raw]$ ls *1.fq.gz | wc -l 
				ls *2.fq.gz | wc -l 
90
90
```
Number of lines:
```
[hpc-0356@d5-w6420b-23 fq_raw]$ wc -l Sin_lcwgs-testlane_SequenceNameDecode.tsv
89 Sin_lcwgs-testlane_SequenceNameDecode.tsv
```
Are there duplicates?
```
[hpc-0356@d5-w6420b-23 fq_raw]$ cat Sin_lcwgs-testlane_SequenceNameDecode.tsv| sort | uniq | wc -l
89
```
***Skip steps 3 and 4***

---
</details>

<details><summary>5. Perform a renaming dry run</summary>

## 5. Perform a renaming dry run

```
[hpc-0356@d1-w6420a-23 fq_raw]$ bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sin_lcwgs-testlane_SequenceNameDecode.tsv
```
---

</details>

<details><summary>6. Rename the files</summary>
	
## 6. Rename the files
```
[hpc-0356@d1-w6420a-23 fq_raw]$ bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sin_lcwgs-testlane_SequenceNameDecode.tsv rename
```
---

</details>

<details><summary>7. Check the quality of raw data (*)</summary>

## 7. Check the quality of raw data (*)

Execute `Multi_FASTQC.sh`:
```
[hpc-0356@d5-w6420b-23 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_raw" "fqc_raw_report"  "fq.gz"
Submitted batch job 3347515
```

### MultiQC output (fq_raw/fqc_raw_report.html):
* Overall, Albatross samples have much higher read counts
	* The Undetermined library has 166.8 million reads
	* Proportion of Undetermined Reads: 0.177
 * Almost all samples are failing Per Base Sequence Content
 * At this point, there are many overrepresented sequences (almost all failed) as well as high adapter content (all failed)

```
‣ % duplication - 
	• Alb: 20 - 50.1%
 	• Contemp: 0 - 16.6%
	• Undertermined: 34.9 - 35.8%
‣ GC content - 
	• Alb: 42 - 54%, 62%: [Sin-APnd_005-Ex1-4B-lcwgs-1-1.2]
 	• Contemp: 43 - 54%
	• Undetermined: 47 - 54%
‣ number of reads - 
	• Alb: 3.3 - 62.8 mil
 	• Contemp: 0 - 7.2 mil
	• Undetermined: 166.8 mil
```
---

</details>

<details><summary>8. First trim (*)</summary>
<p>

## 8. First trim (*)
	
```
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw fq_fp1
Submitted batch job 3349635
```

### Review the FastQC output (fq_fp1/1st_fastp_report.html):
After 1st trim:
* `Sin-CPnd_016-Ex1-1E-lcwgs-1-1` has only 24 reads
* After filtering, GC content appears to have stabilized, except for `Sin-CPnd_016-Ex1-1E-lcwgs-1-1`. This volatility is likely from the low read count.

```  
‣ % duplication - 
    	• Albatross: 1.3 - 8.4%, 17.4%: [Sin-APnd_023-Ex1-6D], 23.7%: [Sin-APnd_006-Ex1-4C]
	• Contemporary: 0.0 - 6.9% 
	• Undetermined: 1.7%
‣ GC content -
    	• Albatross: 36.9 - 40.4%
	• Contemporary: 39.4 - 44.8%
	• Undetermined:39.2%
‣ passing filter - 
    	• Albatross: 66.9%: [Sin-APnd_005-Ex1-4B], 89.4 - 94.6%
	• Contemporary: 84.6 - 95.9%
	• Undetermined: 73.0%
‣ % adapter - 
    	• Albatross: 82.3 - 96.2%
	• Contemporary: 48.7 - 93.4%
	• Undetermined: 83.6%
‣ number of reads - 
    	• Albatross: - 125.5 mil
	• Contemporary: 0 - 14.4 mil
	• Undetermined: 333.5 mil
```

---
</details>

<details><summary>9. Remove duplicates with clumpify (*)</summary>
<p>

## 9. Remove duplicates with clumpify (*)

### 9a. Remove duplicates
 ```
[hpc-0356@wahab-01 1st_sequencing_run]$ bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/hpc-0356 20
Submitted batch job 3349789
```

### 9c. Check duplicate removal success

Clumpify Successfully worked on all samples
```
[hpc-0356@wahab-01 1st_sequencing_run]$ salloc
[hpc-0356@d6-w6420b-07 1st_sequencing_run]$ enable_lmod
[hpc-0356@d6-w6420b-07 1st_sequencing_run]$ module load container_env R/4.3 
[hpc-0356@d4-w6420b-07 1st_sequencing_run]$ crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save
[hpc-0356@d6-w6420b-07 1st_sequencing_run]$ exit
```
### 9d. Clean the scratch drive
```
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/cleanSCRATCH.sbatch /scratch/hpc-0356 "*clumpify*temp*"
Submitted batch job 3349945
```
### 9e. Generate metadata on deduplicated FASTQ files (*)
```
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report"  "fq.gz"
Submitted batch job 3349946
```

**Results** (fq_fp1_clmp/fqc_clmp_report.html): 
* `Sin-CPnd_016-Ex1-1E-lcwgs-1-1` still very volatile on Per Sequence GC Content -> low read count
* Still quite a few overrepresented sequences
* % duplication going down

```
‣ % duplication - 
    • Alb: 1.8 - 6.4%
    • Contemp: 0 - 1.3%
    • Undetermined: 4.7%
‣ GC content - 
    • Alb: 36 - 41%
    • Contemp: 39 - 44%
    • Undetermined: 40%
‣ length - 
    • Alb: 77 - 88 bp
    • Contemp: 81 - 130 bp
    • Undetermined: 85 bp
‣ number of reads -
    • Alb: 2.5 - 37.8 mil
    • Contemp: 0 - 1.7 mil, 6.3 mil: [Sin-CPnd_088-Ex1-2D]
    • Undetermined: 83.3 mil
```
</p>

---
</details>


<details><summary>10. Second trim (*)</summary>
<p>

## 10. Second trim (*)
 
```
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2.sbatch fq_fp1_clmp fq_fp1_clmp_fp2 33
Submitted batch job 3350043
```

### Review the FastQC output (fq_fp1_clmp_fp2/2nd_fastp_report.html):
After 2nd trim:
* Duplication dropped
* % passing filter is high (96%+), besides `Undetermined` and `Sin-CPnd_016-Ex1-1E` in the high 80s
* Everything is looking normal, besides `Sin-CPnd_016-Ex1-1E-lcwgs-1-1`. This individual has a low number of reads (22) which is manifesting as volatility on graphs displaying Insert Size Distribution, Sequence Quality, and GC Content.

```
‣ % duplication -
	• Alb: 0.2 - 5.5%
	• Contemp: 0.0 - 0.3%
	• Undetermined: 0.4%
‣ GC content -
	• Alb: 36.9 - 41.1%
	• Contemp: 39.5 - 44.7%
	• Undetermined: 39.4%
‣ passing filter -
	• Alb: 96.1 - 97.7%
	• Contemp: 81.8: [Sin-CPnd_016-Ex1-1E], 96.6 - 98.6%
	• Undetermined: 89.6%
‣ % adapter -
	• Alb: 2.3 - 2.5%
	• Contemp: 0.0 - 2.8%
	• Undetermined: 2.5%
‣ number of reads -
	• Alb: 5.0 - 75.6 mil
	• Contemp: 0.0 - 3.4 mil, 12.6 mil: [Sin-CPnd_088-Ex1-2D]
	• Undetermined: 166.5 mil
```

---
</details>

<details><summary>11. Decontaminate files (*)</summary>
<p>

## 11. Decontaminate files (*)

<details><summary>11a. Run fastq_screen</summary>
	
### 11a. Run fastq_screen

```
[hpc-0356@wahab-01 1st_sequencing_run]$ bash
[hpc-0356@wahab-01 1st_sequencing_run]$ fqScrnPATH=/home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash
indir=fq_fp1_clmp_fp2
[hpc-0356@wahab-01 1st_sequencing_run]$ outdir=/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn
nodes=20
[hpc-0356@wahab-01 1st_sequencing_run]$ bash $fqScrnPATH $indir $outdir $nodes
```
---

</details>

<details><summary>11b. Check for Errors</summary>
	
### 11b. Check for Errors

```
[hpc-0356@wahab-01 1st_sequencing_run]$ bash
[hpc-0356@wahab-01 1st_sequencing_run]$ outdir=/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/validateFQ.sbatch $outdir "*filter.fastq.gz"
Submitted batch job 3351748

# when complete check the $outdir/fqValidateReport.txt file
less -S $outdir/fqValidationReport.txt file
```
#### Confirm files were succesfully completed:

Check that all 5 files were created for each fqgz file:
```
[hpc-0356@wahab-01 1st_sequencing_run]$ ls $outdir/*r1.tagged.fastq.gz | wc -l
					ls $outdir/*r2.tagged.fastq.gz | wc -l
					ls $outdir/*r1.tagged_filter.fastq.gz | wc -l
					ls $outdir/*r2.tagged_filter.fastq.gz | wc -l 
					ls $outdir/*r1_screen.txt | wc -l
					ls $outdir/*r2_screen.txt | wc -l
					ls $outdir/*r1_screen.png | wc -l
					ls $outdir/*r2_screen.png | wc -l
					ls $outdir/*r1_screen.html | wc -l
					ls $outdir/*r2_screen.html | wc -l
90
90
90
90
90
90
90
90
90
90
```
For each, you should have the same number as the number of input files (number of fq.gz files):
```
[hpc-0356@wahab-01 1st_sequencing_run]$ ls $indir/*r1.fq.gz | wc -l
                                        ls $indir/*r2.fq.gz | wc -l
90
90
```
Check for any errors in the `*out` files: (none)
```
[hpc-0356@wahab-01 1st_sequencing_run]$ grep 'error' slurm-fqscrn.*out
					grep 'No reads in' slurm-fqscrn.*out
					grep 'FATAL' slurm-fqscrn.*out
```
Looked at the outfiles to see if there are any unzipped files with the word temp, which means that the job didn't finish and needs to be rerun: (none)
```
[hpc-0356@wahab-01 1st_sequencing_run]$ outdir=/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn
					ls $outdir/*temp*
ls: cannot access '/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/*temp*': No such file or directory
```

**Since fq screen worked properly, there are no files that need to be rerun!**

---

</details>

<details><summary>11e. Move output files</summary>
	
### 11e. Move output files
The recommended instructions using `screen mv` have not been working for me so I did this:
```
[hpc-0356@wahab-01 1st_sequencing_run]$ mv /scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Sin* /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_fp1_clmp_fp2_fqscrn

#for some reason mv /scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined* did not work so I had to move each file:

[hpc-0356@wahab-01 1st_sequencing_run]$ mv /scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r1_screen.html \
   					/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r1_screen.png \
   					/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r1_screen.txt \
   					/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r1.tagged.fastq.gz \
   					/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r1.tagged_filter.fastq.gz \
   					/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r2_screen.html \
   					/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r2_screen.png \
   					/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r2_screen.txt \
   					/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r2.tagged.fastq.gz \
					/scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/Undetermined.clmp.fp2_r2.tagged_filter.fastq.gz \
					/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_fp1_clmp_fp2_fqscrn/

[hpc-0356@wahab-01 1st_sequencing_run]$ mv /scratch/hpc-0356/fq_fp1_clmp_fp2_fqscrn/fqValidationReport.txt /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_fp1_clmp_fp2_fqscrn/

```
---
</details>

<details><summary>11f. Run MultiQC (*)</summary>
	
### 11f. Run MultiQC (*)

```
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastq_screen_report
Submitted batch job 3353560
```

Review the MultiQC output (fq_fp1_clmp_fp2_fqscrn/fastq_screen_report.html):
* Everything looked normal, no notable signs of contamination
* `Sin-CPnd_016-Ex1-1E` was 100% no hits, 0% multiple genomes -> from low read count 

```
‣ multiple genomes -
	• Alb: 2.5 - 5.0%
	• Contemp: 0.0 - 6.5%
	• Undetermined: 3.6 - 4.6%
‣ no hits -
	• Alb: 92.2 - 96.0%
	• Contemp: 92.3 - 100% 
	• Undetermined: 93.4 - 94.3%
```

</details>

---

</details>

<details><summary>12. Repair FASTQ Files Messed Up by FASTQ_SCREEN (*)</summary>
<p>

## 12. Repair FASTQ Files Messed Up by FASTQ_SCREEN (*)

#### Execute `runREPAIR.sbatch`

Next we need to re-pair our reads. `runREPAIR.sbatch` matches up forward (r1) and reverse (r2) reads so that the `*1.fq.gz` and `*2.fq.gz` files have reads in the same order
```
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_rprd 5
Submitted batch job 3353569 
```
#### Confirm that the paired end fq.gz files are complete and formatted correctly:

Start by running the script:
```
[hpc-0356@wahab-01 1st_sequencing_run]$ bash
[hpc-0356@wahab-01 1st_sequencing_run]$ SCRIPT=/home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/validateFQPE.sbatch 
                                        DIR=fq_fp1_clmp_fp2_fqscrn_rprd
                                        fqPATTERN="*fq.gz"
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch $SCRIPT $DIR $fqPATTERN
Submitted batch job 3353571
```

Check the SLURM `out` file and `fqValidationReport.txt` to determine if all of the fqgz files are valid
```
[hpc-0356@wahab-01 1st_sequencing_run]$ cat valiate_FQ_-3353571.out
PAIRED END FASTQ VALIDATION REPORT

Directory: fq_fp1_clmp_fp2_fqscrn_rprd
File Pattern: *fq.gz
File extensions found: .R1.fq.gz .R2.fq.gz

Number of paired end fq files evaluated: 90
Number of paired end fq files validated: 90

Errors Reported:
```
#### Run `Multi_FASTQC`
```
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "./fq_fp1_clmp_fp2_fqscrn_rprd" "fqc_rprd_report" "fq.gz"
Submitted batch job 3353747
```

#### Review MultiQC output (fq_fp1_clmp_fp2_fqscrn_rprd/fqc_rprd_report.html):
* Only contemporary individuals are stll failing Per Sequence GC Content
* Mean Quality Scores ~40% not passing

```
‣ % duplication -
	• Alb: 1.7 - 6.7%
	• Contemp: 0.0 - 0.8%
	• Undetermined: 3.6 - 3.7%
‣ GC content -
	• Alb: 36 - 40%
	• Contemp: 39 - 44%
	• Undetermined: 38% 
‣ length -
	• Alb: 75 - 86 bp
	• Contemp: 80 - 127 bp
	• Undetermined: 81 - 82 bp
‣ number of reads -
	• Alb: 2.3 - 35.1 mil
	• Contemp: 0.0 - 5.9 mil
	• Undetermined: 69 mil
```

---

</details>

<details><summary>14. Clean Up</summary>
<p>

## 14. Clean Up

Move any .out files into the logs dir
```
[hpc-0356@wahab-01 1st_sequencing_run]$ mkdir logs
[hpc-0356@wahab-01 1st_sequencing_run]$ mv *out logs/
```

---

</details>

<details><summary>15. Map Repaired `fq.gz` to Reference Genome</summary>
<p>

## 15. Map Repaired `fq.gz` to Reference Genome

The following steps 15 & 16 are from the [pire_lcwgs_data_processing repo](https://github.com/philippinespire/pire_lcwgs_data_processing).

### Get your reference genome

Make a new directory `refGenome` and `cd` into it
```
[hpc-0356@wahab-01 1st_sequencing_run]$ mkdir refGenome
[hpc-0356@wahab-01 1st_sequencing_run]$ cd refGenome/
```

This species is not on ncbi, but we do have a reference genome in house. Copy this file `scaffolds.fasta` into refGenome:
```
[hpc-0356@wahab-01 refGenome]$ cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/refGenome/
```

### Map your reads to your reference genome
Start by cloning the dDocentHPC repo to gain access to the scripts we need to run:
```
[hpc-0356@wahab-01 1st_sequencing_run]$ git clone https://github.com/cbirdlab/dDocentHPC
```
Create a `mkBAM_ddocent` directory and copy all `fq.gz` files from `fq_fp1_clmp_fp2_fqscrn_rprd` into this new directory:
```
[hpc-0356@wahab-01 1st_sequencing_run]$ mkdir mkBAM_ddocent
[hpc-0356@wahab-01 1st_sequencing_run]$ rsync fq_fp1_clmp_fp2_fqscrn_rprd/*fq.gz mkBAM_ddocent
```
Copy the reference genome to `mkBAM_ddocent` as well as the scripts we need to run:
```
[hpc-0356@wahab-01 1st_sequencing_run]$ cp refGenome/scaffolds.fasta mkBAM_ddocent/reference.denovoSSL.Sin.fasta

[hpc-0356@wahab-01 1st_sequencing_run]$ cd mkBAM_ddocent/
[hpc-0356@wahab-01 mkBAM_ddocent]$ cp ../dDocentHPC/configs/config.6.lcwgs .
[hpc-0356@wahab-01 mkBAM_ddocent]$ cp ../dDocentHPC/dDocentHPC.sbatch .
```
Before moving forward, I needed to edit the `config.6.lcwgs` file to suit this species:
```
[hpc-0356@wahab-01 mkBAM_ddocent]$ nano config.6.lcwgs

# within file:
# change Cutoff1 and Cutoff2 to "denovoSSL" and "Sin"

----------mkREF: Settings for de novo assembly of the reference genome----------------------------------------->
PE              Type of reads for assembly (PE, SE, OL, RPE)                                    PE=ddRAD & ezRA>
0.9             cdhit Clustering_Similarity_Pct (0-1)                                                   Use cdh>
denovoSSL       Cutoff1 (integer)                                                                              >
Sin             Cutoff2 (integer)                                                                              >
0.05    rainbow merge -r <percentile> (decimal 0-1)                                             Percentile-base>
0.95    rainbow merge -R <percentile> (decimal 0-1)                                             Percentile-base>
--------------------------------------------------------------------------------------------------------------->
```
Then, I needed to alter the `dDocentHPC.sbatch` file to load the newer version:
```
[hpc-0356@wahab-01 mkBAM_ddocent]$ nano dDocentHPC.sbatch

# within file:
# change where the "#" is

enable_lmod
# module load container_env ddocent/2.7.8
module load container_env ddocent/2.9.4
```

Now, I am able to map reads.

Execute `dDocentHPC.sbatch mkBAM config.6.lcwgs` which aligns reads (in FASTQ format) to a reference genome and creates BAM files (Binary Alignment Map files)
```
[hpc-0356@wahab-01 mkBAM_ddocent]$ sbatch dDocentHPC.sbatch mkBAM config.6.lcwgs
Submitted batch job 3353876
```
---

</details>

<details><summary>16. Filter BAM Files</summary>

## 16. Filter BAM Files

Filtering BAM files ensures data quality, reduces noise, improves analysis accuracy, and prepares data for downstream genomic analyses.
```
[hpc-0356@wahab-01 mkBAM_ddocent]$ sbatch dDocentHPC.sbatch fltrBAM config.6.lcwgs
Submitted batch job 3355185
```

---

</details>

<details><summary>17. Generate Number of Mapped Reads</summary>

## 17. Generate Number of Mapped Reads

```
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/mappedReadStats.sbatch mkBAM_ddocent mkBAM_ddocent/coverageMappedReads
Submitted batch job 3355582
```

#### Review Output (coverageMappedReads/out__ReadStats.tsv):
* 6 contemporary libaries with under 1000 reads:
	* `Sin-CPnd_016-Ex1-1E-lcwgs-1-1.clmp.fp2_repr.denovoSSL.Sin-RG.bam`:	11
	* `Sin-CPnd_037-Ex1-4F-lcwgs-1-1.clmp.fp2_repr.denovoSSL.Sin-RG.bam`:	113
	* `Sin-CPnd_027-Ex1-3A-lcwgs-1-1.clmp.fp2_repr.denovoSSL.Sin-RG.bam`:	226
	* `Sin-CPnd_014-Ex1-3F-lcwgs-1-1.clmp.fp2_repr.denovoSSL.Sin-RG.bam`:	454
	* `Sin-CPnd_026-Ex1-1G-lcwgs-1-1.clmp.fp2_repr.denovoSSL.Sin-RG.bam`:	457
	* `Sin-CPnd_087-Ex1-4B-lcwgs-1-1.clmp.fp2_repr.denovoSSL.Sin-RG.bam`:	669
* Overall, low #'s for Contemporary individuals -> 24 more are under 10,000 reads 
* Mean depth with coverage is pretty good for Albatross: between 1.16 and 3.1
```
numreads:
* Alb: 3,095,833 - 5,3152,622
* Contemp: 11 - 9,716,147
* Und: 97,814,629

meanreadlength:
* Alb: 76.05 - 87.22
* Contemp: 83.46 - 128.20
* Und: 82.63

meandepth_wcvg:
* Alb: 1.16 - 3.10
* Contemp: 0.997 - 1.39
* Und: 4.56

numpos:
* 1,356,329,670 bp

numpos_wcvg:
* Alb: 110,401,751 - 716,514,117 bp
* Contemp: 665 - 339,212,571 bp
* Und: 894,543,777 bp

meandepth:
* Alb: 0.097 - 1.64
* Contemp: 0.0000005 - 0.35
* Und: 3.01

pctpos_wcvg:
* Alb: 8.14 - 52.83%
* Contemp: 0.00005 - 25.01%
* Und: 65.95%
```
---

</details>

<details><summary>18. Extract mitochondrial genomes from read data</summary>

## 18. Extract mitochondrial genomes from read data

If there are potential cryptic species in the data, we should try to extract mitochondrial genes from the read data to get an idea of species IDs. You use MitoZ to do so.

Copy the runMitoZ bash and sbatch scripts to your sequencing project directory
```
[hpc-0356@wahab-01 pire_stethojulis_interrupta_lcwgs]$ cp /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMitoZ* 1st_sequencing_run
```
* The `runMitoZ_array.bash` and `runMitoZ_array.sbatch` scripts need to be altered before running. Using nano and ctrl+\ I found every instance of `_clmp.fp2_r1.fq.gz` and replaced it with `.clmp.fp2_r1.fq.gz`.

Now, execute the runMitoZ script:
```
[hpc-0356@wahab-01 1st_sequencing_run]$ bash runMitoZ_array.bash /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_fp1_clmp_fp2 32
Submitted batch job 3355700
```
For the next script to work, I need my MitoZ output files to be in my `fq_fp1_clmp_fp2` directory.
```
[hpc-0356@wahab-01 1st_sequencing_run]$ mv MitoZ*.out fq_fp1_clmp_fp2/
```
Then, after copying it, I was able to run the `process_MitoZ_outputs.sh` script
```
[hpc-0356@wahab-01 1st_sequencing_run]$ cd fq_fp1_clmp_fp2
[hpc-0356@wahab-01 fq_fp1_clmp_fp2]$ cp /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/process_MitoZ_outputs.sh .

[hpc-0356@wahab-01 fq_fp1_clmp_fp2]$ sh process_MitoZ_outputs.sh
```
Now, we can see which individuals MitoZ worked for: 

**Individuals that succeeded:**
```
[hpc-0356@wahab-01 fq_fp1_clmp_fp2]$ cat MitoZ_success.txt
Undetermined
```

**Individuals that failed:**
All of them, besides Undetermined...
