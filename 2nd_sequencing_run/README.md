<img src="https://inaturalist-open-data.s3.amazonaws.com/photos/236392150/original.jpg" alt="Sin" width="300"/>

# *Stethojulis interrupta* lcWGS Analysis

## 2nd Sequencing Run

Analysis of low-coverage whole genome sequencing data for *Stethojulis interrupta* from Pandanon Island (APnd, CPnd).

fq.gz processing done by John Whalen and Gianna Mazzei (January 2025).

---

## fq.gz Pre-processing

This portion follows the instructions in the [pire_fq_gz_processing](https://github.com/philippinespire/pire_fq_gz_processing) repository. 

→ (*) _denotes steps with MultiQC Report Analyses_

<details><summary>1. Set-up</summary>

### 1. Set-up

Make 2nd sequencing run directory and a README.
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run

mkdir 2nd_sequencing_run

nano 2nd_sequencing_run/README.md
```
---
</details>


<details><summary>2. Get raw data</summary>

### 2. Get raw data

Raw fq.gz files were uploaded to `/archive/carpenterlab/pire/downloads/stethojulis_interrupta/2nd_sequencing_run-lcwgs/fq_raw` by Sharon Magnuson on 1/13/25.
```
rsync -a /archive/carpenterlab/pire/downloads/stethojulis_interrupta/2nd_sequencing_run-lcwgs/fq_raw 2nd_sequencing_run &
```
---
</details>


<details><summary>3. Proofread the decode file</summary>

### 3. Proofread the decode file

```
cat Sin_LCWGS-FullSeq_SequenceNameDecode.tsv
```

<details><summary>Sin_LCWGS-FullSeq_SequenceNameDecode.tsv</summary>

```
Sequence_Name	Extraction_ID
SiA04001	Sin-APnd_001-Ex1-6G-lcwgs-1-2
SiA04002	Sin-APnd_002-Ex1-3G-lcwgs-1-2
SiA04003	Sin-APnd_003-Ex1-3H-lcwgs-1-2
SiA04004	Sin-APnd_004-Ex1-4A-lcwgs-1-2
SiA04005	Sin-APnd_005-Ex1-4B-lcwgs-1-2
SiA04006	Sin-APnd_006-Ex1-4C-lcwgs-1-2
SiA04007	Sin-APnd_007-Ex1-4D-lcwgs-1-2
SiA04008	Sin-APnd_008-Ex1-4E-lcwgs-1-2
SiA04009	Sin-APnd_009-Ex1-4F-lcwgs-1-2
SiA04010	Sin-APnd_010-Ex1-4G-lcwgs-1-2
SiA04011	Sin-APnd_011-Ex1-4H-lcwgs-1-2
SiA04012	Sin-APnd_012-Ex1-5A-lcwgs-1-2
SiA04013	Sin-APnd_013-Ex1-5B-lcwgs-1-2
SiA04014	Sin-APnd_014-Ex1-5C-lcwgs-1-2
SiA04015	Sin-APnd_015-Ex1-5D-lcwgs-1-2
SiA04016	Sin-APnd_016-Ex1-5E-lcwgs-1-2
SiA04017	Sin-APnd_017-Ex1-5F-lcwgs-1-2
SiA04018	Sin-APnd_018-Ex1-5G-lcwgs-1-2
SiA04019	Sin-APnd_019-Ex1-5H-lcwgs-1-2
SiA04020	Sin-APnd_020-Ex1-6A-lcwgs-1-2
SiA04021	Sin-APnd_021-Ex1-6B-lcwgs-1-2
SiA04022	Sin-APnd_022-Ex1-6C-lcwgs-1-2
SiA04023	Sin-APnd_023-Ex1-6D-lcwgs-1-2
SiA04024	Sin-APnd_024-Ex1-6E-lcwgs-1-2
SiA04025	Sin-APnd_025-Ex1-6F-lcwgs-1-2
SiC01013	Sin-CPnd_013-Ex1-4E-lcwgs-1-2
SiC01015	Sin-CPnd_015-Ex1-4A-lcwgs-1-2
SiC01018	Sin-CPnd_018-Ex1-11A-lcwgs-1-2
SiC01019	Sin-CPnd_019-Ex1-1H-lcwgs-1-2
SiC01020	Sin-CPnd_020-Ex1-12E-lcwgs-1-2
SiC01021	Sin-CPnd_021-Ex1-3D-lcwgs-1-2
SiC01022	Sin-CPnd_022-Ex1-1D-lcwgs-1-2
SiC01023	Sin-CPnd_023-Ex1-12B-lcwgs-1-2
SiC01024	Sin-CPnd_024-Ex1-12C-lcwgs-1-2
SiC01025	Sin-CPnd_025-Ex1-3B-lcwgs-1-2
SiC01028	Sin-CPnd_028-Ex1-12H-lcwgs-1-2
SiC01029	Sin-CPnd_029-Ex1-4D-lcwgs-1-2
SiC01031	Sin-CPnd_031-Ex1-3G-lcwgs-1-2
SiC01032	Sin-CPnd_032-Ex1-3E-lcwgs-1-2
SiC01033	Sin-CPnd_033-Ex1-1B-lcwgs-1-2
SiC01034	Sin-CPnd_034-Ex1-3C-lcwgs-1-2
SiC01035	Sin-CPnd_035-Ex1-12D-lcwgs-1-2
SiC01038	Sin-CPnd_038-Ex1-11C-lcwgs-1-2
SiC01039	Sin-CPnd_039-Ex1-10F-lcwgs-1-2
SiC01040	Sin-CPnd_040-Ex1-11E-lcwgs-1-2
SiC01042	Sin-CPnd_042-Ex1-10D-lcwgs-1-2
SiC01043	Sin-CPnd_043-Ex1-1C-lcwgs-1-2
SiC01044	Sin-CPnd_044-Ex1-2C-lcwgs-1-2
SiC01045	Sin-CPnd_045-Ex1-11H-lcwgs-1-2
SiC01049	Sin-CPnd_049-Ex1-4C-lcwgs-1-2
SiC01050	Sin-CPnd_050-Ex1-9B-lcwgs-1-2
SiC01051	Sin-CPnd_051-Ex1-12G-lcwgs-1-2
SiC01053	Sin-CPnd_053-Ex1-9G-lcwgs-1-2
SiC01058	Sin-CPnd_058-Ex1-9D-lcwgs-1-2
SiC01061	Sin-CPnd_061-Ex1-9A-lcwgs-1-2
SiC01062	Sin-CPnd_062-Ex1-11D-lcwgs-1-2
SiC01063	Sin-CPnd_063-Ex1-9F-lcwgs-1-2
SiC01065	Sin-CPnd_065-Ex1-11B-lcwgs-1-2
SiC01067	Sin-CPnd_067-Ex1-9C-lcwgs-1-2
SiC01074	Sin-CPnd_074-Ex1-12A-lcwgs-1-2
SiC01075	Sin-CPnd_075-Ex1-11G-lcwgs-1-2
SiC01076	Sin-CPnd_076-Ex1-10E-lcwgs-1-2
SiC01079	Sin-CPnd_079-Ex1-9H-lcwgs-1-2
SiC01080	Sin-CPnd_080-Ex1-2E-lcwgs-1-2
SiC01081	Sin-CPnd_081-Ex1-10G-lcwgs-1-2
SiC01085	Sin-CPnd_085-Ex1-4H-lcwgs-1-2
SiC01088	Sin-CPnd_088-Ex1-2D-lcwgs-1-2
SiC01089	Sin-CPnd_089-Ex1-9E-lcwgs-1-2
SiC01090	Sin-CPnd_090-Ex1-12F-lcwgs-1-2
SiC01092	Sin-CPnd_092-Ex1-11F-lcwgs-1-2
SiC01093	Sin-CPnd_093-Ex1-10C-lcwgs-1-2
SiC01094	Sin-CPnd_094-Ex1-3H-lcwgs-1-2
SiC01095	Sin-CPnd_095-Ex1-2B-lcwgs-1-2
```

</p>
</details> 

Check the number of file names in the decode file. 74 lines including the header, so 73 file names. 
```
cat fq_raw/Sin_LCWGS-FullSeq_SequenceNameDecode.tsv | wc -l
74
```

Check the number of fq raw files. 
```
ls Si*1.fq.gz | wc -l
73

ls Si*2.fq.gz | wc -l
73

ls Undetermined*1.fq.gz | wc -l
1

ls Undetermined*2.fq.gz | wc -l
1
```
The Undetermined files are not included in the decode file. Undetermined files just become `Undetermined.1.fq.gz` & `Undetermined.2.fq.gz`.

---
</details>


<details><summary>4. Perform a renaming dry run</summary>

### 4. Perform a renaming dry run

Renaming dry run looks good. Only 1 underscore that separates the PopSampleID from the LibraryID. But no lane information in the Library ID, which is ok. All files (except Undetermined\*) have the same sequencing information in the original file name `CKDL240043841-1A_22M5VHLT4_L6`.
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sin_lcwgs-testlane_SequenceNameDecode.tsv
```
---
</details>


<details><summary>5. Rename the files</summary>
	
### 5. Rename the files

Rename the files for real. Renaming ran correctly. 
```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sin_lcwgs-testlane_SequenceNameDecode.tsv rename
```
---

</details>

<details><summary>6. Check the quality of raw data (*)</summary>

## 6. Check the quality of raw data (*)

Execute `Multi_FASTQC.sh`:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_raw" "fqc_raw_report"  "fq.gz"
Submitted batch job 4265307
```

### MultiQC output (fq_raw/fqc_raw_report.html):
* low # reads for contemporary; albatross high
* Many duplicate reads in albatross and undetermined
* 1/148 passing Per Base Sequence Content
* 13/148 passing Per Sequence GC Content
	* peaks around 45%, 70%, 78%, and 100%
* All failing adapter content

```
‣ % duplication - 
    • Alb: 27 - 62.7%
    • Contemp: 3.5 - 26.1%
    • Undertermined: 39.7 - 40.7%
‣ GC content - 
    • Alb: 43 - 63%
    • Contemp: 43 - 60%
    • Undetermined: 49 - 54%
‣ number of reads - 
    • Alb: 28.5 - 129.2 mil
    • Contemp: 0.0 - 3.9 mil
    • Undetermined: 287 mil
```
---
</details>

<details><summary>7. First trim (*)</summary>

## 7. First trim (*)

Run `runFASTP_1st_trim.sbatch`:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw fq_fp1
Submitted batch job 4265443
```
### Review the FastQC output (fq_fp1/1st_fastp_report.html):
* Sequence Quality much better after filtering. Quality dips from ~40 to ~27 between reads 90 and 150
* GC content much better after filtering. CPnd_013 is an outlier ~50%, others between 36 - 43%
* Read N Content did not appear to change after filtering; some noise still

```
‣ % duplication - 
    • Alb: 6 - 44%
    • Contemp: 0.9 - 7.8%
    • Undertermined: 2.7%
‣ GC content -
    • Alb: 37.5 - 40.6%
    • Contemp: 40 - 43.3%; 50.1% [CPnd_013]
    • Undertermined: 40.8%
‣ passing filter - 
    • Alb: 67 -  96.2%
    • Contemp:  73.2 - 97.6%
    • Undertermined: 78.9%
‣ % adapter - 
    • Alb:  81.5 - 95.7%
    • Contemp: 45.5 - 91.1%
    • Undertermined: 84.1%
‣ number of reads - 
    • Alb: ~ 52 - 242 mil
    • Contemp: ~ 0.009 - 7.6 mil
    • Undertermined: ~ 453 mil
```
---
</details>

<details><summary>8. Remove duplicates with clumpify (*)</summary>

## 8. Remove duplicates with clumpify (*)

<details><summary>8a. Remove duplicates</summary>
	
### 8a. Remove duplicates

```
[hpc-0373@wahab-01 2nd_sequencing_run]$ bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/hpc-0373 20
Submitted batch job 4265458
```
</details>

<details><summary>8b. Check duplicate removal success</summary>
	
### 8b. Check duplicate removal success

Clumpify failed on some samples:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ salloc
[hpc-0373@d1-w6420a-05 2nd_sequencing_run]$ enable_lmod
[hpc-0373@d1-w6420a-05 2nd_sequencing_run]$ module load container_env R/4.3 
[hpc-0373@d1-w6420a-05 2nd_sequencing_run]$ crun R < /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/checkClumpify_EG.R --no-save

Clumpify failed on 3 samples. Inspect the following outfiles:
clmp_r1r2_-4265458_15.out
clmp_r1r2_-4265458_16.out
clmp_r1r2_-4265458_2.out
```

</details> 

<details><summary>8c. Rerun Clumpify on failed files</summary>
	
### 8c. Rerun Clumpify on failed files

The individuals that failed are `Sin-APnd_016-Ex1-5E-lcwgs-1-2`, `Sin-APnd_017-Ex1-5F-lcwgs-1-2`, & `Sin-APnd_003-Ex1-3H-lcwgs-1-2`

Isolate them in a new directory to be rerun:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ mkdir fq_fp1_clmp_rpt
[hpc-0373@wahab-01 2nd_sequencing_run]$ cp fq_fp1/Sin-APnd_016-Ex1-5E-lcwgs-1-2* fq_fp1/Sin-APnd_017-Ex1-5F-lcwgs-1-2* fq_fp1/Sin-APnd_003-Ex1-3H-lcwgs-1-2* fq_fp1_clmp_rpt
```

Re-run Clumpify:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1_clmp_rpt fq_fp1_clmp /scratch/hpc-0373 20
Submitted batch job 4269823
```

Check the out files to make sure it worked: cat `clmp_r1r2_-4269823_0.out` `clmp_r1r2_-4269823_1.out` `clmp_r1r2_-4269823_2.out`

All looks good.

</details>

<details><summary>8d. Clean the scratch drive</summary>
	
### 8d. Clean the scratch drive
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/cleanSCRATCH.sbatch /scratch/hpc-0373 "*clumpify*temp*"
Submitted batch job 4270298
```

Check:
```
ls /scratch/hpc-0373
```
Nothing printed, so its cleared.

</details>


<details><summary>8e. Generate metadata on deduplicated FASTQ files (*)</summary>

### 8e. Generate metadata on deduplicated FASTQ files (*)
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "fq_fp1_clmp" "fqc_clmp_report"  "fq.gz"
Submitted batch job 4270357
```

**Results** (fq_fp1_clmp/fqc_clmp_report.html): 
* duplication levels dropped considerably for albatross
* 59/148 passing Per Base Sequence Content
* 65/148 passing Per Sequence GC Content
	* one peak ~41%
	* One individual failing: `CPnd_013` with stochastic peaks around 44% and 65%
* 148 samples had less than 1% of reads made up of overrepresented sequences
* 148/148 passing Adapter Content

```
‣ % duplication - 
    • Alb: 2.6 - 10.7%
    • Contemp: 0.2 - 4.5%
    • Undertermined: 4.9 - 5.3%
‣ GC content - 
    • Alb: 37 - 41%
    • Contemp: 39 - 43%; 50% [CPnd_013]
    • Undertermined: 41%
‣ length - 
    • Alb: 77 - 90 bp
    • Contemp: 78 - 129 bp
    • Undertermined: 85 bp
‣ number of reads -
    • Alb: 16.0 - 63.4 mil
    • Contemp: 0.0 - 3.5 mil
    • Undertermined: 144 mil
```
</details>

---
</details>


<details><summary>9. Second trim (*)</summary>

## 9. Second trim (*)
 
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFASTP_2.sbatch fq_fp1_clmp fq_fp1_clmp_fp2 33
Submitted batch job 4271507
```
### Review the FastQC output (fq_fp1_clmp_fp2/2nd_fastp_report.html):
* Sequence quality begins to dip from 40 to ~30 after read position 90, even after filtering, for all individuals
* GC Content looks about the same for all libraries ~40%, except for CPnd_013, which is at ~50%
* N Content looks much better after filtering

```
‣ % duplication -
    • Alb: 1.0 - 10.3%
    • Contemp: 0.1 - 2.2%
    • Undertermined: 0.7%
‣ GC content -
    • Alb: 37.7 - 41.2%
    • Contemp: 40.0 - 43.4%; 50.2% [CPnd_013]
    • Undertermined: 40.8%
‣ passing filter -
    • Alb: 98.5 - 99.3%
    • Contemp: 98.6 - 99.5%
    • Undertermined: 95.3%
‣ % adapter -
    • Alb: 0.9 - 1.2%
    • Contemp: 0.5 - 1.5%
    • Undertermined: 1.7%
‣ number of reads -
    • Alb: 31.6 - 125.4 mil
    • Contemp: 0.007 - 7 mil
    • Undertermined: 274.6 mil
```

---
</details>

<details><summary>10. Decontaminate files (*)</summary>

## 10. Decontaminate files (*)

<details><summary>10a. Run fastq_screen</summary>
	
### 10a. Run fastq_screen

```
[hpc-0373@wahab-01 2nd_sequencing_run]$ bash
[hpc-0373@wahab-01 2nd_sequencing_run]$ fqScrnPATH=/home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runFQSCRN_6.bash
[hpc-0373@wahab-01 2nd_sequencing_run]$ indir=fq_fp1_clmp_fp2
[hpc-0373@wahab-01 2nd_sequencing_run]$ outdir=/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn
[hpc-0373@wahab-01 2nd_sequencing_run]$ nodes=20
[hpc-0373@wahab-01 2nd_sequencing_run]$ bash $fqScrnPATH $indir $outdir $nodes
```
JobID: 4273642

</details>

<details><summary>10b. Check for Errors</summary>
	
### 10b. Check for Errors

```
[hpc-0373@wahab-01 2nd_sequencing_run]$ bash
[hpc-0373@wahab-01 2nd_sequencing_run]$ outdir=/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn
[hpc-0373@wahab-01 2nd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/validateFQ.sbatch $outdir "*filter.fastq.gz"
Submitted batch job 4283410
```
When complete check the $outdir/fqValidateReport.txt file
```
less -S $outdir/fqValidationReport.txt file
```

**Confirm files were succesfully completed:**

Check that all 5 files were created for each fqgz file:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ outdir=/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn
[hpc-0373@wahab-01 2nd_sequencing_run]$ ls $outdir/*r1.tagged.fastq.gz | wc -l
					ls $outdir/*r2.tagged.fastq.gz | wc -l
					ls $outdir/*r1.tagged_filter.fastq.gz | wc -l
					ls $outdir/*r2.tagged_filter.fastq.gz | wc -l 
					ls $outdir/*r1_screen.txt | wc -l
					ls $outdir/*r2_screen.txt | wc -l
					ls $outdir/*r1_screen.png | wc -l
					ls $outdir/*r2_screen.png | wc -l
					ls $outdir/*r1_screen.html | wc -l
					ls $outdir/*r2_screen.html | wc -l
74
74
74
74
74
74
74
74
74
74
```
For each, you should have the same number as the number of input files (number of fq.gz files):
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ indir=fq_fp1_clmp_fp2
[hpc-0373@wahab-01 2nd_sequencing_run]$ ls $indir/*r1.fq.gz | wc -l
                                        ls $indir/*r2.fq.gz | wc -l
74
74
```
Check the `*out` files: (no results)
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ grep 'error' slurm-fqscrn.*out
                                        grep 'No reads in' slurm-fqscrn.*out
                                        grep 'FATAL' slurm-fqscrn.*out
```

Check for any unzipped files with the word temp, which means that the job didn't finish and needs to be rerun: 
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ ls $outdir/*temp*
ls: cannot access '/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn/*temp*': No such file or directory
```

No errors!

---
</details>

<details><summary>10d. Move output files</summary>

### 10d. Move output files

```
[hpc-0373@wahab-01 2nd_sequencing_run]$ mkdir fq_fp1_clmp_fp2_fqscrn
[hpc-0373@wahab-01 2nd_sequencing_run]$ mv /scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn/* /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_fp1_clmp_fp2_fqscrn
```
Check to see if `/scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn/` was cleared:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ ls /scratch/hpc-0373/fq_fp1_clmp_fp2_fqscrn
#nothing printed
```
---
</details>

<details><summary>10e. Run MultiQC (*)</summary>

### 10e. Run MultiQC (*)

```
[hpc-0373@wahab-01 2nd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastq_screen_report
Submitted batch job 4288359
```
#### Review the MultiQC output (fq_fp1_clmp_fp2_fqscrn/fastq_screen_report.html): 
* Considerable bacterial contamination for `Sin-CPnd_013` (15.7%), which has been the outlier individual on GC Content graphs

```
‣ multiple genomes -
    • Alb: 2.6 - 5.0%
    • Contemp: 1.7 - 7.1%
    • Undertermined: 3.4%
‣ no hits -
    • Alb: 91.9% - 95.9%
    • Contemp: 76.4 - 97.5%
    • Undertermined: 94.4% 
```
</details>

---

</details>


<details><summary>11. Repair FASTQ Files Messed Up by FASTQ_SCREEN (*)</summary>

## 11. Repair FASTQ Files Messed Up by FASTQ_SCREEN (*)

Next we need to re-pair our reads. `runREPAIR.sbatch` matches up forward (r1) and reverse (r2) reads so that the `*1.fq.gz` and `*2.fq.gz` files have reads in the same order

I have had trouble running jobs on wahab, so I am using turning which requires a lower cpu count. I need to make a copy of the script and edit the file:
```
[hpc-0373@turing1 2nd_sequencing_run]$ cp /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch low_cpu_runREPAIR.sbatch

[hpc-0373@turing1 2nd_sequencing_run]$ cat -n low_cpu_runREPAIR.sbatch 
     7	#SBATCH --cpus-per-task=32
```
#### Execute `runREPAIR.sbatch`
```
[hpc-0373@turing1 2nd_sequencing_run]$ sbatch low_cpu_runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_rprd 5
Submitted batch job 10707530 
```
#### Confirm that the paired end fq.gz files are complete and formatted correctly:

Start by running the script:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ bash
[hpc-0373@wahab-01 2nd_sequencing_run]$ SCRIPT=/home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/validateFQPE.sbatch 
                                        DIR=fq_fp1_clmp_fp2_fqscrn_rprd
                                        fqPATTERN="*fq.gz"
[hpc-0373@wahab-01 2nd_sequencing_run]$ sbatch $SCRIPT $DIR $fqPATTERN
Submitted batch job 4326841
```
Check the SLURM `.out` file and `fqValidationReport.txt` to determine if all of the fqgz files are valid:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ cat valiate_FQ_-4326841.out
PAIRED END FASTQ VALIDATION REPORT

Directory: fq_fp1_clmp_fp2_fqscrn_rprd
File Pattern: *fq.gz
File extensions found: .R1.fq.gz .R2.fq.gz

Number of paired end fq files evaluated: 74
Number of paired end fq files validated: 74

Errors Reported:
```
#### Run `Multi_FASTQC`
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "./fq_fp1_clmp_fp2_fqscrn_rprd" "fqc_rprd_report" "fq.gz"
Submitted batch job 4342412
```

#### Review MultiQC output (fq_fp1_clmp_fp2_fqscrn_rprd/fqc_rprd_report.html):
* Per Base Sequence Content: 59/148 have warnings
* Per Sequence GC Content: 71/148 with warnings; 3/148 failing: [Sin-APnd_023 R2, Sin-CPnd_013 R1&R2]
* All samples had less than 1% of reads made up of overrepresented sequences
* No samples found with any adapter contamination > 0.1%

```
‣ % duplication -
    • Alb: 2.7 - 12.0%
    • Contemp: 0.1 - 4.4%
    • Undertermined: 
‣ GC content -
    • Alb: 37 - 40%
    • Contemp: 39 - 45%
    • Undertermined: 
‣ length -
    • Alb: 76 - 88 bp
    • Contemp: 76 - 127 bp
    • Undertermined: 
‣ number of reads -
    • Alb: 14.7 - 58.7 mil
    • Contemp: 0.0 - 3.4 mil
    • Undertermined: 128.3 mil
```

---
</details>

<details><summary>12. Clean Up</summary>

## 12. Clean Up

Move any .out files into the logs dir
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ mkdir logs
[hpc-0373@wahab-01 2nd_sequencing_run]$ mv *out logs/
```

---
</details>

<details><summary>13. Map Re-Paired fq.gz to Reference Genome</summary>
<p>

## 13. Map Re-Paired `fq.gz` to Reference Genome

The following steps 13-15 are from the [pire_lcwgs_data_processing repo](https://github.com/philippinespire/pire_lcwgs_data_processing).

### Get your reference genome

Make a new directory `refGenome` and `cd` into it
```
[hpc-0356@wahab-01 2nd_sequencing_run]$ mkdir refGenome
[hpc-0356@wahab-01 2nd_sequencing_run]$ cd refGenome/
```
This species is not on ncbi, but we do have a reference genome in house. Check the [pire_ssl_data_processing](https://github.com/philippinespire/pire_ssl_data_processing) repo to assess which reference genome is the best for mapping. 

From [pire_ssl_data_processing/stethojulis_interrupta](https://github.com/philippinespire/pire_ssl_data_processing/blob/main/stethojulis_interrupta/README.md):

#### Summary of QUAST and BUSCO Results

Species    |Assembly    |DataType    |SCAFIG    |covcutoff    |genome scope v.    |No. of contigs    |Largest contig    |Total length    |% Genome size completeness    |N50    |L50    |Ns per 100 kbp    |BUSCO single copy
------  |------  |------ |------ |------ |------  |------ |------ |------ |------ |------  |------ |------ |------
Sin  |A  |decontam       |contgs       |off       |2       |  69126  |  150657  |  583970986  |  87% |  10319  |  15699  |  0  | 62%
Sin  |A  |decontam       |scaffolds       |off       |2    |  66358  |  156265  |  594601111  |  88% |  11303  |  14290  |  86  |  64%
Sin  |B  |decontam       |contgs       |off       |2       |  69634 |  150819  |  579984097  |  86% |  10094  |  15982  |  0  | 62%
Sin  |B  |decontam       |scaffolds       |off       |2    |  66872  |  176262  |  590947710  |  88%  |  11039  |  14518  |  89  |  65%
Sin  |C  |decontam       |contgs       |off       |2       |  67590  |  130976  |  344743603  |  51%  |  5055  |  22374  |  0  |  31%
Sin  |C  |decontam       |scaffolds       |off       |2    |  69302  |  158888  |  401718557  |  60%  |  5936  |  20361  | 613 |  38%
Sin  |allLibs  |decontam       |contigs       |off       |2    |  63103  |  135104  |  307932117  |  46% |  4743  |  21357  |  0  |  25%
Sin  |allLibs  |decontam       |scaffolds       |off       |2   |  66165  |  207211  |  372871799  |  55%  |  5629  |  19212  |  762  |  32%
Sin | A | contam | contigs | off | 2 | 69146 | 150657 | 583952407 | 87% | 10298 | 15714 | 0 | 62.1%
Sin | A | contam | scaffolds | off | 2 | 66368 | 156256 | 594609150 | 88% | 11279 | 14293 | 0 | 64.3%

It was determined that the best assembly is A decontam scaffolds. We will use this as our reference genome, + it was also used for probe design.



Copy it into `refGenome`:
```
rsync -a /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate/scaffolds.fasta /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/refGenome &
```

Rename the reference genome. 
```
mv scaffolds.fasta SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate_scaffolds.fasta
```
### Prep for mapping

Start by cloning the dDocentHPC repo to gain access to the scripts we need to run:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ git clone https://github.com/cbirdlab/dDocentHPC
```
Create a `mkBAM_ddocent` directory and copy all `fq.gz` files from `fq_fp1_clmp_fp2_fqscrn_rprd` into this new directory:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ mkdir mkBAM_ddocent
[hpc-0373@wahab-01 2nd_sequencing_run]$ rsync fq_fp1_clmp_fp2_fqscrn_rprd/*fq.gz mkBAM_ddocent
```
Now copy the reference genome to `mkBAM_ddocent` as well as the scripts we need to run:
```
[hpc-0373@wahab-01 2nd_sequencing_run]$ cp refGenome/SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate_scaffolds.fasta mkBAM_ddocent/reference.denovoSSL.Sin.fasta

[hpc-0373@wahab-01 mkBAM_ddocent]$ cp ../dDocentHPC/configs/config.6.lcwgs .
[hpc-0373@wahab-01 mkBAM_ddocent]$ cp ../dDocentHPC/dDocentHPC.sbatch .
```
Before moving forward, I needed to edit the `config.6.lcwgs` file to suit this species:

```
[hpc-0373@wahab-01 mkBAM_ddocent]$ nano config.6.lcwgs

# within file:
# change Cutoff1 and Cutoff2 to "denovoSSL" and "Och"

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
[hpc-0373@wahab-01 mkBAM_ddocent]$ nano dDocentHPC.sbatch

# within file:
# change where the "#" is

enable_lmod
# module load container_env ddocent/2.7.8
module load container_env ddocent/2.9.4
```
Now, I am able to map reads.

### Execute `dDocentHPC.sbatch` which aligns reads to the reference genome:
```
[hpc-0373@wahab-01 mkBAM_ddocent]$ sbatch dDocentHPC.sbatch mkBAM config.6.lcwgs
Submitted batch job 4343523
```
---

</details>

<details><summary>14. Filter BAM Files</summary>

## 14. Filter BAM Files

Filtering BAM files ensures data quality, reduces noise, improves analysis accuracy, and prepares data for downstream genomic analyses.
```
[hpc-0373@wahab-01 mkBAM_ddocent]$ sbatch dDocentHPC.sbatch fltrBAM config.6.lcwgs
Submitted batch job 4343878
```
---
</details>

<details><summary>15. Generate Number of Mapped Reads</summary>

## 15. Generate Number of Mapped Reads
```
[hpc-0373@wahab-01 2nd_sequencing_run]$  sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/mappedReadStats.sbatch mkBAM_ddocent mkBAM_ddocent/coverageMappedReads
Submitted batch job 4346548
```

#### Review Output (coverageMappedReads/out__ReadStats.tsv):
* Number of Reads very low for contemporary; all but 2 have under 1 million reads
* Mean depth all above 1
* Poor percent positions with coverage for contemporary

```
‣ numreads:
    • Alb: 20,079,431 - 26,290,652
    • Contemp: 493 - 5,696,878
    • Undertermined: 22,264,915

‣ meanreadlength:
    • Alb: 72.2 - 85.5
    • Contemp: 80.4 - 126.4
    • Undertermined: 79.4

‣ meandepth_wcvg:
    • Alb: 2.1 - 5.2
    • Contemp: 1.0 - 1.4
    • Undertermined: 6.6

‣ numpos:
    • 798,880,421

‣ numpos_wcvg:
    • Alb: 208,025,593 - 404,038,898
    • Contemp: 23,952 - 269,972,622
    • Undertermined: 136,356,621 

‣ meandepth:
    • Alb: 1.0 - 1.4 
    • Contemp: 0.00003 - 0.5
    • Undertermined: 1.1

‣ pctpos_wcvg:
    • Alb: 26.0 - 50.6%
    • Contemp: 0.003 - 33.8%
    • Undertermined: 17.1%
```
---

</details>

<details><summary>16. Extract mitochondrial genomes from read data</summary>

## 16. Extract mitochondrial genomes from read data

If there are potential cryptic species in the data, we should try to extract mitochondrial genes from the read data to get an idea of species IDs. You use MitoZ to do so.

Copy the runMitoZ bash and sbatch scripts to your sequencing project directory
```
cp /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runMitoZ* /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/
```
* The `runMitoZ_array.bash` and `runMitoZ_array.sbatch` scripts need to be altered before running. Using nano and ctrl+\ find every instance of `_clmp.fp2_r1.fq.gz` and replace it with `.clmp.fp2_r1.fq.gz`.

Now, execute the runMitoZ script:
```
[hpc-0373@turing1 2nd_sequencing_run]$ bash runMitoZ_array.bash /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_fp1_clmp_fp2 32
Submitted batch job 10707751
```

Move MitoZ\*.out files to `fq_fp1_clmp_fp2`.
```
mv MitoZ*.out fq_fp1_clmp_fp2/
```

Process MitoZ
```
cd fq_fp1_clmp_fp2

cp /archive/carpenterlab/pire/pire_lcwgs_data_processing/scripts/MitoZ_wahab/process_MitoZ_outputs_lcwgs.sh ./

sh process_MitoZ_outputs_lcwgs.sh
```

Rename duplicate sequence names in the fasta file. 
```
cp /archive/carpenterlab/pire/pire_sphyraena_obtusata_lcwgs/3rd_sequencing_run/fq_fp1_clmp_fp2/rename_duplicate_fasta_headers.sh ./

sh rename_duplicate_fasta_headers.sh MitoZ_output.fasta Sin_2nd_MitoZ_output_cleaned.fasta
```

Rename files to include the species code and the sequencing run.
```
mv MitoZ_success.txt Sin_2nd_MitoZ_success.txt
mv MitoZ_failure_lowdepth.txt Sin_2nd_MitoZ_failure_lowdepth.txt
mv MitoZ_output.fasta Sin_2nd_MitoZ_output.fasta
```

Now, we can see which individuals MitoZ worked for:

<details><summary>Individuals that succeeded/failed:</summary>
<p>
		
**Individuals that succeeded:** (Albatross: 4/25   Contemporary: 2/48)
```
[hpc-0373@wahab-01 fq_fp1_clmp_fp2]$ cat Sin_2nd_MitoZ_success.txt
Sin-APnd_007-Ex1-4D-lcwgs-1-2
Sin-APnd_014-Ex1-5C-lcwgs-1-2
Sin-APnd_018-Ex1-5G-lcwgs-1-2
Sin-APnd_025-Ex1-6F-lcwgs-1-2
Sin-CPnd_045-Ex1-11H-lcwgs-1-2
Sin-CPnd_090-Ex1-12F-lcwgs-1-2
```
**Individuals that failed:** (Albatross: 11/25   Contemporary: 42/48)
```
[hpc-0373@wahab-01 fq_fp1_clmp_fp2]$ cat Sin_2nd_MitoZ_failure_lowdepth.txt
Sin-APnd_002-Ex1-3G-lcwgs-1-2
Sin-APnd_004-Ex1-4A-lcwgs-1-2
Sin-APnd_005-Ex1-4B-lcwgs-1-2
Sin-APnd_009-Ex1-4F-lcwgs-1-2
Sin-APnd_013-Ex1-5B-lcwgs-1-2
Sin-APnd_016-Ex1-5E-lcwgs-1-2
Sin-APnd_017-Ex1-5F-lcwgs-1-2
Sin-APnd_020-Ex1-6A-lcwgs-1-2
Sin-APnd_022-Ex1-6C-lcwgs-1-2
Sin-APnd_023-Ex1-6D-lcwgs-1-2
Sin-APnd_024-Ex1-6E-lcwgs-1-2
Sin-CPnd_013-Ex1-4E-lcwgs-1-2
Sin-CPnd_015-Ex1-4A-lcwgs-1-2
Sin-CPnd_018-Ex1-11A-lcwgs-1-2
Sin-CPnd_019-Ex1-1H-lcwgs-1-2
Sin-CPnd_020-Ex1-12E-lcwgs-1-2
Sin-CPnd_021-Ex1-3D-lcwgs-1-2
Sin-CPnd_022-Ex1-1D-lcwgs-1-2
Sin-CPnd_023-Ex1-12B-lcwgs-1-2
Sin-CPnd_024-Ex1-12C-lcwgs-1-2
Sin-CPnd_025-Ex1-3B-lcwgs-1-2
Sin-CPnd_031-Ex1-3G-lcwgs-1-2
Sin-CPnd_032-Ex1-3E-lcwgs-1-2
Sin-CPnd_033-Ex1-1B-lcwgs-1-2
Sin-CPnd_034-Ex1-3C-lcwgs-1-2
Sin-CPnd_035-Ex1-12D-lcwgs-1-2
Sin-CPnd_038-Ex1-11C-lcwgs-1-2
Sin-CPnd_039-Ex1-10F-lcwgs-1-2
Sin-CPnd_040-Ex1-11E-lcwgs-1-2
Sin-CPnd_042-Ex1-10D-lcwgs-1-2
Sin-CPnd_043-Ex1-1C-lcwgs-1-2
Sin-CPnd_049-Ex1-4C-lcwgs-1-2
Sin-CPnd_050-Ex1-9B-lcwgs-1-2
Sin-CPnd_051-Ex1-12G-lcwgs-1-2
Sin-CPnd_053-Ex1-9G-lcwgs-1-2
Sin-CPnd_058-Ex1-9D-lcwgs-1-2
Sin-CPnd_061-Ex1-9A-lcwgs-1-2
Sin-CPnd_062-Ex1-11D-lcwgs-1-2
Sin-CPnd_063-Ex1-9F-lcwgs-1-2
Sin-CPnd_065-Ex1-11B-lcwgs-1-2
Sin-CPnd_067-Ex1-9C-lcwgs-1-2
Sin-CPnd_074-Ex1-12A-lcwgs-1-2
Sin-CPnd_075-Ex1-11G-lcwgs-1-2
Sin-CPnd_076-Ex1-10E-lcwgs-1-2
Sin-CPnd_079-Ex1-9H-lcwgs-1-2
Sin-CPnd_080-Ex1-2E-lcwgs-1-2
Sin-CPnd_081-Ex1-10G-lcwgs-1-2
Sin-CPnd_085-Ex1-4H-lcwgs-1-2
Sin-CPnd_088-Ex1-2D-lcwgs-1-2
Sin-CPnd_089-Ex1-9E-lcwgs-1-2
Sin-CPnd_092-Ex1-11F-lcwgs-1-2
Sin-CPnd_093-Ex1-10C-lcwgs-1-2
Sin-CPnd_095-Ex1-2B-lcwgs-1-2
```
---
</details>

It seems like maybe MitoZ didn't run properly, because 14 individuals are not accounted for.
I'm going to move all of the MitoZ out files to `2nd_sequencing_run/logs` to avoid confusion, and then rerun MitoZ.
```
[hpc-0373@wahab-01 fq_fp1_clmp_fp2]$ mv MitoZ*.out ../logs/

[hpc-0373@wahab-01 2nd_sequencing_run]$ bash runMitoZ_array.bash /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_fp1_clmp_fp2 32
Submitted batch job 4366975
```
