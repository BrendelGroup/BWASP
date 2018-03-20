#!/usr/bin/env python

#
#BWASP python script eval_srmbias.py
#
# The script takes as input a *.M-bias.txt file (produced in the BWASP workflow
# by bismark_methylation_extractor with the --mbias_only option, identifies
# outlier positions, and recommends "ignore" and "maxrlgth" parameters for the
# subsequent bismark_methylation_extractor run.
#
# Parameters of choice below are: qfactor=1/4 (meaning that the terminal 1/4
# read positions are discarded when established the mean and standard deviation
# of methylation percentages) and sfactor=3 (meaning that positions with
# percentages exceeding the mean by 3 standard deviations get flagged).
#
# The script recommends to ignore consecutive terminal positions that are
# flagged in any C context.  The output summarizes the extent of the bias.
#
# This script works for single-read data.  For paired-read data, use
# eval_prmbias.py.
#
import csv
import decimal
import math
import numpy
import re
import sys

# Set parameters:
#
qfactor = 1.0/4.0
sfactor = 3.0
verbose = 0

# Initialize variables:
#
methvals=[]
bias=[]
m = {}
s = {}
sumM = {}
sumU = {}
cumcntM= 0
cumcntU= 0

# Open and read Mbias file:
#
input = open(sys.argv[1], 'r')
cline = re.compile('(\w+) context')
pline = re.compile('position')
data = re.compile('\d+\t\d+\t\d+')
line = input.readline()
if cline.match(line):
  mtch = cline.match(line)
  label = mtch.group(1)
  if verbose: print label

input.readline()
input.readline()
for line in input.readlines():
    if cline.match(line):
      start = int(qfactor * len(methvals))
      end   = int((1.0-qfactor) * len(methvals))
      if verbose: print len(methvals), start, end
      mean=numpy.mean(methvals[start:end])
      standard_deviation=numpy.std(methvals[start:end])
      m[label] = mean
      s[label] = standard_deviation
      sumM[label] = cumcntM
      sumU[label] = cumcntU
      if verbose: print "  mean = ", m[label], "std = ", s[label]
      if verbose: print "  cumcntM = ", cumcntM, "cumcntU = ", cumcntU

      methvals=[]
      cumcntM= 0
      cumcntU= 0
      mtch = cline.match(line)
      label = mtch.group(1)
      if verbose: print label
      continue
    if data.match(line):
      values = line.split('\t')
      methvals.append(float(values[3]))
      cumcntM+= int(values[1])
      cumcntU+= int(values[2])

#Last context:
start = int(qfactor * len(methvals))
end   = int((1.0-qfactor) * len(methvals))
if verbose: print len(methvals), start, end
mean=numpy.mean(methvals[start:end])
standard_deviation=numpy.std(methvals[start:end])
m[label] = mean
s[label] = standard_deviation
sumM[label] = cumcntM
sumU[label] = cumcntU
if verbose: print "  mean = ", m[label], "std = ", s[label]
if verbose: print "  cumcntM = ", cumcntM, "cumcntU = ", cumcntU
if verbose: print "\n\n"



# Now establishing range:
#
exclude=[0]
exclude=[0]
for i in range(len(methvals)):
  exclude.append(0)
print "Outlier positions:\n\n"

cumcntMv= []
cumcntUv= []
input = open(sys.argv[1], 'r')
line = input.readline()
if cline.match(line):
  i = 0
  mtch = cline.match(line)
  label = mtch.group(1)
  print label, m[label], s[label], "Acceptable range:", m[label]-sfactor*s[label], "-", m[label]+sfactor*s[label]

input.readline()
input.readline()
for line in input.readlines():
    if cline.match(line):
      mtch = cline.match(line)
      label = mtch.group(1)
      print label, m[label], s[label], "Acceptable range:", m[label]-sfactor*s[label], "-", m[label]+sfactor*s[label]
      i = 0
      continue
    if data.match(line):
      i += 1
      values = line.split('\t')
      if float(values[3]) < m[label] - sfactor * s[label] or float(values[3]) > m[label] + sfactor * s[label]:
        print line.rstrip(), "**"
        exclude[i] = 1

# Establish "ignore" parameters:
#
igf = 0
for i in range(len(methvals)):
  if exclude[i+1] == 1:
    igf += 1
  else:
    break;
igt = 0
for i in range(len(methvals)):
  if exclude[len(methvals)-i] == 1:
    igt += 1
  else:
    break;

print "\n\nRecommended bismark_methylation_extractor flags:\n"
print "--ignore", igf, "--maxrlgth", len(methvals)-igt, "\n"


print "\nRemoval of biased calls:\n"
cumcntM= 0
cumcntU= 0
input = open(sys.argv[1], 'r')
line = input.readline()
if cline.match(line):
  i = 0
  mtch = cline.match(line)
  label = mtch.group(1)

input.readline()
input.readline()
for line in input.readlines():
    if cline.match(line):
      print "{0:s} cntM= {1:7d} of {2:8d} ({3:6.2f}%)\tcntU= {4:8d} of {5:9d} ({6:6.2f}%)\tfor {7:2d} ignored positions of {8:3d} ({9:6.2f}%)".format(label, cumcntM, sumM[label], round(100.*float(cumcntM)/float(sumM[label]),2), cumcntU, sumU[label], round(100.*float(cumcntU)/float(sumU[label]),2), igf+igt, len(methvals), round(100.*float(igf+igt)/float(len(methvals)),2))
      mtch = cline.match(line)
      label = mtch.group(1)
      i = 0
      cumcntM= 0
      cumcntU= 0
      continue
    if data.match(line):
      i += 1
      values = line.split('\t')
      if (i<=igf or i>len(methvals)-igt):
        cumcntM+= int(values[1])
        cumcntU+= int(values[2])

print "{0:s} cntM= {1:7d} of {2:8d} ({3:6.2f}%)\tcntU= {4:8d} of {5:9d} ({6:6.2f}%)\tfor {7:2d} ignored positions of {8:3d} ({9:6.2f}%)".format(label, cumcntM, sumM[label], round(100.*float(cumcntM)/float(sumM[label]),2), cumcntU, sumU[label], round(100.*float(cumcntU)/float(sumU[label]),2), igf+igt, len(methvals), round(100.*float(igf+igt)/float(len(methvals)),2))
