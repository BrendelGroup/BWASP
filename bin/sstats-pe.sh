#!/bin/sh
#

#BWASP script sstats-pe.sh
#
# This script takes various BWASP output files and prints out sample
# statistics to file ${SAMPLE}.stats. Required input variables are as
# defined in the calling makefile.

SAMPLE=$1
SYNONYM=$2
GENOME=$3

echo "Sample:		${SAMPLE}"
echo "Synonym:	${SYNONYM}"
echo "Genome:		${GENOME}"
echo ""


### Sample statistics

RAWREAD_NB1=`wc -l ${SAMPLE}_1.fastq|cut -d' ' -f1`
RAWREAD_NB2=`wc -l ${SAMPLE}_2.fastq|cut -d' ' -f1`
RAWREAD_NB=`awk "BEGIN {print ${RAWREAD_NB1}/4+${RAWREAD_NB2}/4}"`
echo "Number of raw reads: ${RAWREAD_NB} (sum of left and right reads)" > ${SAMPLE}.stats

RAWREAD_LGTH1=`awk 'NR==9' FastQC/${SAMPLE}_1_fastqc/fastqc_data.txt | awk -F" " '{print $3}'`
RAWREAD_LGTH2=`awk 'NR==9' FastQC/${SAMPLE}_2_fastqc/fastqc_data.txt | awk -F" " '{print $3}'`
echo "Raw read length (per FastQC report): ${RAWREAD_LGTH1} (left reads), ${RAWREAD_LGTH2} (right reads)" >> ${SAMPLE}.stats

RAWREAD_SZE1=`awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length($0);}}END{print sum;}' ${SAMPLE}_1.fastq`
RAWREAD_SZE2=`awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length($0);}}END{print sum;}' ${SAMPLE}_2.fastq`
RAWSAMPLE_SZE=`awk "BEGIN {print ${RAWREAD_SZE1} + ${RAWREAD_SZE2}}"`
echo "Raw read sample size: ${RAWSAMPLE_SZE} bp" >> ${SAMPLE}.stats


TRMREAD_NB1=`wc -l ${SAMPLE}_1_val_1.fq|cut -d' ' -f1`
TRMREAD_NB2=`wc -l ${SAMPLE}_2_val_2.fq|cut -d' ' -f1`
TRMREAD_NB=`awk "BEGIN {print ${TRMREAD_NB1}/4+${TRMREAD_NB2}/4}"`
echo "Number of trimmed reads: ${TRMREAD_NB} (sum of left and right reads)" >> ${SAMPLE}.stats

TRMREAD_LGTH1=`awk 'NR==9' FastQC/${SAMPLE}_1_val_1_fastqc/fastqc_data.txt | awk -F" " '{print $3}'`
TRMREAD_LGTH2=`awk 'NR==9' FastQC/${SAMPLE}_2_val_2_fastqc/fastqc_data.txt | awk -F" " '{print $3}'`
echo "Trimmed read length range (per FastQC report): ${TRMREAD_LGTH1} (left reads), ${TRMREAD_LGTH2} (right reads)" >> ${SAMPLE}.stats
TRMREAD_ML1=`cat ${SAMPLE}_1_val_1.fq | awk '{if(NR%4==2) print length($1)}' > /tmp/${SAMPLE}_readlength1.txt; sort -n /tmp/${SAMPLE}_readlength1.txt| awk ' { a[i++]=$1; } END { print a[int(i/2)]; }'`
TRMREAD_ML2=`cat ${SAMPLE}_2_val_2.fq | awk '{if(NR%4==2) print length($1)}' > /tmp/${SAMPLE}_readlength2.txt; sort -n /tmp/${SAMPLE}_readlength2.txt| awk ' { a[i++]=$1; } END { print a[int(i/2)]; }'`
echo "Median length of trimmed reads: ${TRMREAD_ML1} (left reads), ${TRMREAD_ML2} (right reads)" >> ${SAMPLE}.stats

TRMREAD_SZE1=`awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length($0);}}END{print sum;}' ${SAMPLE}_1_val_1.fq`
TRMREAD_SZE2=`awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length($0);}}END{print sum;}' ${SAMPLE}_2_val_2.fq`
TRMSAMPLE_SZE=`awk "BEGIN {print ${TRMREAD_SZE1} + ${TRMREAD_SZE2}}"`
echo "Trimmed sample size: ${TRMSAMPLE_SZE} bp" >> ${SAMPLE}.stats

TOTAL_ALGNDBASE_CNT=`samtools depth ${SYNONYM}.bam | awk '{sum+=$3}END{print sum}'`
genome_size=`awk 'NR==1{print $4}' ${GENOME}.stats`
COVERAGE=`awk "BEGIN {printf \"%.2f\", ${TOTAL_ALGNDBASE_CNT}/${genome_size} }"`
echo "Genome coverage: ${COVERAGE} (= ${TOTAL_ALGNDBASE_CNT} / ${genome_size})" >> ${SAMPLE}.stats
