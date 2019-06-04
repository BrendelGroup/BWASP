#!/bin/bash

# Script to download a fastq file from the EBI ftp servers
# Url is derived as described in https://www.ebi.ac.uk/ena/browse/read-download
# Only input parameter is the SRA accession number

accession=$1

#ftp://ftp.sra.ebi.ac.uk/vol1/fastq/<dir1>[/<dir2>]/<run accession>

#<dir1> is the first 6 letters and numbers of the run accession ( e.g. ERR000 for ERR000916 ),

#<dir2> does not exist if the run accession has six digits. For example, fastq files for run ERR000916 are in directory: ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR000/ERR000916/.

#If the run accession has seven digits then the <dir2> is 00 + the last digit of the run accession. For example, fastq files for run SRR1016916 are in directory: ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR101/006/SRR1016916/.

#If the run accession has eight digits then the <dir2> is 0 + the last two digits of the run accession.

#If the run accession has nine digits then the <dir2> is the last three digits of the run accession.

ftpbase=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/
asperabase=era-fasp@fasp.sra.ebi.ac.uk:/vol1/fastq/

dir1="${accession:0:6}/"


case ${#accession} in
	"9")
		dir2=""
		;;
	"10")
		dir2="00${accession:9}"
		;;
	"11")
		dir2="0${accession:9:10}"
		;;
	"12")
		dir2="${accession:9:11}"
		;;
esac

ascp -QT -l 300m -P33001 -i $ASPERA_CERT $asperabase$dir1$dir2/$accession/$accession.fastq.gz . || (
ascp -QT -l 300m -P33001 -i $ASPERA_CERT $asperabase$dir1$dir2/$accession/${accession}_1.fastq.gz . &&
ascp -QT -l 300m -P33001 -i $ASPERA_CERT $asperabase$dir1$dir2/$accession/${accession}_2.fastq.gz . )
	
gunzip $accession.fastq.gz || (
gunzip ${accession}_1.fastq.gz &&
gunzip ${accession}_2.fastq.gz )

