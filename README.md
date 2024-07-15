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
	• Alb: 42 - 54%, 62%: `Sin-APnd_005-Ex1-4B-lcwgs-1-1.2`
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
    	• Albatross: 1.3 - 8.4%, 17.4%: `Sin-APnd_023-Ex1-6D`, 23.7%: `Sin-APnd_006-Ex1-4C`
	• Contemporary: 0.0 - 6.9% 
	• Undetermined: 1.7%
‣ GC content -
    	• Albatross: 36.9 - 40.4%
	• Contemporary: 39.4 - 44.8%
	• Undetermined:39.2%
‣ passing filter - 
    	• Albatross: 66.9%: `Sin-APnd_005-Ex1-4B`, 89.4 - 94.6%
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

<details><summary>9. Remove duplicates with clumpify</summary>
<p>

## 9. Remove duplicates with clumpify

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
### 9e. Generate metadata on deduplicated FASTQ files
```
[hpc-0356@wahab-01 1st_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report"  "fq.gz"
Submitted batch job 3349946
```

**Results** (fq_fp1_clmp/fqc_clmp_report.html): 
*

```
‣ % duplication - 
    • Alb: 
    • Contemp: 
    • Undetermined: 
‣ GC content - 
    • Alb: 
    • Contemp: 
    • Undetermined: 
‣ length - 
    • Alb: 
    • Contemp: 
    • Undetermined: 
‣ number of reads -
    • Alb: 
    • Contemp: 
    • Undetermined: 
```
</p>

---
</details>

