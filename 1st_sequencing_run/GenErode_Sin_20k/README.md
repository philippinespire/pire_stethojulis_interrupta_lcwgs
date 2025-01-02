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



