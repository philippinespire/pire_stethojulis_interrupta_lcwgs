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

