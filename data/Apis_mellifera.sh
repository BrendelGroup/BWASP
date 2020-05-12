#!/bin/bash

# This is a script to generate the necessary directory structure
# and fill in the relevant accession numbers for all publicly available
# bisulfite sequencing experiments on Apis Mellifera

PE_TEMPLATE_GENOME=Pcan.gdna
PE_TEMPLATE_SRA=SRR1519132

SE_TEMPLATE_GENOME=Amel.gdna
SE_TEMPLATE_SRA=SRR1270128

GENOME=Amel_HAv3.1 # https://www.ncbi.nlm.nih.gov/genome/48?genome_assembly_id=403979

## Assembly
if [ ! -f Amel/genome/${GENOME}.fa ]; then
  mkdir -p Amel/genome
  pushd Amel/genome
  wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/254/395/GCF_003254395.2_Amel_HAv3.1/GCF_003254395.2_Amel_HAv3.1_genomic.fna.gz
  gunzip GCF_003254395.2_Amel_HAv3.1_genomic.fna.gz
  ln GCF_003254395.2_Amel_HAv3.1_genomic.fna ${GENOME}.fa
  popd
fi

## Annotation
if [ ! -f Amel/genome/${GENOME}.gff ]; then
  mkdir -p Amel/genome
  pushd Amel/genome
  wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/254/395/GCF_003254395.2_Amel_HAv3.1/GCF_003254395.2_Amel_HAv3.1_genomic.gff.gz
  gunzip GCF_003254395.2_Amel_HAv3.1_genomic.gff.gz
  ln GCF_003254395.2_Amel_HAv3.1_genomic.gff ${GENOME}.gff
  popd
fi

## Experiments :

EXPERIMENT=Feng2010  # https://doi.org/10.1073/pnas.1002720107

./xmkdirstr Amel ${EXPERIMENT} immature_male 2 s

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR039327/;" Amel/${EXPERIMENT}/immature_male/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR039328/;" Amel/${EXPERIMENT}/immature_male/replicate2/Makefile


EXPERIMENT=Zemach2010 # https://doi.org/10.1126/science.1186366

./xmkdirstr Amel ${EXPERIMENT} worker 4 p

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR042617/;" Amel/${EXPERIMENT}/worker/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR042618/;" Amel/${EXPERIMENT}/worker/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR042619/;" Amel/${EXPERIMENT}/worker/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR042620/;" Amel/${EXPERIMENT}/worker/replicate4/Makefile


EXPERIMENT=Lyko2010 # https://doi.org/10.1371/journal.pbio.1000506

./xmkdirstr Amel ${EXPERIMENT} queen 1 p
./xmkdirstr Amel ${EXPERIMENT} worker 1 p

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR039815/;" Amel/${EXPERIMENT}/queen/replicate1/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR039814/;" Amel/${EXPERIMENT}/worker/replicate1/Makefile


EXPERIMENT=Foret # https://doi.org/10.1371/journal.pbio.1000506

./xmkdirstr Amel ${EXPERIMENT} queen 2 s
./xmkdirstr Amel ${EXPERIMENT} worker 2 s

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR353494/;" Amel/${EXPERIMENT}/queen/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR353496/;" Amel/${EXPERIMENT}/queen/replicate2/Makefile

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR353497/;" Amel/${EXPERIMENT}/worker/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR353498/;" Amel/${EXPERIMENT}/worker/replicate2/Makefile


EXPERIMENT=Herb2012 # https://doi.org/10.1038/nn.3218

./xmkdirstr Amel ${EXPERIMENT} forager 6 p
./xmkdirstr Amel ${EXPERIMENT} queen 5 p
./xmkdirstr Amel ${EXPERIMENT} reverted_nurse 6 p
./xmkdirstr Amel ${EXPERIMENT} worker 5 p

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445773/;" Amel/${EXPERIMENT}/forager/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445771/;" Amel/${EXPERIMENT}/forager/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445770/;" Amel/${EXPERIMENT}/forager/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445769/;" Amel/${EXPERIMENT}/forager/replicate4/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445768/;" Amel/${EXPERIMENT}/forager/replicate5/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445767/;" Amel/${EXPERIMENT}/forager/replicate6/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445809/;" Amel/${EXPERIMENT}/worker/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445808/;" Amel/${EXPERIMENT}/worker/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445807/;" Amel/${EXPERIMENT}/worker/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445806/;" Amel/${EXPERIMENT}/worker/replicate4/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445805/;" Amel/${EXPERIMENT}/worker/replicate5/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445800/;" Amel/${EXPERIMENT}/queen/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445801/;" Amel/${EXPERIMENT}/queen/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445802/;" Amel/${EXPERIMENT}/queen/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445803/;" Amel/${EXPERIMENT}/queen/replicate4/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445804/;" Amel/${EXPERIMENT}/queen/replicate5/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445799/;" Amel/${EXPERIMENT}/reverted_nurse/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445778/;" Amel/${EXPERIMENT}/reverted_nurse/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445777/;" Amel/${EXPERIMENT}/reverted_nurse/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445776/;" Amel/${EXPERIMENT}/reverted_nurse/replicate4/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445775/;" Amel/${EXPERIMENT}/reverted_nurse/replicate5/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR445774/;" Amel/${EXPERIMENT}/reverted_nurse/replicate6/Makefile


