#!/usr/bin/env python3

from argparse import ArgumentParser
from pathlib import Path
from zipfile import ZipFile
import sys


parser = ArgumentParser(description='Merges replicate Creport files from all subdirectories')
parser.add_argument('-o', '--outfile', help='output file name')
args=parser.parse_args()

# look for plaintext Creport files
creports = [open(f, 'rb') for f in Path().glob('*/*.Creport')]

# look for Creport files in zips
for zipfilepath in list(Path().glob('*/*.zip')) :
    zipfile = ZipFile(zipfilepath)
    for filename in zipfile.namelist() :
        if filename[-8:]=='.Creport' :
            creports.append(zipfile.open(filename))
            break
print("Merging {} replicates from files:".format(len(creports)))
for creport in creports :
    print (creport.name)
print("Writing into {}.Creport".format(args.outfile))
sys.stdout.flush()

with open(args.outfile + '.Creport', 'w') as outfile :

    for lines in  zip(*creports) :
        lines = [line.decode('ascii').strip().split('\t') for line in lines]
        chromosome = lines[0][0]
        position = int(lines[0][1])
        strand = lines[0][2]
        count_c = int(lines[0][3])
        count_t = int(lines[0][4])
        c_context = lines[0][5]
        tri_context = lines[0][6]

        for line in lines[1:] :
            # asserting Creport files are compatible
            assert line[0] == chromosome
            assert int(line[1]) == position
            assert line[2] == strand

            count_c += int(line[3])
            count_t += int(line[4])

        outfile.write('{}\t{}\t{}\t{}\t{}\t{}\t{}\n'.format(chromosome, position, strand, count_c, count_t, c_context, tri_context ))

print ("Creport merge complete.")
