#!/bin/sh
#
#BWASP script mstats.sh
#
# This script takes the BWASP output files *.mcalls and *.Creport and 
# summarizes the output statistics in file *.mstats.

echo "Sample: $1"
echo ""

context=(CpG CHG CHH)
pattern=(CG CHG CHH)
coverage=(0 1 2 5 10 20)
site=(scd hsm nsm)

cl=${#context[@]}
vl=${#coverage[@]}
declare -a vnbr
sl=${#site[@]}
declare -a snbr

i=-1

for c in ${context[@]}; do
  ((i++))

  j=-1
  file=$1.${c}report
  for s in ${coverage[@]}; do
    ((j++))
    if [ "$s" = "0" ]; then
      n=`tail -n +2 $file | awk '$4 == 0' | wc -l`
    else
      n=`tail -n +2 $file | awk -v t=$s '$4 >= t' | wc -l`
    fi
    a=$(($vl*$i+$j))
    vnbr[$a]=$n
  done

  j=-1
  for s in ${site[@]}; do
    ((j++))
    file=$1.$c$s.mcalls
    n=`cat $file | wc -l`
    ((n=n-1))
    a=$(($sl*$i+$j))
    snbr[$a]=$n
  done
done


file=$1.Creport
echo "File: $file"
echo ""

awk -v cxt="${context[*]}" -v pat="${pattern[*]}" -v ctl="$cl"   -v vrg="${coverage[*]}" -v vgl="$vl" -v vnbr="${vnbr[*]}"   -v ste="${site[*]}" -v stl="$sl" -v snbr="${snbr[*]}" < $file '
	BEGIN{
		split(cxt,c," "); split(pat,p," "); split(vrg,v," "); split(vnbr,m," "); split(ste,s," "); split(snbr,n," ");
	 	for (i=1; i<=ctl; i++) {nSites[i]= sumC[i]= sumT[i]= 0;}
	}
	{
		for (i=1; i<=ctl; i++) {
			if ($6 == p[i]) {nSites[i]+=1; sumC[i]+=$4; sumT[i]+=$5;}
		}
	}
	END{
		tSites= 0;
		for (i=1; i<=ctl; i++) {
			tSites+= nSites[i];
			tsumC+= sumC[i];
			tsumT+= sumT[i];
		}
        	printf "\nCoverage of C sites (number of reads mapped):\n";
 		printf "  Total number of Cs: %9d\n\n", tSites;
		for (i=1; i<=ctl; i++) {
			printf "  %s %8d (%6.2f%% of all C)\n", c[i], nSites[i], 100.*nSites[i]/tSites;
 				printf "\t%s n == %s\t%8d (%6.2f%% of all %s)\n", c[i], v[1], m[(i-1)*vgl+1], 100.*m[(i-1)*vgl+1]/nSites[i], c[i];
			for (j=2; j<=vgl; j++) {
 				printf "\t%s n >= %s\t%8d (%6.2f%% of all %s)\n", c[i], v[j], m[(i-1)*vgl+j], 100.*m[(i-1)*vgl+j]/nSites[i], c[i];
			}
			printf "\n";
		}

        	printf "\nOverall level of methylation (percent reads reporting conversion or non-conversion):\n";
		for (i=1; i<=ctl; i++) {
			printf "  %s (%6.2f%% of genomic Cs): %6.2f (PrcntM) %6.2f (PrcntU)\n", c[i], 100.*nSites[i]/tSites, 100.*sumC[i]/(sumC[i]+sumT[i]), 100.*sumT[i]/(sumC[i]+sumT[i]);
		}
			printf "  C   (all contexts         ): %6.2f (PrcntM) %6.2f (PrcntU)\n", 100.*tsumC/(tsumC+tsumT), 100.*tsumT/(tsumC+tsumT);
		printf "\n";

		printf "\nNumber of sites:\n"
		for (i=1; i<=ctl; i++) {
			printf "  %s %8d (%6.2f%% of all C)", c[i], nSites[i], 100.*nSites[i]/tSites;
 			printf "\t%s%s\t%8d (%6.2f%% of all %s)", c[i], s[1], n[(i-1)*stl+1], 100.*n[(i-1)*stl+1]/nSites[i], c[i];
			for (j=2; j<=stl; j++) {
 				printf "\t%s%s\t%8d (%6.2f%% of all %s%s)", c[i], s[j], n[(i-1)*stl+j], 100.*n[(i-1)*stl+j]/n[(i-1)*stl+1], c[i], s[1];
			}
			printf "\n";
		}
	}
'
