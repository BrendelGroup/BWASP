#!/bin/bash

# Script to download a sra file from the ncbi ftp servers
# Url is derived as described in https://www.ncbi.nlm.nih.gov/books/NBK158899/
# only imput parameter is the SRA accession number

accession=$1

url=ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/${accession:0:3}/${accession:0:6}/${accession}/${accession}.sra

wget -nv $url
