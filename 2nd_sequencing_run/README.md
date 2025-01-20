<img src="https://inaturalist-open-data.s3.amazonaws.com/photos/236392150/original.jpg" alt="Sin" width="300"/>

# *Stethojulis interrupta* lcWGS

## 2nd Sequencing Run

Analysis of low-coverage whole genome sequencing data for *Stethojulis interrupta* 2nd sequencing run.

---

## fq.gz Pre-processing

This portion follows the instructions on [this repo](https://github.com/philippinespire/pire_fq_gz_processing).


<details><summary>1. Set-up</summary>

### 1. Set-up

Make 2nd sequencing run directory
```
cd 

mkdir 2nd_sequencing_run
```

</details>


<details><summary>2. Get raw data</summary>

### 2. Get raw data

```
rsync -r /archive/carpenterlab/pire/downloads/stethojulis_interrupta/1st_sequencing_run-lcwgs/fq_raw 1st_sequencing_run
```

</details>


<details><summary>3. Proofread the decode file</summary>

### 3. Proofread the decode file

```
cat Sin_lcwgs-testlane_SequenceNameDecode.tsv
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

</details>


<details><summary>4. Perform a renaming dry run</summary>

## 4. Perform a renaming dry run

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sin_lcwgs-testlane_SequenceNameDecode.tsv
```

</details>


<details><summary>5. Rename the files</summary>
	
## 5. Rename the files

```
bash /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/renameFQGZ.bash Sin_lcwgs-testlane_SequenceNameDecode.tsv rename
```

</details>
