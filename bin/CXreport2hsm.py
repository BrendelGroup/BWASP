#
#BWASP python script CXreport2hsm.py
#
# This script takes the *.C??report and *.HSMthresholds files as
# input and generates the *.C??xxx.mcalls methylation call records;
# here xxx = scd gives the significantly covered sites; xxx = hsm
# gives the highly supported methylation sites; and xxx = nsm gives
# the sites with no significant methylation.
#
from collections import defaultdict
import decimal
import math
import scipy.stats
import sys

psites = []
unique_n = []
minnbs = []

minNval = int(sys.argv[2])

with open(sys.argv[1], 'rb') as infile:
  infile.readline()
  for line in infile:
      input = (line.rstrip('\n')).split("\t");
      if int(input[3]) >= minNval:
         psites.append(input[3])

S_n = len(psites)
t=0.01/S_n


unique_n = list(set(psites))
unique_n = map(int,unique_n)
unique_n.sort()
for n in range (0,len(unique_n)):
    for m in range(1,int(unique_n[n]+1)):
        if 1-scipy.stats.binom.cdf(m-1,int(unique_n[n]),0.005) <= t :
           minnbs.append(m)
           break

minnbs4unique_n = dict(zip(unique_n,minnbs))


scdFile = open(sys.argv[3],'w')
hsmFile = open(sys.argv[4], 'w')
nsmFile = open(sys.argv[5], 'w')

scdFile.write("SeqID.Pos" + '\t' + "SequenceID" + '\t' + "Position" + '\t' + "Strand" + '\t' + "Coverage" + '\t' + "Prcnt_Meth" +'\t'+ "Prcnt_Unmeth" +'\n')
hsmFile.write("SeqID.Pos" + '\t' + "SequenceID" + '\t' + "Position" + '\t' + "Strand" + '\t' + "Coverage" + '\t' + "Prcnt_Meth" +'\t'+ "Prcnt_Unmeth" +'\n')
nsmFile.write("SeqID.Pos" + '\t' + "SequenceID" + '\t' + "Position" + '\t' + "Strand" + '\t' + "Coverage" + '\t' + "Prcnt_Meth" +'\t'+ "Prcnt_Unmeth" +'\n')

with open(sys.argv[1], 'rb') as infile:
    infile.readline()
    for line in infile:
        line = line.replace('\r','')
        input = (line.rstrip('\n')).split("\t");
        if int(input[3]) in unique_n:
            if int(input[3]) <> 0:
                C_Freq = "{0:.2f}".format((float(input[4])/float(input[3]))*100)
                T_Freq = "{0:.2f}".format((float(input[5])/float(input[3]))*100)
            else:
                C_Freq = 0.0
                T_Freq = 0.0
            output = input[0]+'.'+input[1] + '\t' + input[0] + '\t' + input[1] + '\t' + input[2] + '\t' + input[3] + '\t' + str(C_Freq) + '\t' + str(T_Freq) + '\n'
            scdFile.writelines(output)
            if int(input[4])>= minnbs4unique_n.get(int(input[3])):
                hsmFile.writelines(output)
            else:
                nsmFile.writelines(output)

infile.close()
hsmFile.close()
nsmFile.close()
scdFile.close()
