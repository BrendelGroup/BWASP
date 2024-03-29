## Suggested data directory structure and workflow execution plans for (large-scale) BWASP analyses

The [BWASP HOWTO](../HOWTO.md) illustrates a typical use case scenario for analyzing a BS-seq experiment with multiple replicates for a specific sample.
The initial workflow steps will take downloaded or users-supplied BS-seq reads, go through various filtering steps for data quality control, then map the reads to the genome, and call methylation status.
Statistical criteria are applied to identify _highly supported methylation_ (hsm) sites.

A common experiment involves multiple samples and replicates.
In typical BWASP usage, replicate are analyzed separately before results from the replicates are merged for each sample to provide an aggregate view of methylation status for this condition.
Keeping track of the various data sets and stages of analysis can be greatly facilitated by an appropriate directory structure to run the analyses and store the results.

An appropriate directory structure for such scenario can be generated with the _xmkdirstr_ script in this directory.
We next provide a usage example.
Once you are familiar with the general idea, take a look at the __The next level of automation__ section below, which describes how we manage large-scale integrative projects.

#### Example:

```
xmkdirstr myspecies study1 sample1 3 p
```

will generate the following directory structure:

```
myspecies:
genome	study1

myspecies/genome:
Makefile

myspecies/study1:
sample1

myspecies/study1/sample1:
Makefile  replicate1  replicate2  replicate3

myspecies/study1/sample1/replicate1:
genome	Makefile

myspecies/study1/sample1/replicate2:
genome	Makefile

myspecies/study1/sample1/replicate3:
genome	Makefile
```

The above assumes that _sample1_ in _study1_ has 3 replicates.
To add directories for _sample2_ with 2 replicates, run the following command next:

```
xmkdirstr myspecies study1 sample2 2 s
```

giving overall:

```
myspecies:
genome	study1

myspecies/genome:
Makefile

myspecies/study1:
sample1  sample2

myspecies/study1/sample1:
Makefile  replicate1  replicate2  replicate3

myspecies/study1/sample1/replicate1:
genome	Makefile

myspecies/study1/sample1/replicate2:
genome	Makefile

myspecies/study1/sample1/replicate3:
genome  Makefile

myspecies/study1/sample2:
Makefile  replicate1  replicate2

myspecies/study1/sample2/replicate1:
genome  Makefile

myspecies/study1/sample2/replicate2:
genome  Makefile
```

