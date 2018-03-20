#!/bin/sh
#

#BWASP script sstats-se.sh
#
# This script takes various BWASP output files and prints out sample
# statistics to file ${SAMPLE}.stats. Required input variables are as
# defined in the calling makefile.

SAMPLE=$1
SYNONYM=$2
GENOME=$3
SAMTOOLS=$4

echo "Sample:		${SAMPLE}"
echo "Synonym:	${SYNONYM}"
echo "Genome:		${GENOME}"
echo "SAMTOOLS:	${SAMTOOLS}"
echo ""


### Sample statistics

RAWREAD_NB1=`wc -l ${SAMPLE}.fastq|cut -d' ' -f1`
RAWREAD_NB=`awk "BEGIN {print ${RAWREAD_NB1}/4}"`
echo "Number of raw reads: ${RAWREAD_NB}" > ${SAMPLE}.stats

RAWREAD_LGTH=`awk 'NR==9' FastQC/${SAMPLE}_fastqc/fastqc_data.txt | awk -F" " '{print $3}'`
echo "Raw read length (per FastQC report): ${RAWREAD_LGTH}" >> ${SAMPLE}.stats

RAWSAMPLE_SZE=`awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length($0);}}END{print sum;}' ${SAMPLE}.fastq`
echo "Raw read sample size: ${RAWSAMPLE_SZE} bp" >> ${SAMPLE}.stats


TRMREAD_NB1=`wc -l ${SAMPLE}_trimmed.fq|cut -d' ' -f1`
TRMREAD_NB=`awk "BEGIN {print ${TRMREAD_NB1}/4}"`
echo "Number of trimmed reads: ${TRMREAD_NB}" >> ${SAMPLE}.stats

TRMREAD_LGTH=`awk 'NR==9' FastQC/${SAMPLE}_trimmed_fastqc/fastqc_data.txt | awk -F" " '{print $3}'`
echo "Trimmed read length range (per FastQC report): ${TRMREAD_LGTH}" >> ${SAMPLE}.stats
TRMREAD_ML=`cat ${SAMPLE}_trimmed.fq | awk '{if(NR%4==2) print length($1)}' > /tmp/${SAMPLE}_readlength1.txt; sort -n /tmp/${SAMPLE}_readlength1.txt| awk ' { a[i++]=$1; } END { print a[int(i/2)]; }'`
echo "Median length of trimmed reads: ${TRMREAD_ML}" >> ${SAMPLE}.stats

TRMSAMPLE_SZE=`awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length($0);}}END{print sum;}' ${SAMPLE}_trimmed.fq`
echo "Trimmed sample size: ${TRMSAMPLE_SZE} bp" >> ${SAMPLE}.stats

TOTAL_ALGNDBASE_CNT=`samtools depth ${SYNONYM}.bam | awk '{sum+=$3}END{print sum}'`
genome_size=`awk 'NR==1{print $4}' ${GENOME}.stats`
COVERAGE=`awk "BEGIN {printf \"%.2f\", ${TOTAL_ALGNDBASE_CNT}/${genome_size} }"`
echo "Genome coverage: ${COVERAGE} (= ${TOTAL_ALGNDBASE_CNT} / ${genome_size})" >> ${SAMPLE}.stats
