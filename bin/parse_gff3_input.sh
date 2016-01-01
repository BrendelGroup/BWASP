#!/bin/sh
#
# parse_gff3_input.sh - a shell script to parse GFF3 annotation for various gene features,
#                       as needed in BWASP workflows
#
#			Version: December 29, 2015
#			Contact: Volker Brendel (vbrendel@indiana.edu)

if [ $# -lt 5 ]; then
  echo "Usage: parse_gff3_input.sh <path> <gdnafile> <gff3file> <species-label> <output-directory>"
  echo ""
  echo "       <path> = path to BWASP-required scripts and executables"
  echo ""
  echo "       Example:  parse_gff3_input.sh /usr/local/src/BWASP/bin Pdom.gdna.fa Pdom.gff3 Pdom ./GFF3DIR"
  exit
fi

BWASPBIN=$1
gfile=$2
gff3file=$3
species=$4
outputdir=$5


# 1. GFF3 master file => *.gene.gff3, *.promoter.gff3:
#
awk '$3=="gene"' $gff3file > $outputdir/$species.gene.gff3
awk '/^>/ {if (seqlen){print seqlen};print;seqtotal+=seqlen;seqlen=0;seq+=1;next;} {seqlen=seqlen+length($0)} END{print seqlen;print seq" sequences, total length " seqtotal+seqlen}' $gfile > $outputdir/$gfile.sl
python $BWASPBIN/gene2promoter.py $outputdir/$species.gene.gff3 $outputdir/$gfile.sl $outputdir/$species.promoter.gff3


# 2. Run AEGean pmrna to to pull out a single representative mRNA for each gene and its exons:
#
$BWASPBIN/pmrna -p -i <$gff3file> $outputdir/$species.pmrna.gff3
awk '$3== "exon"' $outputdir/$species.pmrna.gff3 > $outputdir/$species.exon.gff3


# 3. Run AEGean canon-gff3 to obtain the protein coding features
#
$BWASPBIN/canon-gff3 < $outputdir/$species.pmrna.gff3 > $outputdir/$species.pcg.gff3
awk '$3== "gene"'            $outputdir/$species.pcg.gff3 > $outputdir/$species.pcg-gene.gff3
awk '$3== "exon"'            $outputdir/$species.pcg.gff3 > $outputdir/$species.pcg-exon.gff3
awk '$3== "CDS"'             $outputdir/$species.pcg.gff3 > $outputdir/$species.pcg-CDS.gff3
awk '$3== "five_prime_UTR"'  $outputdir/$species.pcg.gff3 > $outputdir/$species.pcg-5pUTR.gff3
awk '$3== "three_prime_UTR"' $outputdir/$species.pcg.gff3 > $outputdir/$species.pcg-3pUTR.gff3
python $BWASPBIN/gene2promoter.py $outputdir/$species.pcg-gene.gff3 $outputdir/$gfile.sl $outputdir/$species.pcg-promoter.gff3
