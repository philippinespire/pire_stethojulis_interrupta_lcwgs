<img src="https://inaturalist-open-data.s3.amazonaws.com/photos/236392150/original.jpg" alt="Sin" width="300"/>

# GenErode: *Stethojulis interrupta* lcWGS 1st sequencing run (test lane) from Pandanon Island

Following the [GenErode pipeline](https://github.com/philippinespire/pire_lcwgs_data_processing/tree/main/scripts/GenErode_wahab) for Sin 1st sequencing run from Pandanon Island. 
```
/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k
```

<details><summary>1. Set-Up</summary>

### 1. Set-up

Create the GenErode directory and subdirectories. 
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run

mkdir GenErode_Sin_20k

cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k

mkdir config historical modern reference gerp_outgroups
```

Copy the contents of the template directory to your GenErode directory.
```
cp -r /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_wahab/GenErode_templatedir/* /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/
```

All sequencing data and reference genomes have to be within their respective subdirectdory in the main analysis directory. Count and copy `\*.fq.gz` files in the fq_raw directories. Do not copy `Undetermined\*.fq.gz` files. 

#### Historical
```
# 1st run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/Sin-APnd*.fq.gz | wc -l
50

rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/Sin-APnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/historical &

ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/historical | wc -l
50
```

#### Modern
```
# SSL
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq/Sin-CPnd*.fq.gz | wc -l
6

rsync -a /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq/Sin-CPnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/modern &

# 1st run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/Sin-CPnd*.fq.gz | wc -l
128

rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/Sin-CPnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/modern &

#confirm all files were transferred
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/modern | wc -l
134
```

#### Reference

Use the 20k version (scaffolds > 20kbp) of the best reference genome that was used for probe development and mkBAM. However, probe development and mkBAM used different reference genomes. Use the reference genome that was used for mapping (Brendan Reid). 

1st sequencing run mapping used allLibs reference genome. 
```
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/refGenome/
```

SSL probe design used Sin-CPnd-A reference genome. 
```
cp SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate/scaffolds.fasta probe_design #copy best assembly
```

Copy the allLibs reference genome to the reference directory. 
```
cp /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/reference
```

Create the 20k reference genome: `reference.denovoSSL.Sin20k.fasta`
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/reference

perl /home/e1garcia/shotgun_PIRE/REUs/2022_REU/PSMC/scripts/removesmalls.pl 20000 scaffolds.fasta > reference.denovoSSL.Sin20k.fasta
```

#### GERP Outgroups

Copy gerp scripts to the species' gerp_outgroups directory.
```
cp /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_Wahab/gerp_outgroups/*.sh /archive/carpenterlab/pire/pire_genus_species_lcwgs/GenErode_Spp_20k/gerp_outgroups/
```

Identify the ~30 closest relatives of your species with chromosome-level genomes. *Stethojulis interrupta* is in the order Labriformes. Labriformes is in Eupercaria, next to Uranoscopiformes, Ephippiformes, Chaetodontiformes, Acanthuriformes, Lutjaniformes, etc. Gerreiformes seems to be an outgroup within Eupercaria, but Gerreiformes had outgroups relevant to Labriformes.

Copy 34 genomes from *Gerres oyena* GenErode gerp_outgroups
```
rsync -a /archive/carpenterlab/pire/pire_gerres_oyena_lcwgs/1st_sequencing_run/GenErode_Goy_20k/gerp_outgroups/*.fa.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups &
```

Add the genomes of *Cheilinus undulatus*, *Labrus bergylta*, and *Notolabrus celidotus* for a total of 37. 
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups

# Cheilinus undulatus
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/018/320/785/GCF_018320785.1_ASM1832078v1/GCF_018320785.1_ASM1832078v1_genomic.fna.gz

# Labrus bergylta
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/963/930/695/GCF_963930695.1_fLabBer1.1/GCF_963930695.1_fLabBer1.1_genomic.fna.gz

# Notolabrus celidotus
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/762/535/GCF_009762535.1_fNotCel1.pri/GCF_009762535.1_fNotCel1.pri_genomic.fna.gz
```

Rename the genomes to their species' names.
```
mv GCF_018320785.1_ASM1832078v1_genomic.fna.gz Cheilinus_undulatus.fa.gz

mv GCF_963930695.1_fLabBer1.1_genomic.fna.gz Labrus_bergylta.fa.gz

mv GCF_009762535.1_fNotCel1.pri_genomic.fna.gz Notolabrus_celidotus.fa.gz
```

Create the file `speciesnames.txt`.
```
ls | sed 's/\.fa\.gz$//' > speciesnames.txt
```

Add `Stethojulis_interrupta` to the first line of `speciesnames.txt`, which contains a list of the species names of *Stethojulis interrupta* and its 37 closest relatives with chromosome-level genomes from Genbank.

<details><summary>speciesnames.txt</summary>

```
Stethojulis_interrupta
Acanthopagrus_latus
Antennarius_maculatus
Argyrosomus_regius
Cheilinus_undulatus
Collichthys_lucidus
Cottus_gobio
Cyclopterus_lumpus
Etheostoma_cragini
Gasterosteus_aculeatus
Hyperoplus_lanceolatus
Karalla_daura
Labroides_dimidiatus
Labrus_bergylta
Labrus_mixtus
Larimichthys_crocea
Lutjanus_campechanus
Micropterus_salmoides
Nibea_albiflora
Nibea_coibor
Notolabrus_celidotus
Notothenia_rossii
Pao_palembangensis
Perca_flavescens
Pholis_gunnellus
Protonibea_diacanthus
Sander_lucioperca
Scatophagus_argus
Sciaenops_ocellatus
Scortum_barcoo
Sebastes_umbrosus
Siniperca_scherzeri
Sparus_aurata
Symphodus_melops
Takifugu_rubripes
Tautogolabrus_adspersus
Thamnaconus_septentrionalis
Xyrichtys_novacula
```

</p>
</details>

</details>


<details><summary>2. Get Newick tree</summary>

### 2. Get Newick tree

Create a dated phylogenetic tree. Upload `speciesnames.txt` to [TimeTree of Life](https://timetree.org/). Download the .nwk and .jpg files that TimeTree creates. Upload these to the `GenErode_Sin_20k/gerp_outgroups` directory. Rename the file from `speciesnames.nwk` to `gerp_tree.nwk`.
```
mv speciesnames.nwk gerp_tree.nwk
```

#### TimeTree Results

<img src="https://github.com/philippinespire/pire_stethojulis_interrupta_lcwgs/blob/main/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/prunetree.jpg" alt="Sin tree" width="700"/>

\**Notolabrus celidotus* not found in NCBI taxonomy and replaced with *Notolabrus gymnogenis*.


!!! Not done yet. Check which genome first. I forgot to replace Stethojulis_interrupta with *reference.denovoSSL.Sin20k.fasta*. Make this GenErode directory deprecated and start over. 

Replace your Genus_species in `gerp_tree.nwk` with the name of the reference genome, which should be `reference.denovoSSL.Spp20k.fasta`: 
```
sed -i 's/Stethojulis_interrupta/reference.denovoSSL.Sin20k.fasta/g' gerp_tree.nwk
```

<details><summary>gerp_tree.nwk</summary>

```
((((Karalla_daura:84.83588000,((Lutjanus_campechanus:82.26366000,(Sparus_aurata:31.84100000,Acanthopagrus_latus:31.84100000)'14':50.42266000)'13':0.49007000,(Scatophagus_argus:81.72976000,((Thamnaconus_septentrionalis:71.26750000,(Pao_palembangensis:45.34872000,Takifugu_rubripes:45.34872000)'25':25.91878000)'37':6.87480000,Antennarius_maculatus:78.14230000)'36':3.58746000)'35':1.02397000)'34':2.08215000)'43':1.10157000,((Sciaenops_ocellatus:44.60328000,(((Nibea_albiflora:23.27883000,Nibea_coibor:23.27883000)'33':17.37576000,(Collichthys_lucidus:15.93820000,Larimichthys_crocea:15.93820000)'51':24.71639000)'50':2.31829000,Argyrosomus_regius:42.97288000)'49':1.63040000)'57':6.71643000,Protonibea_diacanthus:51.31971000)'60':34.61774000)'56':10.77313000,((((((Labroides_dimidiatus:33.05912000,Stethojulis_interrupta:33.05912000)'48':0.60303000,Xyrichtys_novacula:33.66215000)'63':9.82407000,Notolabrus_celidotus:43.48622000)'47':1.87620000,(Cheilinus_undulatus:42.54118000,((Symphodus_melops:18.29928000,Tautogolabrus_adspersus:18.29928000)'68':5.74727000,(Labrus_mixtus:13.54130000,Labrus_bergylta:13.54130000)'73':10.50525000)'72':18.49463000)'84':2.82124000)'87':43.87276000,Hyperoplus_lanceolatus:89.23518000)'83':3.58438000,(Scortum_barcoo:75.71781000,(Micropterus_salmoides:59.12548000,Siniperca_scherzeri:59.12548000)'82':16.59233000)'80':17.10175000)'79':3.89102000)'94':6.86373000,((Etheostoma_cragini:32.50262000,(Sander_lucioperca:30.85028000,Perca_flavescens:30.85028000)'92':1.65234000)'78':44.47236000,((Sebastes_umbrosus:75.22844000,(((Cottus_gobio:35.27928000,Cyclopterus_lumpus:35.27928000)'98':10.64897000,Gasterosteus_aculeatus:45.92825000)'97':0.24965000,Pholis_gunnellus:46.17790000)'77':29.05054000)'71':1.69136000,Notothenia_rossii:76.91980000)'67':0.05518000)'66':26.59933000);
```

</p>
</details>

</details>


<details><summary>3. Edit Config Files</summary>

### 3. Edit Config Files

Copy config scripts to your species' config directory.
```
cp /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_ahab/config/config* /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/config/
```
GenErode uses `config.yaml` to run. It also requires you to make two config files: `modern_samples.txt` and `historical_samples.txt`. These config files are specific to your data. In these config files, each unique sample gets its own line with its unique forward and reverse read files. The R1_fastq_file and R2_fastq_file in the header of these config files correspond to the \*.1.fq.gz and \*.2.fq.gz files that are preceded by a unique sample name.

#### Creating config files

The script `config_generode_old_new_lane.sh` will be used to create the file `old_new_lane_GenErode_Spp_config.log`. This will be used as an input for the scripts `config_modern_samples.sh` and `config_historical_samples.sh`, which will create the files `modern_samples.txt` and `historical_samples.txt`, respectively. Each script should be run in the config directory. Each scripts need to be edited for the user-defined variables: `species` and `Spp`. These scripts require the input file `old_new_lane_GenErode__config.log`, which is created from the bash script `generode_config_old_new_lane.sh`.

1. Identify all `old_new_config.log` files

The `config_generode_old_new_lane.sh` script requires the `old_new_config.log` files from each fq_raw directory that will be used in GenErode.
```
cd /archive/carpenterlab/pire/pire_genus_species_lcwgs/GenErode_Spp_20k/config

# 1st run
ls ../fq_raw/old_new_filenames.log

# SSL. The SSL file does not exist and I can't find the old file names. 
ls  /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq/old_new_config.log
```

However sometimes they don't have the file `old_new_config.log`. I can't find the original file names. 
```
# SSL files
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq/*.fq.gz
Sin-CPnd_001_Ex1-1G_L4_1.fq.gz
Sin-CPnd_001_Ex1-1G_L4_2.fq.gz
Sin-CPnd_001_Ex1-2F_L4_1.fq.gz
Sin-CPnd_001_Ex1-2F_L4_2.fq.gz
Sin-CPnd_001_Ex1-3E_L4_1.fq.gz
Sin-CPnd_001_Ex1-3E_L4_2.fq.gz
```

SinCPnd001_Ex11G_L4 HK2C2DSX3:4 illumina modern/Sin-CPnd_001_Ex1-1G_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-1G_L4_2.fq.gz
SinCPnd001_Ex12F_L4 HK2C2DSX3:4 illumina modern/Sin-CPnd_001_Ex1-2F_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-2F_L4_2.fq.gz
SinCPnd001_Ex13E_L4 HK2C2DSX3:4 illumina modern/Sin-CPnd_001_Ex1-3E_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-3E_L4_2.fq.gz

2. Run `config_generode_old_new_lane.sh`

Once all of the `old_new_config.log` files have been identified, edit user-defined variables in the script `config_generode_old_new_lane.sh`. 
```
# User-defined variables for species and species code (Spp).
# For species use lowercase and an underscore so the directory path can be identified (e.g. lethrinus_variegatus)
species="stethojulis_interrupta"
# For Spp, this is the three letter species code. Capitalize the first letter.
Spp="Sin"

# Define the lcwgs & ssl directory path using the species variable. Edit if necessary. Check SSL. 
lcwgs_path=$"/archive/carpenterlab/pire/pire_${species}_lcwgs"
ssl_path=$"/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/${species}"

# Define the input files. Edit if necessary. Check SSL.
file1="${lcwgs_path}/1st_sequencing_run/fq_raw/old_new_filenames.log"
file2="${lcwgs_path}/2nd_sequencing_run/fq_raw/old_new_filenames.log"
file3="${lcwgs_path}/3rd_sequencing_run/fq_raw/old_new_filenames.log"
file4="${ssl_path}/fq_raw_shotgun/old_new_filenames.log"

# Define the output file
output_file="${lcwgs_path}/1st_sequencing_run/GenErode_${Spp}_20k/config/old_new_lane_GenErode_${Spp}_config.log"
```

Run `config_generode_old_new_lane.sh` to create `old_new_lane_GenErode_Spp_config.log`. The file `old_new_lane_GenErode_Spp_config.log` does not have a header, but the columns are `origFileName newFileName lane`.
```
cd /archive/carpenterlab/pire/pire_genus_species_lcwgs/GenErode_Ssp_20k/config

bash generode_config_old_new_lane.sh
```

Output.
```
Including file: /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/old_new_filenames.log
File not found: /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/old_new_filenames.log
File not found: /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/3rd_sequencing_run/fq_raw/old_new_filenames.log
File not found: /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/fq_raw_shotgun/old_new_filenames.log
Concatenation completed. Output saved to /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/config/old_new_lane_GenErode_Sin_config.log
```

Count the number of lines in the file. There should be 179 lines (134 modern -6 modern SSL + 50 historical + 1 header). 
```
wc -l old_new_lane_GenErode_Sin_config.log
179
```

#### Historical
Run `config_historical_samples.sh`.
```
bash config_historical_samples.sh
```

Output.
```
Historical samples processing completed. Output saved to historical_samples.txt
All 25 1.fq.gz and 25 2.fq.gz files were incorporated into historical_samples.txt
```

```
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/Sin-APnd*.fq.gz
Sin-APnd_001-Ex1-6G-lcwgs-1-1.1.fq.gz
Sin-APnd_001-Ex1-6G-lcwgs-1-1.2.fq.gz
Sin-APnd_002-Ex1-3G-lcwgs-1-1.1.fq.gz
Sin-APnd_002-Ex1-3G-lcwgs-1-1.2.fq.gz
Sin-APnd_003-Ex1-3H-lcwgs-1-1.1.fq.gz
Sin-APnd_003-Ex1-3H-lcwgs-1-1.2.fq.gz
Sin-APnd_004-Ex1-4A-lcwgs-1-1.1.fq.gz
Sin-APnd_004-Ex1-4A-lcwgs-1-1.2.fq.gz
Sin-APnd_005-Ex1-4B-lcwgs-1-1.1.fq.gz
Sin-APnd_005-Ex1-4B-lcwgs-1-1.2.fq.gz
Sin-APnd_006-Ex1-4C-lcwgs-1-1.1.fq.gz
Sin-APnd_006-Ex1-4C-lcwgs-1-1.2.fq.gz
Sin-APnd_007-Ex1-4D-lcwgs-1-1.1.fq.gz
Sin-APnd_007-Ex1-4D-lcwgs-1-1.2.fq.gz
Sin-APnd_008-Ex1-4E-lcwgs-1-1.1.fq.gz
Sin-APnd_008-Ex1-4E-lcwgs-1-1.2.fq.gz
Sin-APnd_009-Ex1-4F-lcwgs-1-1.1.fq.gz
Sin-APnd_009-Ex1-4F-lcwgs-1-1.2.fq.gz
Sin-APnd_010-Ex1-4G-lcwgs-1-1.1.fq.gz
Sin-APnd_010-Ex1-4G-lcwgs-1-1.2.fq.gz
Sin-APnd_011-Ex1-4H-lcwgs-1-1.1.fq.gz
Sin-APnd_011-Ex1-4H-lcwgs-1-1.2.fq.gz
Sin-APnd_012-Ex1-5A-lcwgs-1-1.1.fq.gz
Sin-APnd_012-Ex1-5A-lcwgs-1-1.2.fq.gz
Sin-APnd_013-Ex1-5B-lcwgs-1-1.1.fq.gz
Sin-APnd_013-Ex1-5B-lcwgs-1-1.2.fq.gz
Sin-APnd_014-Ex1-5C-lcwgs-1-1.1.fq.gz
Sin-APnd_014-Ex1-5C-lcwgs-1-1.2.fq.gz
Sin-APnd_015-Ex1-5D-lcwgs-1-1.1.fq.gz
Sin-APnd_015-Ex1-5D-lcwgs-1-1.2.fq.gz
Sin-APnd_016-Ex1-5E-lcwgs-1-1.1.fq.gz
Sin-APnd_016-Ex1-5E-lcwgs-1-1.2.fq.gz
Sin-APnd_017-Ex1-5F-lcwgs-1-1.1.fq.gz
Sin-APnd_017-Ex1-5F-lcwgs-1-1.2.fq.gz
Sin-APnd_018-Ex1-5G-lcwgs-1-1.1.fq.gz
Sin-APnd_018-Ex1-5G-lcwgs-1-1.2.fq.gz
Sin-APnd_019-Ex1-5H-lcwgs-1-1.1.fq.gz
Sin-APnd_019-Ex1-5H-lcwgs-1-1.2.fq.gz
Sin-APnd_020-Ex1-6A-lcwgs-1-1.1.fq.gz
Sin-APnd_020-Ex1-6A-lcwgs-1-1.2.fq.gz
Sin-APnd_021-Ex1-6B-lcwgs-1-1.1.fq.gz
Sin-APnd_021-Ex1-6B-lcwgs-1-1.2.fq.gz
Sin-APnd_022-Ex1-6C-lcwgs-1-1.1.fq.gz
Sin-APnd_022-Ex1-6C-lcwgs-1-1.2.fq.gz
Sin-APnd_023-Ex1-6D-lcwgs-1-1.1.fq.gz
Sin-APnd_023-Ex1-6D-lcwgs-1-1.2.fq.gz
Sin-APnd_024-Ex1-6E-lcwgs-1-1.1.fq.gz
Sin-APnd_024-Ex1-6E-lcwgs-1-1.2.fq.gz
Sin-APnd_025-Ex1-6F-lcwgs-1-1.1.fq.gz
Sin-APnd_025-Ex1-6F-lcwgs-1-1.2.fq.gz
```

#### Modern
Run `config_modern_samples.sh`.
```
bash config_modern_samples.sh
```

Output.
```
Modern samples processing completed. Output saved to modern_samples.txt
All 67 1.fq.gz and 67 2.fq.gz files were incorporated into modern_samples.txt
```
67 files means that it incorporated the SSL files. The error_modern.out file said it was missing the Lane information from these 3 samples (6 files), which makes sense because they weren't incorporated into the old_new_lane_GenErode_Sin_config.log file. Lane will have to be manually added. Lane 4 for each of these samples. 

```
cat error_modern.out
Warning: Lane information missing for SinCPnd001 illumina modern/Sin-CPnd_001_Ex1-1G_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-1G_L4_2.fq.gz
Warning: Lane information missing for SinCPnd001 illumina modern/Sin-CPnd_001_Ex1-2F_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-2F_L4_2.fq.gz
Warning: Lane information missing for SinCPnd001 illumina modern/Sin-CPnd_001_Ex1-3E_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-3E_L4_2.fq.gz
```

head -n 4 modern_samples.txt
```
samplename_index_lane readgroup_id readgroup_platform path_to_R1_fastq_file path_to_R2_fastq_file
SinCPnd001_Ex11G_L4 HK2C2DSX3:4 illumina modern/Sin-CPnd_001_Ex1-1G_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-1G_L4_2.fq.gz
SinCPnd001_Ex12F_L4 HK2C2DSX3:4 illumina modern/Sin-CPnd_001_Ex1-2F_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-2F_L4_2.fq.gz
SinCPnd001_Ex13E_L4 HK2C2DSX3:4 illumina modern/Sin-CPnd_001_Ex1-3E_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-3E_L4_2.fq.gz
```

modern_samples.txt is now ready. 

#### Edit the config files

Template config files are located in `home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_Wahab/config`.

Currently these are the files used to conduct the white rhino reference test run.

Edit the config.yaml files to reflect the analyses you want to conduct in GenErode.

Edit the `*historical_samples.txt` and `*modern_samples.txt` files to reflect your sample information.

Edit the config.yaml

<details><summary>config.yaml</summary>

```
line 23: ref_path: "/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta"
line 31: historical_samples: "config/historical_samples.txt"
line 32: modern_samples: "config/modern_samples.txt"
Line 70: fastq_processing: True
line 89: map_historical_to_mitogenomes: False
line 165: historical_bam_mapDamage: True
line 173: historical_rescaled_samplenames: ["SinAPnd001","SinAPnd002","SinAPnd003","SinAPnd004","SinAPnd005","SinAPnd006","SinAPnd007","SinAPnd008","SinAPnd009","SinAPnd010","SinAPnd011","SinAPnd012","SinAPnd013","SinAPnd014","SinAPnd015","SinAPnd016","SinAPnd017","SinAPnd018","SinAPnd019","SinAPnd020","SinAPnd021","SinAPnd022","SinAPnd023","SinAPnd024","SinAPnd025"]
line 446: snpEff: False
line 455: gtf_path: ""
line 486: gerp: True
line 492: gerp_ref_path: "/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups"
line 501: tree: "/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/gerp_tree.nwk"
```

</p>
</details>

</details>

<details><summary>4. Run GenErode</summary>

### 4. Run GenErode

#### Run the pipeline

Copy `run_GenErode.sbatch` and `run_GenErode_unlock.sbatch` to your analysis folder (GenErode_Spp_20k).
```
cp /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_wahab/*sbatch /archive/carpenterlab/pire/pire_genus_species_lcwgs/GenErode_Spp_20k/ 
```

Move to this folder and run with 
```
sbatch run_GenErode.sbatch
```

If it is locked then unlock it with:
```
sbatch run_GenErode_unlock.sbatch
```

Error. Run again but with line 486: gerp: True set to False bc it was already made.

line 173: historical_rescaled_samplenames: ["SinAPnd002","SinAPnd004","SinAPnd005","SinAPnd006","SinAPnd007","SinAPnd008","SinAPnd009","SinAPnd010","SinAPnd011","SinAPnd013","SinAPnd014","SinAPnd018","SinAPnd019","SinAPnd020","SinAPnd021","SinAPnd023","SinAPnd025"]
Run again on 12/31/24. Still need 1 modern and 17 historical files. 
```
sbatch run_GenErode.sbatch
```

</details>

<details><summary>5. Results</summary>

### 5. Results

Check input and output

#### GERP Scores
```
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/results/gerp/reference.denovoSSL.Sin20k.ancestral.rates.gz | wc -l 
1
```
GenErode successfully created the ancestral rates file. 

#### Modern
```
# modern expected
find /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/modern -maxdepth 1 -type f -name 'Sin-CPnd_*' -printf '%f\n' | cut -c 10-12 | sort | uniq | wc -l
65

# modern output *.merged.rmdup.merged.realn.bam
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/results/modern/mapping/reference.denovoSSL.Sin20k/*.merged.rmdup.merged.realn.bam | wc -l
64

# modern output *.merged.rmdup.merged.realn.bai
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/results/modern/mapping/reference.denovoSSL.Sin20k/*.merged.rmdup.merged.realn.bai | wc -l
65
```
GenErode successfully created all  modern `\*.merged.rmdup.merged.realn.bam` files. 


#### Historical
```
# historical expected
find /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/historical -maxdepth 1 -type f -name 'Sin-APnd_*' -printf '%f\n' | cut -c 10-12 | sort | uniq | wc -l
25

# historical output *.merged.rmdup.merged.realn.bam
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/results/historical/mapping/reference.denovoSSL.Sin20k/*.merged.rmdup.merged.realn.bam | wc -l
25

# historical output *.merged.rmdup.merged.realn.bai
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/results/historical/mapping/reference.denovoSSL.Sin20k/*.merged.rmdup.merged.realn.bai | wc -l
25
```

Successfully ran on 24 files. Remove these from config.yaml. Just run on SinAPnd006 & SinCPnd001

Remove every other sample besides sincpnd001
cp modern_samples.txt modern_samples_sincpnd001.txt



Remove every other sample besides sinapnd006
cp historical_samples.txt historical_samples_sinapnd006.txt

mv historical_samples_sinapnd006.txt

Edit config.yaml to reflect new config files and just sinapnd006. 

GenErode successfully created all 25 historical `\*.merged.rmdup.merged.realn.bam` files. 

GenErode still running after creating all files. slurm-4054554.out hasn't been updated in 4.5 hours. Cancel jobs. 

This caused the last SinCPnd001\*realn.bam file to disapear. Running ATLAS Recal on Historical. Rerun GenErode on just the SinCPnd001 sample. Remove historical samples from config.yaml.

Edit the config.yaml
<details><summary>config.yaml</summary>

```
line 31: historical_samples: "" # leave empty ("") if not run for historical samples.
line 165: historical_bam_mapDamage: False
line 173: historical_rescaled_samplenames: [""]
line 486: gerp: False
```
This was incorrect. It should not have had the apostraphes. So I edited config.yaml while it was running, after ~93 minutes. I don't think it would cause an error or fail because historical_bam_mapDamage was set to false and historical_samples was left empty. 
line 173: historical_rescaled_samplenames: [""] 

# I forgot to change the name of Stethojulis_interrupta to the name of the reference genome file in gerp_tree.nwk, so I don't think it used the reference genome to create the GERP scores. Cancel the current GenErode run. Rename this directory to deprecated. Create a new GenErode directory. Copy files over. Restart. 


</details>

<details><summary>6. Clean up</summary>

### 6. Clean up

Make logs directory. Move `\*.out` files to logs directory.  
```
mkdir logs

mv *.out logs
```

</details>