#### Comments:
1. The _genome_ directory is expected by the [Bismark](http://www.bioinformatics.babraham.ac.uk/projects/bismark/)
software.
You should deposit the genome assembly of _myspecies_ into the _genome_ directory as &lt;species\_label&gt;.gdna.fa (and no other \*.fa files).

2. Template _makefiles_ were copied into the _sample_ and _replicate_ directories.
The _p_ argument in the first invocation of the _xmkdirstr_ command was used to indicate that _sample1_ replicates comprise paired-end read data, wheres the _s_ argument in the second command invocation was used to copy the template _makefile_ for
single-read data analysis.
The _sample_ directories have the _Makefile_ template for merging replicate data.

3. Obviously, you will need to edit the _makefile_ templates appropriate to your needs, but then you should be good to go.
The _makefile_ templates are from the [../makefiles/ directory](../makefiles).
Instructions on how to modify the _makefiles_ are provided as comments in the files.

4. In particular, __make sure that your computer has enough resources__ to do what is asked in the _makefiles_.
Execute some test runs and monitor CPU, memory, and disk usage.


## Adding the data

The workflow assumes that each replicate (or single sample) directory either contains the BS-seq read files or that the _Makefile_ specifies the NCBI SRA accession number for the reads.
In the latter case, _make_ will first download the read data before proceeding with read quality control and mapping.
What to do when you want to analyze your own pre-publication data, fresh off the sequencer?
Easy enough: just put the read files into the same directory and edit the _Makefile_ appropriately.

For example, assume that your sequencing facility provided you with two files _FacilityIDsampleXrunY.1.fq_ and _FacilityIDsampleXrunY.2.fq_ for a paired-read expriment on your sample _queen-brain_, and this was replicate 1.
Then you could save the first file as _sampleXrunY\_1.fastq_ and the second file as _sampleXrunY\_2.fastq_ and set in the _Makefile_:

```bash
SAMPLE  = sampleXrunY
SYNONYM = queen-brain-1
```

instead of the template values, and you are good to go.
__Please note that the programs assume read file endings of _\_1.fastq_ and _\_2.fastq_ for paired-end reads and _.fastq_ for single-end reads.__


## The next level of automation: Using config files to produce the data directory structure and machine-specific execution scripts

As discussed above, a BWASP project involves preparing the relevant genome data files; setting up a directory structure to analyze the samples and replicates of selected studies; and defining appropriate parameters to match your available computing resources.
If you only have one experiment to analyze, the instructions in the previous section should suffice.
But if you have multiple experiments, or want to compare with external data sets, or in some other way find yourself to be a repeat user, then you surely would appreciate more automation, without having to do a lot of typing.
Enter the script [xsetup](./xsetup) in this directory.
_xsetup_ takes as input the following configuration files:

```bash
./machines_cfgdir/<machine>.conf
./species_cfgdir/<species>.conf
./studies_cfgdir/<study>.conf
```

_\<machine>.conf_ is where you change the default parameters in BWASP makefiles (e.g., number of processors and size of memory to use for the various programs).
_\<species>.conf_ contains the instructions to download the relevant genome sequence and annotation files.
_\<study\>.conf_ details the scope of the _study_: samples, number of replicates.
You may supply multiple _\<study\>.conf_ files.

#### Example:

```
./xsetup -m bggnomic -s Amel  Li-Byarlay2013 Herb2012
```

would set up a directory structure and scripts to analyze two studies of BS-seq in _Apis mellifera_ on a machine configured as _bggnomic_.

Here, _machines\_cfgdir/bgggnomic.conf_ is
```bash
#Offset
#
OFFSET=30m

#Makefile options:
#
SAVESPACE = true

# Options for programs called in the BWASP workflow:
#
BOWTIE2_OPTIONS       = -p 2  --score_min L,0,-0.6
BISMARK_OPTIONS       = --multicore 8  --bowtie2 $(BOWTIE2_OPTIONS)
FASTQC_OPTIONS        = --threads 8  --extract
SAMTOOLS_SORT_OPTIONS = -m 10G  -@ 6
TRIM_GALORE_OPTIONS   = --cores 4
SORT_BUFFER_SIZE      = 20G
BME_OPTIONS           = --multicore 8  --buffer_size $(SORT_BUFFER_SIZE)
MFILTER_NUMPRC        = 4

```

_species\_cfgdir/Amel.conf_ is

```bash
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/254/395/GCF_003254395.2_Amel_HAv3.1/GCF_003254395.2_Amel_HAv3.1_genomic.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/254/395/GCF_003254395.2_Amel_HAv3.1/GCF_003254395.2_Amel_HAv3.1_genomic.gff.gz
gunzip GCF*
ln -s GCF_003254395.2_Amel_HAv3.1_genomic.fna Amel.gdna.fa
ln -s GCF_003254395.2_Amel_HAv3.1_genomic.gff Amel.gff
```

_./studies\_cfgdir/Li-Byarlay2013.conf_ is

```bash
SPECIES=Amel
GENOME=Amel.gdna
STUDY=Li-Byarlay2013 # https://doi.org/10.1073/pnas.1310735110
SAMPLES=( control knockdown )
NREPS=( 1 1 )
PORS=( s s )
SRAID=( SRR1270128 SRR1270129 )
```

and _./studies\_cfgdir/Herb2012.conf_ is

```bash
SPECIES=Amel
GENOME=Amel.gdna
STUDY=Herb2012 # https://doi.org/10.1038/nn.3218
SAMPLES=( forager queen reverted_nurse worker )
NREPS=( 6 5 6 5 )
PORS=( p p p p )
SRAID=( SRR445773 SRR445771 SRR445770 SRR445769 SRR445768 SRR445767 \
        SRR445800 SRR445801 SRR445802 SRR445803 SRR445804 \
        SRR445799 SRR445778 SRR445777 SRR445776 SRR445775 SRR445774 \
        SRR445805 SRR445806 SRR445807 SRR445808 SRR445809 \
      )
```

What does this all mean?
First, we are planning to run things on a machine presumably called _bggnomic_, which must have considerable resources: each Bismark run will use 8 cores for _bowtie2_ with 2 processors each (i.e., 16 threads in total).
Different replicate analyses will be launched after a 30m (_OFFSET_) waiting period (which may still allow for two replicates to run _bowtie2_ simultaneously, so _bggnomic_ better be big enough to handle this for some time),

Second, the _Amel.conf_ file provides instructions on where from to pull the genome sequence and annotation files.

Third, the _study.conf_ files tell us the accession numbers for the raw data to be pulled from [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra), how many replicates there are per sample (and how the samples are labeled), and whether the read data are paired-end or single (_PORS_).

The command will generate a directory structure _Amel_ and also deposit execution scripts _xdoitLi-Byarlay2013_ and _xdoitHerb2012_ (as well as scripts _xgetdLi-Byarlay2013_ and _xgetdHerb2012_, see Comment 5 below).
The former is pasted below.
It's a _bash_ script that executes the entire workflow.
Too good to be true?
Try something like this:

```_bash_
singularity exec -e bwasp.simg  ./xdoitLi-Byarlay2013
```

and walk away until everything is done (make sure you have put the _Amel_ directory structure and the _xdoit_ script on a disk with plenty of free disk space ...).

_xdoit_Li-Byarlay2013_ script:

```bash
#!/bin/bash
#

date
echo "Parsing the genome annotation ..."
cd Amel/genome
make >& err
cd ..
echo "  done with genome annotation parsing ..."
date
cd Li-Byarlay2013
cd control
if [[ -d replicate1 ]]; then
  if [[ ! -f replicate1/errBSG ]]; then
    echo "Bismark genome preparation ..."
    cd replicate1
    make Bisulfite_Genome >& errBSG
    cd ../..
    echo "  done with Bismark genome preparation ..."
  fi
else
  if [[ ! -f errBSG ]]; then
    echo "Bismark genome preparation ..."
    make Bisulfite_Genome >& errBSG
    cd ..
    echo "  done with Bismark genome preparation ..."
  fi
fi

echo "... starting on control"
cd control
time make -j 4 >& err &
sleep 30m
cd ..
cd knockdown

echo "... starting on knockdown"
cd knockdown
time make -j 4 >& err &
sleep 30m
cd ..
cd ../..
date
echo "All done!"
```


#### Comments:
1. Configuration files we have used are in the _*.cfgdir_ directories.

2. Going back to the first example, how would we set up the _Patalano et al._ (2015) analysis?
Right, with default settings (not recommended; you __should__ think about parameters) it would be as simple as this:

```bash
./xsetup -s Pcan  Patalano2015
```

3. In some studies, biological samples were split and run on different sequencer lanes.
These are recorded at NCBI SRA as different _runs_.
In such case, the run data should be combined to reflect the entirety of the biological sample.
This is important, for example, for removal of PCR duplicates.
[xgetSRAacc](../bin/xgetSRAacc) creates such combined read sets if the constituent SRA accessions are separated by \_ instead of a space in the  studies configuration file.
For example,

```bash_
SPECIES=Amel
GENOME=Amel.gdna
STUDY=Feng2010  # https://doi.org/10.1073/pnas.1002720107
SAMPLES=( immature_male )
NREPS=( 1 )
PORS=( s )
SRAID=( SRR039327_SRR039328 \
      )
```

indicates that accessions _SRR039327_ and _SRR39328_ will be combined before analysis.
Note that the configuration file correctly states that the study involved only one replicate.

4. The alert reader will have noticed that the use of the _PORS_ variable implicitly assumes that all replicates are of the same type, either paired-end or single reads.
This would seem to be a reasonable assumption, but in practice, exceptions may occur.
To account for such cases, _xsetup_ will print the content of the _EXCEPTIONS_ variable, if provided in the studies configuration file.
For example, [Harris2019.conf](./studies_cfgdir/Amel/Harris2019.conf) indicates that

```bash
SPECIES=Amel
GENOME=Amel.gdna
STUDY=Harris2019 # https://doi.org/10.1186/s13072-019-0307-4
SAMPLES=( drone_head drone_larva drone_sperm queen_head worker_embryo worker_head worker_pupa )
NREPS=( 2 2 2 2 2 2 2 )
PORS=( s s s s s s s )
SRAID=( SRR7472342 SRR7472349 \
        SRR7472339_SRR7472340_SRR7472341 SRR7472348 \
        SRR7472329_SRR7472330 SRR9077639 \
        SRR7472343 SRR7472350 \
        SRR7472331_SRR7472332 SRR7472344 \
        SRR7472337_SRR7472338 SRR7472347 \
        SRR7472335_SRR7472336 SRR7472346 \
      )
EXCEPTIONS="SRR9077639 is paired-end"
```

run _SRR9077639_ was paired-end.
Thus the _Makefile_ generated by _xsetup_ would lead to an error - expecting a single read experiment, rather than paired-end data.
For such rare instances, we suggest to save a copy of the output of the first _xsetup_ execution, then change the _PORS_ variable for a second run, and then copy the correct _Makefile_ into the saved copy for final execution of the workflow script.

5. The one part of the workflow somewhat outside of your control is the download of public data from NCBI SRA.
For example, if you have internet connection problems, that might just stop the workflow right there, at the very first step.
Should that become a concern, you might want to execute the _xgetd\<STUDY\>_ script first.
This script calls up just the subset of _xdoit\<STUDY\>_ _make_ commands that pull the public data into your work space.
If you do this first and confirm that everything downloaded as prescribed, then you can proceed with _xdoit\<STUDY\>_ as before - _make_ will recognize that the data are already downloaded and proceed with the next workflow steps (that are completely local to your machine at this point).
