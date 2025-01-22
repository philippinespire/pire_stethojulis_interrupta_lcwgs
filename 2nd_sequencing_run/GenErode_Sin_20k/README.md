<img src="https://inaturalist-open-data.s3.amazonaws.com/photos/236392150/original.jpg" alt="Sin" width="300"/>

# GenErode: *Stethojulis interrupta* lcWGS 2nd sequencing run from Pandanon Island.

Following the [GenErode pipeline](https://github.com/philippinespire/pire_lcwgs_data_processing/tree/main/scripts/GenErode_wahab) for Sin 2nd sequencing run from Pandanon Island. GenErode was already run on the 1st sequencing run. These results will be merged with the results from the 1st sequencing run in the main species directory.
```
/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k
```

<details><summary>1. Set-Up</summary>

### 1. Set-up

Create the GenErode directory and subdirectories. 
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run

mkdir GenErode_Sin_20k

cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k

mkdir config historical modern reference gerp_outgroups logs
```

Copy the contents of the template directory to your GenErode directory.
```
rsync -a /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_wahab/GenErode_templatedir/* /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/ &
```

Analyzing 2nd sequencing run files and SSL files. 1st sequencing run files will be merged later. Count and copy `\*.fq.gz` files in the `2nd_sequencing_run/fq_raw` directories. Do not copy `Undetermined\*.fq.gz` files. 

#### Historical
```
# 2nd run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/Sin-APnd*.fq.gz | wc -l
50

rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/Sin-APnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/historical &

ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/historical | wc -l
50
```

#### Modern
\* Rerun the SSL sequences, which are all the sample SinCPnd001, because this did not finish during the GenErode run on the 1st sequencing run.
```
# SSL
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq/Sin-CPnd*.fq.gz | wc -l
6

rsync -a /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq/Sin-CPnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/modern &

# 2nd run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/Sin-CPnd*.fq.gz | wc -l
96

rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/Sin-CPnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/modern &

ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/modern | wc -l
102
```

#### Reference

Use the 20k version (scaffolds > 20kbp) of the best reference genome that was used for probe development and mkBAM. However, probe development and mkBAM used different reference genomes. Use the reference genome that was used for mapping, which was allLibs (Brendan Reid). 

Copy the 20k reference genome from the 1st sequencing directory. This was made from the reference genome that was used for mapping in the 1st sequencing run. 
```
rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/reference &
```

1st sequencing run used the allLibs reference genome for mapping.
```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_allLibs_decontam_R1R2_noIsolate/scaffolds.fasta 
```

SSL used the Sin-CPnd-A reference genome for probe design. 
```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate/scaffolds.fasta probe_design
```

#### GERP Outgroups

Copy all 37 gerp outgroup genome `\*.fa.gz` files from `1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups` to the gerp_outgroups directory. 
```
rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/*.fa.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/gerp_outgroups/ &
```

Copy `speciesnames.txt` from `1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups` to the gerp_outgroups directory. 
```
cp /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/speciesnames.txt /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/gerp_outgroups/
```

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

Created a dated phylogenetic tree. Uploaded `speciesnames.txt` to [TimeTree of Life](https://timetree.org/). Downloaded the .nwk and .jpg files that TimeTree creates. Uploaded these to the `GenErode_Sin_20k/gerp_outgroups` directory. Copied the files `gerp_tree.nwk` & `prunetree.jpg` from `1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups` to the gerp_outgroups directory. 
```
cp /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/gerp_tree.nwk /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/gerp_outgroups/

cp /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/prunetree.jpg /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/gerp_outgroups/
```

#### TimeTree Results

<img src="https://github.com/philippinespire/pire_stethojulis_interrupta_lcwgs/blob/main/2nd_sequencing_run/GenErode_Sin_20k/gerp_outgroups/prunetree.jpg" alt="Sin tree" width="700"/>

\**Notolabrus celidotus* not found in NCBI taxonomy and replaced with *Notolabrus gymnogenis*.

In the `gerp_tree.nwk` file, `Stethojulis_interrupta` was already renamed to the reference genome file name (`reference.denovoSSL.Sin20k.fasta`). 

<details><summary>gerp_tree.nwk</summary>

```
((((Karalla_daura:84.83588000,((Lutjanus_campechanus:82.26366000,(Sparus_aurata:31.84100000,Acanthopagrus_latus:31.84100000)'14':50.42266000)'13':0.49007000,(Scatophagus_argus:81.72976000,((Thamnaconus_septentrionalis:71.26750000,(Pao_palembangensis:45.34872000,Takifugu_rubripes:45.34872000)'25':25.91878000)'37':6.87480000,Antennarius_maculatus:78.14230000)'36':3.58746000)'35':1.02397000)'34':2.08215000)'43':1.10157000,((Sciaenops_ocellatus:44.60328000,(((Nibea_albiflora:23.27883000,Nibea_coibor:23.27883000)'33':17.37576000,(Collichthys_lucidus:15.93820000,Larimichthys_crocea:15.93820000)'51':24.71639000)'50':2.31829000,Argyrosomus_regius:42.97288000)'49':1.63040000)'57':6.71643000,Protonibea_diacanthus:51.31971000)'60':34.61774000)'56':10.77313000,((((((Labroides_dimidiatus:33.05912000,reference.denovoSSL.Sin20k.fasta:33.05912000)'48':0.60303000,Xyrichtys_novacula:33.66215000)'63':9.82407000,Notolabrus_celidotus:43.48622000)'47':1.87620000,(Cheilinus_undulatus:42.54118000,((Symphodus_melops:18.29928000,Tautogolabrus_adspersus:18.29928000)'68':5.74727000,(Labrus_mixtus:13.54130000,Labrus_bergylta:13.54130000)'73':10.50525000)'72':18.49463000)'84':2.82124000)'87':43.87276000,Hyperoplus_lanceolatus:89.23518000)'83':3.58438000,(Scortum_barcoo:75.71781000,(Micropterus_salmoides:59.12548000,Siniperca_scherzeri:59.12548000)'82':16.59233000)'80':17.10175000)'79':3.89102000)'94':6.86373000,((Etheostoma_cragini:32.50262000,(Sander_lucioperca:30.85028000,Perca_flavescens:30.85028000)'92':1.65234000)'78':44.47236000,((Sebastes_umbrosus:75.22844000,(((Cottus_gobio:35.27928000,Cyclopterus_lumpus:35.27928000)'98':10.64897000,Gasterosteus_aculeatus:45.92825000)'97':0.24965000,Pholis_gunnellus:46.17790000)'77':29.05054000)'71':1.69136000,Notothenia_rossii:76.91980000)'67':0.05518000)'66':26.59933000);
```

</p>
</details>

</details>


<details><summary>3. Edit Config Files</summary>

### 3. Edit Config Files

Copy config scripts to the config directory. 
```
cp /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_wahab/config/config* /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/config/
```

Edited the user-defined variables for these files: `species`, `Spp`, & `base_path`. 
```
species="stethojulis_interrupta"

Spp="Sin"

base_path=$"/archive/carpenterlab/pire/pire_${species}_lcwgs/2nd_sequencing_run/GenErode_${Spp}_20k"
```

#### Creating config files

The script `config_generode_old_new_lane.sh` will be used to create the file `old_new_lane_GenErode_Spp_config.log`. This will be used as an input for the scripts `config_modern_samples.sh` and `config_historical_samples.sh`, which will create the files `modern_samples.txt` and `historical_samples.txt`, respectively. These scripts require the input file `old_new_lane_GenErode__config.log`, which is created from the bash script `generode_config_old_new_lane.sh`.

1. Identify all `old_new_config.log` files

The `config_generode_old_new_lane.sh` script requires the `old_new_config.log` files from each fq_raw directory that will be used in GenErode.
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k

# 1st run. But don't include this. 
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/old_new_filenames.log

# 2nd run
ls ../fq_raw/old_new_filenames.log

# SSL. The SSL file does not exist and I can't find the old file names. 
ls  /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq/old_new_config.log
```

SSL files:
```
ls /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/shotgun_raw_fq/*.fq.gz
Sin-CPnd_001_Ex1-1G_L4_1.fq.gz
Sin-CPnd_001_Ex1-1G_L4_2.fq.gz
Sin-CPnd_001_Ex1-2F_L4_1.fq.gz
Sin-CPnd_001_Ex1-2F_L4_2.fq.gz
Sin-CPnd_001_Ex1-3E_L4_1.fq.gz
Sin-CPnd_001_Ex1-3E_L4_2.fq.gz
```

2. Run `config_generode_old_new_lane.sh`

Once all of the `old_new_config.log` files have been identified. Edit `file1` because we just want 2nd seq run and SSL files. 
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
file1="${lcwgs_path}/2nd_sequencing_run/fq_raw/old_new_filenames" #changed so it doesn't use this file
file2="${lcwgs_path}/2nd_sequencing_run/fq_raw/old_new_filenames.log"
file3="${lcwgs_path}/3rd_sequencing_run/fq_raw/old_new_filenames.log"
file4="${ssl_path}/fq_raw_shotgun/old_new_filenames.log"

# Define the output file
output_file="${lcwgs_path}/2nd_sequencing_run/GenErode_${Spp}_20k/config/old_new_lane_GenErode_${Spp}_config.log"
```

Run `config_generode_old_new_lane.sh` to create `old_new_lane_GenErode_Spp_config.log`. 
```
cd /archive/carpenterlab/pire/pire_genus_species_lcwgs/GenErode_Ssp_20k/config

bash generode_config_old_new_lane.sh
```

The output file `old_new_lane_GenErode_Sin_config.log` does not have a header, but the columns are `origFileName newFileName lane`.
```
File not found: /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/old_new_filenames
Including file: /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/old_new_filenames.log
File not found: /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/3rd_sequencing_run/fq_raw/old_new_filenames.log
File not found: /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/fq_raw_shotgun/old_new_filenames.log
Concatenation completed. Output saved to /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/config/old_new_lane_GenErode_Sin_config.log
```

Count the number of lines in the file. There should be 147 lines (96 modern -6 modern SSL + 50 historical + 1 header). 
```
wc -l old_new_lane_GenErode_Sin_config.log
147
```

#### Historical
Run `config_historical_samples.sh`.
```
bash config_historical_samples.sh
```

Output. All 50 \*.fq.gz files incorporated into output file `historical_samples.txt`.
```
Historical samples processing completed. Output saved to historical_samples.txt
All 25 1.fq.gz and 25 2.fq.gz files were incorporated into historical_samples.txt
```

Run `config_historical_rescaled_samplenames.sh` to get the historical sample names for the `config.yaml` file. 
```
bash config_historical_rescaled_samplenames.sh
```

Contents of output file `historical_rescaled_samplenames.txt`.
```
cat historical_rescaled_samplenames.txt

"SinAPnd001","SinAPnd002","SinAPnd003","SinAPnd004","SinAPnd005","SinAPnd006","SinAPnd007","SinAPnd008","SinAPnd009","SinAPnd010","SinAPnd011","SinAPnd012","SinAPnd013","SinAPnd014","SinAPnd015","SinAPnd016","SinAPnd017","SinAPnd018","SinAPnd019","SinAPnd020","SinAPnd021","SinAPnd022","SinAPnd023","SinAPnd024","SinAPnd025"
```

#### Modern
Run `config_modern_samples.sh`.
```
bash config_modern_samples.sh
```

Output.
```
Modern samples processing completed. Output saved to modern_samples.txt
All 51 1.fq.gz and 51 2.fq.gz files were incorporated into modern_samples.txt
```
All 102 \*.fq.gz files from the 2nd seq run and SSL were incorporated. But, the `error_modern.out` file said it was missing lane information from the 3 SSL samples (6 files), which makes sense because they weren't incorporated into the `old_new_lane_GenErode_Sin_config.log` file. Lane will have to be manually added. Lane 4 for each of these samples. 

Check `error_modern.out` file:
```
cat error_modern.out

Warning: Lane information missing for SinCPnd001 illumina modern/Sin-CPnd_001_Ex1-1G_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-1G_L4_2.fq.gz
Warning: Lane information missing for SinCPnd001 illumina modern/Sin-CPnd_001_Ex1-2F_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-2F_L4_2.fq.gz
Warning: Lane information missing for SinCPnd001 illumina modern/Sin-CPnd_001_Ex1-3E_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-3E_L4_2.fq.gz
```

The lane information for the SSL files was not incorporated so manually add `_L4` to each line that starts with `SinCPnd001`:
```
nano modern_samples.txt

SinCPnd001_Ex11G_L4 HK2C2DSX3:4 illumina modern/Sin-CPnd_001_Ex1-1G_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-1G_L4_2.fq.gz
SinCPnd001_Ex12F_L4 HK2C2DSX3:4 illumina modern/Sin-CPnd_001_Ex1-2F_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-2F_L4_2.fq.gz
SinCPnd001_Ex13E_L4 HK2C2DSX3:4 illumina modern/Sin-CPnd_001_Ex1-3E_L4_1.fq.gz modern/Sin-CPnd_001_Ex1-3E_L4_2.fq.gz
```
`modern_samples.txt` is now ready. 

#### Edit the config files

Edit `config.yaml`.

<details><summary>config.yaml</summary>

```
line 23: ref_path: "/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta"
line 31: historical_samples: "config/historical_samples.txt"
line 32: modern_samples: "config/modern_samples.txt"
Line 70: fastq_processing: True
line 89: map_historical_to_mitogenomes: False
line 165: historical_bam_mapDamage: True
line 173: historical_rescaled_samplenames: ["SinAPnd001","SinAPnd002","SinAPnd003","SinAPnd004","SinAPnd005","SinAPnd006","SinAPnd007","SinAPnd008","SinAPnd009","SinAPnd010","SinAPnd011","SinAPnd012","SinAPnd013","SinAPnd014","SinAPnd015","SinAPnd016","SinAPnd017","SinAPnd018","SinAPnd019","SinAPnd020","SinAPnd021","SinAPnd022","SinAPnd023","SinAPnd024","SinAPnd025"]
line 446: snpEff: False
line 455: gtf_path: ""
line 486: gerp: True
line 492: gerp_ref_path: "/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/gerp_outgroups"
line 501: tree: "/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k/gerp_outgroups/gerp_tree.nwk"
```

</p>
</details>

</details>


<details><summary>4. Run GenErode</summary>

### 4. Run GenErode

#### Run the pipeline

Copy the `run_GenErode*.sbatch` files to the GenErode_Sin_20k directory.
```
cp /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_wahab/run_GenErode*.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/GenErode_Sin_20k
```

Move to the GenErode_Sin_20k direcotry and run the script `run_GenErode.sbatch`.
```
sbatch run_GenErode.sbatch
```

If it is locked then unlock it with:
```
sbatch run_GenErode_unlock.sbatch
```
