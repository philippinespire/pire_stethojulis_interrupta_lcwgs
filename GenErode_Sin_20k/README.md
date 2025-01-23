<img src="https://inaturalist-open-data.s3.amazonaws.com/photos/236392150/original.jpg" alt="Sin" width="300"/>

# GenErode: *Stethojulis interrupta* lcWGS from Pandanon Island.

Following the [GenErode pipeline](https://github.com/philippinespire/pire_lcwgs_data_processing/tree/main/scripts/GenErode_wahab) for *Stethojulis interrupta* lcWGS data from the 1st & 2nd sequencing runs from Pandanon Island (Modern) and Cebu City Market (Historical). 

```
/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k
```

<details><summary>1. Set-Up</summary>

### 1. Set-up

This GenErode run will initially not use the SSL data, which all comes from the individual Sin-CPnd_001. This individual does not have lcWGS data. When GenErode was run on lcWGS data from the 1st sequencing run and the SSL data, this sample never finished GenErode processing after several days. It can be run on it's own after the initial GenErode run on the lcWGS data if it is decided that 1 more modern individual is necessary. 

Create the GenErode directory and subdirectories. 
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs

mkdir GenErode_Sin_20k

cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k

mkdir config historical modern reference gerp_outgroups logs
```

Copy the contents of the template directory to your GenErode directory.
```
rsync -a /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_wahab/GenErode_templatedir/* /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/ &
```

Analyzing lcWGS data from the 1st & 2nd sequencing run. Not analyzing SSL data. SSL data is just from individual SinCPnd001, which is not represented in the lcWGS data. These files can be analyzed later if necessary.

Count and copy raw `\*.fq.gz` files to their respective GenErode directories. Do not copy `Undetermined\*.fq.gz` files. 

#### Historical
```
# 1st run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/Sin-APnd*.fq.gz | wc -l
50

rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/Sin-APnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/historical &

# 2nd run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/Sin-APnd*.fq.gz | wc -l
50

rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/Sin-APnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/historical &

ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/historical | wc -l
100
```

#### Modern
```
# 1st run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/Sin-CPnd*.fq.gz | wc -l
128

rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/Sin-CPnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/modern &

# 2nd run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/Sin-CPnd*.fq.gz | wc -l
96

rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/Sin-CPnd*.fq.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/modern &

ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/modern | wc -l
224
```

#### Reference

Use the 20k version (scaffolds > 20kbp) of the best reference genome that was used for probe development and mkBAM. However, probe development and mkBAM (for the 1st sequencing run) used different reference genomes. Use the reference genome that was used for mapping, unless the reference genome that was used for probe design is significantly better. In this case the reference genome that was used for probe design is significantly better than the one that was used for mapping the 1st sequencing run. 
```
/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate/scaffolds.fasta 
```

Copy the `SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate/scaffolds.fasta` reference genome that was used for probe design to the GenErode reference directory. 
```
rsync -a /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/SPAdes_Sin-CPnd-A_decontam_R1R2_noIsolate/scaffolds.fasta /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference &
```

Create the 20k reference genome `reference.denovoSSL.Sin20k.fasta` from this reference genome. 
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference

perl /home/e1garcia/shotgun_PIRE/REUs/2022_REU/PSMC/scripts/removesmalls.pl 20000 scaffolds.fasta > reference.denovoSSL.Sin20k.fasta
```

#### GERP Outgroups

Copy all 37 gerp outgroup genome `\*.fa.gz` files from `1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups` to the gerp_outgroups directory. 
```
rsync -a /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/*.fa.gz /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/gerp_outgroups/ &
```

Copy `speciesnames.txt` from `1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups` to the gerp_outgroups directory. 
```
cp /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/speciesnames.txt /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/gerp_outgroups/
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
cp /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/gerp_tree.nwk /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/gerp_outgroups/

cp /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/GenErode_Sin_20k/gerp_outgroups/prunetree.jpg /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/gerp_outgroups/
```

#### TimeTree Results

<img src="https://github.com/philippinespire/pire_stethojulis_interrupta_lcwgs/blob/main/GenErode_Sin_20k/gerp_outgroups/prunetree.jpg" alt="Sin tree" width="700"/>

\**Notolabrus celidotus* not found in NCBI taxonomy and replaced with *Notolabrus gymnogenis*.

In the `gerp_tree.nwk` file, `Stethojulis_interrupta` was already renamed to the reference genome file name (`reference.denovoSSL.Sin20k.fasta`). 

<details><summary>gerp_tree.nwk</summary>

```
((((Karalla_daura:84.83588000,((Lutjanus_campechanus:82.26366000,(Sparus_aurata:31.84100000,Acanthopagrus_latus:31.84100000)'14':50.42266000)'13':0.49007000,(Scatophagus_argus:81.72976000,((Thamnaconus_septentrionalis:71.26750000,(Pao_palembangensis:45.34872000,Takifugu_rubripes:45.34872000)'25':25.91878000)'37':6.87480000,Antennarius_maculatus:78.14230000)'36':3.58746000)'35':1.02397000)'34':2.08215000)'43':1.10157000,((Sciaenops_ocellatus:44.60328000,(((Nibea_albiflora:23.27883000,Nibea_coibor:23.27883000)'33':17.37576000,(Collichthys_lucidus:15.93820000,Larimichthys_crocea:15.93820000)'51':24.71639000)'50':2.31829000,Argyrosomus_regius:42.97288000)'49':1.63040000)'57':6.71643000,Protonibea_diacanthus:51.31971000)'60':34.61774000)'56':10.77313000,((((((Labroides_dimidiatus:33.05912000,reference.denovoSSL.Sin20k.fasta:33.05912000)'48':0.60303000,Xyrichtys_novacula:33.66215000)'63':9.82407000,Notolabrus_celidotus:43.48622000)'47':1.87620000,(Cheilinus_undulatus:42.54118000,((Symphodus_melops:18.29928000,Tautogolabrus_adspersus:18.29928000)'68':5.74727000,(Labrus_mixtus:13.54130000,Labrus_bergylta:13.54130000)'73':10.50525000)'72':18.49463000)'84':2.82124000)'87':43.87276000,Hyperoplus_lanceolatus:89.23518000)'83':3.58438000,(Scortum_barcoo:75.71781000,(Micropterus_salmoides:59.12548000,Siniperca_scherzeri:59.12548000)'82':16.59233000)'80':17.10175000)'79':3.89102000)'94':6.86373000,((Etheostoma_cragini:32.50262000,(Sander_lucioperca:30.85028000,Perca_flavescens:30.85028000)'92':1.65234000)'78':44.47236000,((Sebastes_umbrosus:75.22844000,(((Cottus_gobio:35.27928000,Cyclopterus_lumpus:35.27928000)'98':10.64897000,Gasterosteus_aculeatus:45.92825000)'97':0.24965000,Pholis_gunnellus:46.17790000)'77':29.05054000)'71':1.69136000,Notothenia_rossii:76.91980000)'67':0.05518000)'66':26.59933000);
```

</p>
</details>

</details>

<details><summary>3. Config Files</summary>

### 3. Config Files

1. Copy config scripts to the config directory. 
```
cd /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k

cp /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_wahab/config/config* /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/config/
```

2. Edit the user-defined variables for the files `config_modern_samples.sh`, `config_historical_samples.sh`, and `config_generode_old_new_lane.sh`.
```
species="stethojulis_interrupta"

Spp="Sin"
```

3. Identify all `old_new_config.log` files.

The `config_generode_old_new_lane.sh` script requires the `old_new_config.log` files from each fq_raw directory that will be used in GenErode. The log files for both the 1st & 2nd sequencing runs are available.
```
# 1st run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/old_new_filenames.log

# 2nd run
ls /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/old_new_filenames.log
```

4. Run `config_generode_old_new_lane.sh` to create `old_new_lane_GenErode_Spp_config.log`.

Once all of the `old_new_config.log` files have been identified and the user-defined variables have been edited, run `config_generode_old_new_lane.sh` to create `old_new_lane_GenErode_Spp_config.log`.
```
bash config_generode_old_new_lane.sh
```

The output file `old_new_lane_GenErode_Sin_config.log` does not have a header, but the columns are `origFileName newFileName lane`.
```
Including file: /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/1st_sequencing_run/fq_raw/old_new_filenames.log
Including file: /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/2nd_sequencing_run/fq_raw/old_new_filenames.log
File not found: /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/3rd_sequencing_run/fq_raw/old_new_filenames.log
File not found: /home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/stethojulis_interrupta/fq_raw_shotgun/old_new_filenames.log
Concatenation completed. Output saved to /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/config/old_new_lane_GenErode_Sin_config.log
```

Count the number of lines in the file. There should be 325 lines (224 modern + 100 historical + 1 header). 
```
wc -l old_new_lane_GenErode_Sin_config.log
325
```

5. Run `config_historical_samples.sh` to create `historical_samples.txt`.
```
bash config_historical_samples.sh
```

Output:
```
Historical samples processing completed. Output saved to historical_samples.txt
All 50 1.fq.gz and 50 2.fq.gz files were incorporated into historical_samples.txt
```
All 100 historical \*.fq.gz files incorporated into output file `historical_samples.txt`.

6. Run `config_historical_rescaled_samplenames.sh` to get line 173: `historical_rescaled_samplenames:` for the `config.yaml` file. 
```
bash config_historical_rescaled_samplenames.sh
```

Contents of output file `historical_rescaled_samplenames.txt`.
```
cat historical_rescaled_samplenames.txt

"SinAPnd001","SinAPnd002","SinAPnd003","SinAPnd004","SinAPnd005","SinAPnd006","SinAPnd007","SinAPnd008","SinAPnd009","SinAPnd010","SinAPnd011","SinAPnd012","SinAPnd013","SinAPnd014","SinAPnd015","SinAPnd016","SinAPnd017","SinAPnd018","SinAPnd019","SinAPnd020","SinAPnd021","SinAPnd022","SinAPnd023","SinAPnd024","SinAPnd025"
```

7. Run `config_modern_samples.sh` to create `modern_samples.txt`. 
```
bash config_modern_samples.sh
```

Output:
```
Modern samples processing completed. Output saved to modern_samples.txt
All 112 1.fq.gz and 112 2.fq.gz files were incorporated into modern_samples.txt
```
All 224 modern \*.fq.gz files incorporated into output file `modern_samples.txt`. 

8. Edit `config.yaml`.

<details><summary>config.yaml</summary>

```
line 23: ref_path: "/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/reference/reference.denovoSSL.Sin20k.fasta"
line 31: historical_samples: "config/historical_samples.txt"
line 32: modern_samples: "config/modern_samples.txt"
Line 70: fastq_processing: True
line 89: map_historical_to_mitogenomes: False
line 165: historical_bam_mapDamage: True
line 173: historical_rescaled_samplenames: ["SinAPnd001","SinAPnd002","SinAPnd003","SinAPnd004","SinAPnd005","SinAPnd006","SinAPnd007","SinAPnd008","SinAPnd009","SinAPnd010","SinAPnd011","SinAPnd012","SinAPnd013","SinAPnd014","SinAPnd015","SinAPnd016","SinAPnd017","SinAPnd018","SinAPnd019","SinAPnd020","SinAPnd021","SinAPnd022","SinAPnd023","SinAPnd024","SinAPnd025"]
line 446: snpEff: False
line 455: gtf_path: ""
line 486: gerp: True
line 492: gerp_ref_path: "/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/gerp_outgroups"
line 501: tree: "/archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k/gerp_outgroups/gerp_tree.nwk"
```

</p>
</details>

</details>


<details><summary>4. Run GenErode</summary>

### 4. Run GenErode

#### Run the pipeline

Copy the `run_GenErode*.sbatch` files to the GenErode_Sin_20k directory.
```
cp /home/e1garcia/shotgun_PIRE/pire_lcwgs_data_processing/scripts/GenErode_wahab/run_GenErode*.sbatch /archive/carpenterlab/pire/pire_stethojulis_interrupta_lcwgs/GenErode_Sin_20k
```

Move to the GenErode_Sin_20k direcotry and run the script `run_GenErode.sbatch`.
```
sbatch run_GenErode.sbatch
```

JobID:
```
Submitted batch job 4137740
```