EXPERIMENT=Li-Byarlay2013 # https://doi.org/10.1073/pnas.1310735110

./xmkdirstr Amel ${EXPERIMENT} control 1 s
./xmkdirstr Amel ${EXPERIMENT} knockdown 1 s

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR1270128/;" Amel/${EXPERIMENT}/control/replicate1/Makefile

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR1270129/;" Amel/${EXPERIMENT}/knockdown/replicate1/Makefile


EXPERIMENT=Cingolani2013 # https://dx.doi.org/10.1186/1471-2164-14-666

./xmkdirstr Amel ${EXPERIMENT} european 1 s
./xmkdirstr Amel ${EXPERIMENT} africanized 1 s

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR989671/;" Amel/${EXPERIMENT}/european/replicate1/Makefile

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR989670/;" Amel/${EXPERIMENT}/africanized/replicate1/Makefile


EXPERIMENT=Drewell2014 # https://dx.doi.org/10.1242/dev.110163

./xmkdirstr Amel ${EXPERIMENT} drone 1 p
./xmkdirstr Amel ${EXPERIMENT} haploid_egg 1 p
./xmkdirstr Amel ${EXPERIMENT} sperm 1 p

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR9316836/;" Amel/${EXPERIMENT}/drone/replicate1/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR9316837/;" Amel/${EXPERIMENT}/haploid_egg/replicate1/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR9316838/;" Amel/${EXPERIMENT}/sperm/replicate1/Makefile


EXPERIMENT=Remnant2016 # https://dx.doi.org/10.1186/s12864-016-2506-8

./xmkdirstr Amel ${EXPERIMENT} fembryo 1 p
./xmkdirstr Amel ${EXPERIMENT} tembryo 1 p

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR1994693/;" Amel/${EXPERIMENT}/fembryo/replicate1/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR1994694/;" Amel/${EXPERIMENT}/tembryo/replicate1/Makefile


EXPERIMENT=Li2017 # https://dx.doi.org/10.1038/s41598-017-17046-1

./xmkdirstr Amel ${EXPERIMENT} control 1 p
./xmkdirstr Amel ${EXPERIMENT} trained 1 p

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR5312519/;" Amel/${EXPERIMENT}/control/replicate1/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR5295651/;" Amel/${EXPERIMENT}/trained/replicate1/Makefile


EXPERIMENT=Herb2018 # https://dx.doi.org/10.1186/s12864-018-4594-0

./xmkdirstr Amel ${EXPERIMENT} A_120min 6 p
./xmkdirstr Amel ${EXPERIMENT} C_120min 6 p
./xmkdirstr Amel ${EXPERIMENT} A_5min 6 p
./xmkdirstr Amel ${EXPERIMENT} C_5min 6 p

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175588/;" Amel/${EXPERIMENT}/A_120min/replicate6/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175587/;" Amel/${EXPERIMENT}/A_120min/replicate5/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175586/;" Amel/${EXPERIMENT}/A_120min/replicate4/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175585/;" Amel/${EXPERIMENT}/A_120min/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175584/;" Amel/${EXPERIMENT}/A_120min/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175583/;" Amel/${EXPERIMENT}/A_120min/replicate1/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175582/;" Amel/${EXPERIMENT}/C_120min/replicate6/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175581/;" Amel/${EXPERIMENT}/C_120min/replicate5/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175580/;" Amel/${EXPERIMENT}/C_120min/replicate4/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175579/;" Amel/${EXPERIMENT}/C_120min/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175578/;" Amel/${EXPERIMENT}/C_120min/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175577/;" Amel/${EXPERIMENT}/C_120min/replicate1/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175576/;" Amel/${EXPERIMENT}/A_5min/replicate6/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175575/;" Amel/${EXPERIMENT}/A_5min/replicate5/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175574/;" Amel/${EXPERIMENT}/A_5min/replicate4/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175573/;" Amel/${EXPERIMENT}/A_5min/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175572/;" Amel/${EXPERIMENT}/A_5min/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175571/;" Amel/${EXPERIMENT}/A_5min/replicate1/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175570/;" Amel/${EXPERIMENT}/C_5min/replicate6/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175569/;" Amel/${EXPERIMENT}/C_5min/replicate5/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175568/;" Amel/${EXPERIMENT}/C_5min/replicate4/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175567/;" Amel/${EXPERIMENT}/C_5min/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175566/;" Amel/${EXPERIMENT}/C_5min/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR6175565/;" Amel/${EXPERIMENT}/C_5min/replicate1/Makefile


