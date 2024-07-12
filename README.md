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
*

```
‣ % duplication - 
	• Alb: 
 	• Contemp: 
	• Undertermined: 
‣ GC content - 
	• Alb: 
 	• Contemp: 
	• Undetermined: 
‣ number of reads - 
	• Alb: 
 	• Contemp: 
```
---

</details>

