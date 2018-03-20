#!/usr/bin/env python

#
#BWASP python script Creport2CXreport.py
#
# This script takes a sorted creport file (output from Bismark script coverage2cytosine)
# and splits it into the *.CpGreport, *.CHGreport, and *.CHHreport files.  It also
# produces the *.HSMthresholds file, which records the BWASP rationale for determining
# the minimal coverage of a site to be dectectable as a "highly supported methylation"
# (hsm) site.
#
import decimal
import math
import re
import scipy.stats
import sys

def minNval (coverage, label):
  unique_n = []
  unique_n = list(set(coverage))
  unique_n = map(int,unique_n)
  unique_n.sort()

  print '\n\nFinding the minimal coverage required to potentially observe significant failed C->T conversion counts ...\n'

  for n in range (0,len(unique_n)):
      breakFlag = 0
      S_n = t = 0
      for m in range (0,len(coverage)):
          if int(coverage[m]) >= unique_n[n]:
             S_n += 1
      t = 0.01/S_n
      for m in range(1,int(unique_n[n]+1)):
          if 1-scipy.stats.binom.cdf(m-1,int(unique_n[n]),0.005) <= t :
             breakFlag = 1
             print 'For coverage n=' + str(unique_n[n]) + ', there are', S_n, label, 'sites.'
             print 'The Bonferroni adjusted 1% significance probability threshold is t = 0.01 /', S_n, '=', t, '.'
             print 'The cumulative upper tail of the binomial distribution for', unique_n[n], 'trials, success probability 0.005, and >=', m, 'successes is', 1-scipy.stats.binom.cdf(m-1,int(unique_n[n]),0.005), '.'
             print 'Thus, the minimum coverage of', label, 'sites required to potentially observe significant failed C->T conversion counts is: ' + str(unique_n[n])
             break
      if breakFlag == 1:
         break


infile = open(sys.argv[1], 'rb')
fileCpG = open(sys.argv[2], 'w')
fileCHG = open(sys.argv[3], 'w')
fileCHH = open(sys.argv[4], 'w')

fileCpG.write("SequenceID" + '\t' + "Position" + '\t' + "Strand" + '\t' + "Coverage" + '\t' + "Count_C" + '\t' + "Count_T" +'\n')
fileCHG.write("SequenceID" + '\t' + "Position" + '\t' + "Strand" + '\t' + "Coverage" + '\t' + "Count_C" + '\t' + "Count_T" +'\n')
fileCHH.write("SequenceID" + '\t' + "Position" + '\t' + "Strand" + '\t' + "Coverage" + '\t' + "Count_C" + '\t' + "Count_T" +'\n')

coverageCpG = []
coverageCHG = []
coverageCHH = []

with open(sys.argv[1], 'rb') as infile:
  for line in infile:
      output = ['N/A'] * 8;
      input = (line.rstrip('\n')).split("\t");

      coverage = int(input[3]) + int(input[4])
      if coverage <> 0:
          C_Freq = int(input[3])
          T_Freq = int(input[4])
      else:
          C_Freq = 0
          T_Freq = 0
      altrow =input[0].split('|')
      pattern=filter(None,altrow)
      lengthpattern= len(pattern)-1
      temp= (altrow[lengthpattern])
      output[0]=temp
      output[1]= input[1]
      if input[2] == '+':
          output[2] = "F"
      else:
          output[2] = "R"
      output[3] = str(coverage)
      output[4] = str(C_Freq)
      output[5] = str(T_Freq)
      output[6] = input[5]

      if output[6] == 'CG':
        fileCpG.writelines('\t'.join(output[0:6]) + '\n')
        coverageCpG.append(coverage)
      elif output[6] == 'CHG':
        fileCHG.writelines('\t'.join(output[0:6]) + '\n')
        coverageCHG.append(coverage)
      elif output[6] == 'CHH':
        fileCHH.writelines('\t'.join(output[0:6]) + '\n')
        coverageCHH.append(coverage)
      else:
        print "\nUnknown context: neither CG, nor CHG, nor CHH.  How can that be?  Please check.\n"
        exit()

fileCpG.close()
fileCHH.close()
fileCHG.close()
minNval(coverageCpG,'CpG')
minNval(coverageCHG,'CHG')
minNval(coverageCHH,'CHH')
