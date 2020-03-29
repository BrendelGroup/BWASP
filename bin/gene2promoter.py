#!/usr/bin/env python

#BWASP python script gene2promoter.py
#
# This script is called by parse_gff3_input.sh to add "promoter"
# annotations to "gene" features in a GFF3 file.  The promoter
# region is simply set to 500 nucleotides upstream of the 5' gene
# boundary (or the sequence end if that comes first).
#
from collections import defaultdict
import csv
import decimal
import math
import numpy
import re
import string
import sys

chrName = []
source = []
feature = []
startPos = []
endPos = []
temp = []
strand = []
rgb = []
attribute = []

with open(sys.argv[1], 'rt') as inputa:
    linesa = inputa.readlines()
    for rowa in csv.reader(linesa, delimiter='\t'):
        if rowa[6] == '-':
            dummy = int(rowa[4])
            rowa[3] = dummy + 1
            rowa[4] = dummy + 500

        elif rowa[6] == '+':
            dummy = int(rowa[3])
            rowa[4] = dummy -1
            rowa[3] = dummy - 500

        if int(rowa[3]) <= 0:
            rowa[3] = 1

        chrName.append(rowa[0])
        source.append(rowa[1])
        feature.append(rowa[2])
        startPos.append(rowa[3])
        endPos.append(rowa[4])
        temp.append(rowa[5])
        strand.append(rowa[6])
        rgb.append(rowa[7])
        attribute.append(rowa[8])


seqLengthChrName = []
seqLengtheEndPos = []


with open(sys.argv[2], 'rt') as infile1:
    for line in infile1:
        if line[0]=='>' :
            row = (line.rstrip('\n')).split()
            altrow= row[0].split('|')
            pattern=filter(None,altrow)
            lengthpattern= len(list(pattern))-1

            if altrow[lengthpattern][0] == '>':
                alteredChrName = altrow[lengthpattern][1:]
                seqLengthChrName.append(alteredChrName)
            else:
                seqLengthChrName.append(altrow[lengthpattern])
        else:
            length = (line.rstrip('\n')).split()
            if len(length) == 1:
                seqLengtheEndPos.append(int(length[0]))
#  print seqLengthChrName
infile1.close()

chrEndPos_dict = dict(zip(seqLengthChrName,seqLengtheEndPos))

correctedPromotersFile = open(sys.argv[3], 'w')

for i in range (0,len(chrName)):
    if chrName[i] in chrEndPos_dict:
        actualSeqLength = chrEndPos_dict.get(chrName[i])
        if actualSeqLength < int(endPos[i]):
            endPos[i] = actualSeqLength

        if endPos[i] > 0:
            correctedPromotersFile.write(chrName[i] + '\t' + source[i] + '\t' + 'promoter' + '\t' + str(startPos[i]) + '\t' + str(endPos[i])  + '\t' +  temp[i]  + '\t' + strand[i]  + '\t' + rgb[i]  + '\t' + attribute[i] +'\n')

correctedPromotersFile.close()
