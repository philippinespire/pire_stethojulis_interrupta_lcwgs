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
Submitted batch job 4256517
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
    • Undetermined: 
```
---
</details>






<details><summary>#. Get reference genome</summary>
	
### #. Get reference genome

Make a new directory `refGenome`.
```
mkdir refGenome
```

Identify best reference genome from the [pire_ssl_data_processing/stethojulis_interrupta](https://github.com/philippinespire/pire_ssl_data_processing/tree/main/stethojulis_interrupta) page. Probe design used `SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate/scaffolds.fasta`, so use this for mapping. 

Copy the reference genome to the `refGenome` directory.
```
rsync -a /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate/scaffolds.fasta /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/refGenome &
```

Rename the reference genome. 
```
mv scaffolds.fasta SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate_scaffolds.fasta
```

</details>