EXPERIMENT=Harris2019 # https://doi.org/10.1186/s13072-019-0307-4

./xmkdirstr Amel ${EXPERIMENT} drone_head 2 s
./xmkdirstr Amel ${EXPERIMENT} drone_larva 4 s
./xmkdirstr Amel ${EXPERIMENT} drone_sperm 3 s
./xmkdirstr Amel ${EXPERIMENT} queen_head 2 s
./xmkdirstr Amel ${EXPERIMENT} worker_embryo 3 s
./xmkdirstr Amel ${EXPERIMENT} worker_head 3 s
./xmkdirstr Amel ${EXPERIMENT} worker_pupa 3 s

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472342/;" Amel/${EXPERIMENT}/drone_head/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472349/;" Amel/${EXPERIMENT}/drone_head/replicate2/Makefile

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472339/;" Amel/${EXPERIMENT}/drone_larva/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472340/;" Amel/${EXPERIMENT}/drone_larva/replicate2/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472341/;" Amel/${EXPERIMENT}/drone_larva/replicate3/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472348/;" Amel/${EXPERIMENT}/drone_larva/replicate4/Makefile

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472329/;" Amel/${EXPERIMENT}/drone_sperm/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472330/;" Amel/${EXPERIMENT}/drone_sperm/replicate2/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR9077639/;" Amel/${EXPERIMENT}/drone_sperm/replicate3/Makefile

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472343/;" Amel/${EXPERIMENT}/queen_head/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472350/;" Amel/${EXPERIMENT}/queen_head/replicate2/Makefile

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472331/;" Amel/${EXPERIMENT}/worker_embryo/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472332/;" Amel/${EXPERIMENT}/worker_embryo/replicate2/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472344/;" Amel/${EXPERIMENT}/worker_embryo/replicate3/Makefile

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472337/;" Amel/${EXPERIMENT}/worker_head/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472338/;" Amel/${EXPERIMENT}/worker_head/replicate2/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472347/;" Amel/${EXPERIMENT}/worker_head/replicate3/Makefile

sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472335/;" Amel/${EXPERIMENT}/worker_pupa/replicate1/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472336/;" Amel/${EXPERIMENT}/worker_pupa/replicate2/Makefile
sed -i -e "s/${SE_TEMPLATE_GENOME}/${GENOME}/; s/${SE_TEMPLATE_SRA}/SRR7472346/;" Amel/${EXPERIMENT}/worker_pupa/replicate3/Makefile


EXPERIMENT=BGI2020 # https://doi.org/

./xmkdirstr Amel ${EXPERIMENT} sperm 2 p
./xmkdirstr Amel ${EXPERIMENT} oocyte 2 p
./xmkdirstr Amel ${EXPERIMENT} worker_blastoderm 2 p
./xmkdirstr Amel ${EXPERIMENT} worker_gastrula 2 p
./xmkdirstr Amel ${EXPERIMENT} drone_blastoderm 2 p
./xmkdirstr Amel ${EXPERIMENT} drone_gastrula 2 p

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433702/;" Amel/${EXPERIMENT}/sperm/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433703/;" Amel/${EXPERIMENT}/sperm/replicate2/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433704/;" Amel/${EXPERIMENT}/oocyte/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433705/;" Amel/${EXPERIMENT}/oocyte/replicate2/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433706/;" Amel/${EXPERIMENT}/worker_blastoderm/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433707/;" Amel/${EXPERIMENT}/worker_blastoderm/replicate2/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433708/;" Amel/${EXPERIMENT}/worker_gastrula/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433709/;" Amel/${EXPERIMENT}/worker_gastrula/replicate2/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433710/;" Amel/${EXPERIMENT}/drone_blastoderm/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433711/;" Amel/${EXPERIMENT}/drone_blastoderm/replicate2/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433712/;" Amel/${EXPERIMENT}/drone_gastrula/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR2433713/;" Amel/${EXPERIMENT}/drone_gastrula/replicate2/Makefile


EXPERIMENT=Jiangxi2020 # https://doi.org/

./xmkdirstr Amel ${EXPERIMENT} G1E 3 p
./xmkdirstr Amel ${EXPERIMENT} G1L1 3 p
./xmkdirstr Amel ${EXPERIMENT} G1L2 4 p
./xmkdirstr Amel ${EXPERIMENT} G2E 3 p
./xmkdirstr Amel ${EXPERIMENT} G2L1 3 p
./xmkdirstr Amel ${EXPERIMENT} G2L2 2 p
./xmkdirstr Amel ${EXPERIMENT} G3E 3 p
./xmkdirstr Amel ${EXPERIMENT} G3L1 3 p
./xmkdirstr Amel ${EXPERIMENT} G3L2 3 p
./xmkdirstr Amel ${EXPERIMENT} G4E 4 p
./xmkdirstr Amel ${EXPERIMENT} G4L1 4 p
./xmkdirstr Amel ${EXPERIMENT} G4L2 4 p

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821802/;" Amel/${EXPERIMENT}/G1E/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821813/;" Amel/${EXPERIMENT}/G1E/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821814/;" Amel/${EXPERIMENT}/G1E/replicate3/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821780/;" Amel/${EXPERIMENT}/G1L1/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821781/;" Amel/${EXPERIMENT}/G1L1/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821791/;" Amel/${EXPERIMENT}/G1L1/replicate3/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821776/;" Amel/${EXPERIMENT}/G1L2/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821777/;" Amel/${EXPERIMENT}/G1L2/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821778/;" Amel/${EXPERIMENT}/G1L2/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821779/;" Amel/${EXPERIMENT}/G1L2/replicate4/Makefile


sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821810/;" Amel/${EXPERIMENT}/G2E/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821811/;" Amel/${EXPERIMENT}/G2E/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821812/;" Amel/${EXPERIMENT}/G2E/replicate3/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821807/;" Amel/${EXPERIMENT}/G2L1/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821808/;" Amel/${EXPERIMENT}/G2L1/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821809/;" Amel/${EXPERIMENT}/G2L1/replicate3/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821805/;" Amel/${EXPERIMENT}/G2L2/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821806/;" Amel/${EXPERIMENT}/G2L2/replicate2/Makefile


sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821801/;" Amel/${EXPERIMENT}/G3E/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821803/;" Amel/${EXPERIMENT}/G3E/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821804/;" Amel/${EXPERIMENT}/G3E/replicate3/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821798/;" Amel/${EXPERIMENT}/G3L1/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821799/;" Amel/${EXPERIMENT}/G3L1/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821800/;" Amel/${EXPERIMENT}/G3L1/replicate3/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821795/;" Amel/${EXPERIMENT}/G3L2/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821796/;" Amel/${EXPERIMENT}/G3L2/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821797/;" Amel/${EXPERIMENT}/G3L2/replicate3/Makefile


sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821790/;" Amel/${EXPERIMENT}/G4E/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821792/;" Amel/${EXPERIMENT}/G4E/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821793/;" Amel/${EXPERIMENT}/G4E/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821794/;" Amel/${EXPERIMENT}/G4E/replicate4/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821786/;" Amel/${EXPERIMENT}/G4L1/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821787/;" Amel/${EXPERIMENT}/G4L1/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821788/;" Amel/${EXPERIMENT}/G4L1/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821789/;" Amel/${EXPERIMENT}/G4L1/replicate4/Makefile

sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821782/;" Amel/${EXPERIMENT}/G4L2/replicate1/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821783/;" Amel/${EXPERIMENT}/G4L2/replicate2/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821784/;" Amel/${EXPERIMENT}/G4L2/replicate3/Makefile
sed -i -e "s/${PE_TEMPLATE_GENOME}/${GENOME}/; s/${PE_TEMPLATE_SRA}/SRR10821785/;" Amel/${EXPERIMENT}/G4L2/replicate4/Makefile
