# HOWTO BWASP

## Requirements

  * BWASP can run on any platform that can run Singularity (Linux, MacOS, Windows), although it is only tested on Linux.
 These instructions are therefore for Linux but they should apply to MacOS without much modification.
  * BWASP can run on a single processor, although it is intended to run on several cores.
  * Furthermore, BWASP requires a considerable amount of memory (>16 GB) and scratch space (>500 GB).

## Installation

Assuming we have Git and  Singularity installed on the system, we can get the BWASP code from GitHub and the container from the
[Singularity Hub](https://www.singularity-hub.org/collections/763) by doing :

```bash
git clone https://github.com/brendelgroup/BWASP.git
cd BWASP
singularity pull shub://littleblackfish/BWASP
source bin/bwasp_env.sh
```

Sourcing `bwasp_env.sh` sets up some environment variables such as `BWASP_ROOT`, `BWASP_DATA`,
but most importantly `BWASP_EXEC` which is the master Singularity command we use to run the workflow.
Although it may not be necessary, it is recommended to source this script before every run to make sure these variables are in place.

## Directory structure

BWASP expects a certain directory structure starting from the `BWASP_ROOT/data` directory (`BWASP_DATA`).

  * BWASP_DATA/
    * species/
      * genome/
      * study/
        * caste/
          * replicate/

This hierarchy is designed to organize various data sets.
Although not mandatory, it is recommended to follow it for easier operation.
The [xmkdirstr](data/xmkdirstr) script helps create this structure and populates it with the relevant links and Makefiles for each sample.
Please note that Makefiles for each sample need to be modified prior to running the workflow.

## Example run

To demonstrate how to work with BWASP, we will re-analyze the BS-seq data from the [Patalano _et al._, 2015,](https://doi.org/10.1073/pnas.1515937112) study of the paper wasp _Polistes canadensis_.
This should serve to familiarize the new user with how BWASP is intended to be utilized.


We start by preparing the directory structure :

```bash
cd data
./xmkdirstr Pcan Patalano2015 Queen 3 p
```

**Pcan** is an alias for _Polistes canadensis_ and might hold several studies on this species, the **Patalano2015** study being one example.
Under _Patalano2015_, the subdirectory **Queen** will contain **3** _replicates_ of **p** aired-end reads from queens.
Each _replicate_ subdirectory, will be populated with a link to the _genome_ directory and a copy of _Makefile_\__pe_\__template_.

### Getting the genome

BWASP workflow requires a reference genome, so we need to obtain and place it in the appropriate directory.
The _Polistes canadensis_ genome can be found at the appropriate [NCBI Genome page](https://www.ncbi.nlm.nih.gov/genome/16494).

We can simply get the direct download links for the genome assembly (FASTA) and annotation (GFF) files to download them directly into the `Pcan/genome` directory.

```bash
cd Pcan/genome
wget  ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/313/835/GCF_001313835.1_ASM131383v1/GCF_001313835.1_ASM131383v1_genomic.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/313/835/GCF_001313835.1_ASM131383v1/GCF_001313835.1_ASM131383v1_genomic.gff.gz
```

Assuming everything was downloaded nicely, we decompress and link the files to more convenient file names:

```bash
gunzip GCF_*.gz
ln GCF_001313835.1_ASM131383v1_genomic.fna Pcan.gdna.fa
ln GCF_001313835.1_ASM131383v1_genomic.gff Pcan.gff3
```
Note that the annotation was not necessary for the basic BWASP run but we downloaded it anyways for use in downstream analysis.
Also note that we preferred linking the files to moving (renaming) them to keep the original filenames for future reference.

### Getting the reads

Note that the appropriate template *Makefile* was copied into each replicate directory.
This *Makefile* contains the necessary commands (fastq-dump) to download reads from the [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra) so all we need to do is to fill in the accession numbers.

Three sets of BS-seq reads from queen adult brains were deposited in the NCBI Short Read Archive:

* [SRR1519132 21Q](http://www.ncbi.nlm.nih.gov/sra/SRX656317)
* [SRR1519133 43Q](http://www.ncbi.nlm.nih.gov/sra/SRX656318)
* [SRR1519134 75Q](http://www.ncbi.nlm.nih.gov/sra/SRX656319)


For our example, the template _Makefile_ already has the accession number for the first queen replicate.
We should manually edit numbers for the other two replicates.

The commands below simply replace the SRA accession numbers and sample labels for the other two replicates:

```bash
sed -i -e "s/SRR1519132/SRR1519133/; s/Pcan-21Q/Pcan-43Q/;" replicate2/Makefile
sed -i -e "s/SRR1519132/SRR1519134/; s/Pcan-21Q/Pcan-75Q/;" replicate3/Makefile
```

Now we are ready to start the heavy data processing.

### Running the workflow

Since the rest of the workflow is fire and forget, proofreading of the *Makefile*s is highly recommended at this point.
The section titled **Variable Settings** is the only part that is necessarily modified, and should be double checked before proceeding.

Once that is done, it is recommended to source the `bwasp_env.sh` (as per installation instructions) and confirming that the `BWASP_EXEC` variable is set by checking the output of `echo $BWASP_EXEC`.
This is merely a convenience variable that holds a command that has all the relevant Singularity parameters set for the user.
An exemplary BWASP_EXEC looks like :

```
singularity exec -e -c -B /N/dc2/scratch/muroztur/BWASP/data /N/dc2/scratch/muroztur/BWASP/bwasp.simg
```

Finally, we can run the workflow as follows (from directory _replicateX_):

```bash
$BWASP_EXEC make -n
$BWASP_EXEC make Bisulfite_Genome
$BWASP_EXEC make &> bwasp.log
```

The preceding `$BWASP_EXEC` makes sure that `make` runs from inside the Singularity container,
where we made sure all the moving parts are in working condition (i.e. all required binaries are in correct version and path).
Although it is possible to set up and use BWASP natively, this is not recommended nor supported.


The first *make* command with the -n flag simply shows what _make_ will do and is valuable for reference.
The second _make_ command runs the preparatory genome processing step which needs to be done once and is shared for all samples of a given species.
The third _make_ command will run the main workflow.

Once the the common _bismark_\__genome_\__preparation_ step is done, you
could start _make_ in the other _replicate_ directories - however, we strongly
suggest you finish one run first to make sure that everything works and you
have enough resources on your computer to run multiple __BWASP__ workflows
simultaneously.  Check the _err_ file and your system monitor frequently.


### Output

After completion of the BWASP workflow, the working directory should contain a
fair number of output files.  Please refer to the documentation of the various
constituent programs for details as well as our
[manuscript](http://brendelgroup.org/research/publications.php).
To remove unneeded intermediate files and archive files that may be of
interest later but are not needed in subsequent __BWASP__ analysis steps
we recommend running the following commands at this stage:

```bash
$BWASP_EXEC make cleanup
$BWASP_EXEC make finishup
```

This will crate the archive _STORE-SRR1519132.zip_ and substantially reduce
the disk space used.  The remaining output files should be as follows:

#### Methylation calls and statistics
* Pcan-21Q.mstats
* Pcan-21Q.CHGhsm.mcalls Pcan-21Q.CHGnsm.mcalls Pcan-21Q.CHGscd.mcalls
* Pcan-21Q.CHHhsm.mcalls Pcan-21Q.CHHnsm.mcalls Pcan-21Q.CHHscd.mcalls
* Pcan-21Q.CpGhsm.mcalls Pcan-21Q.CpGnsm.mcalls Pcan-21Q.CpGscd.mcalls
* Pcan-21Q.HSMthresholds

<!-- -->

- SRR1519132.stats

#### Read preparation, mapping, and quality reports
* SRR1519132.stats
* Pcan-21Q.bam
* Pcan-21Q_splitting_report.txt
* CpG_OT_Pcan-21Q.txt
* CpG_OB_Pcan-21Q.txt

<!-- -->

- Pcan-21Q.M-bias.eval
- Pcan-21Q_mbias_only_splitting_report.txt
- Pcan-21Q.M-bias_R1.png
- Pcan-21Q.M-bias_R2.png
- Pcan-21Q.M-bias.txt

<!-- -->

* FilterMsam-Report-Pcan-21Q-deduplicated
* Rejected-Reads10-Pcan-21Q-deduplicated.sam
* Rejected-Reads01-Pcan-21Q-deduplicated.sam
* Rejected-Reads11-Pcan-21Q-deduplicated.sam

<!-- -->

- SRR1519132_1_val_1.fq_bismark_bt2_pe.deduplication_report.txt
- SRR1519132_1_val_1.fq_bismark_bt2_PE_report.txt
- FastQC/
- SRR1519132_2.fastq_trimming_report.txt
- SRR1519132_1.fastq_trimming_report.txt

#### Genome statistics
* Pcan.gdna.stats

Take a look and explore.  The _.stats_ and _report_ files would be good
starting points.


### Merging data from multiple replicates
While it is of interest to look at the methylation statistics across
different replicate data sets, typically the replicate data are pooled when
comparing between samples/conditions (_e.g._, Queen versus Worker samples).


BWASP provides an additional makefile to merge replicates and provide cumulative statistics over all replicates.
The _xmkdirstr_ script in our example already set this up for us in the _Queen_ directory.
We only need to fill in the label (Pcan-queen) and run (from directory  _Queen_):

```bash
$BWASP_EXEC make
```

Optionally followed by _cleanup_ and _finishup_ targets here as well:

```bash
$BWASP_EXEC make cleanup
$BWASP_EXEC make finishup
```

Leaving us with

#### Combined methylation calls and statistics
* Pcan-queen.mstats
* Pcan-queen.CHGhsm.mcalls Pcan-queen.CHGnsm.mcalls Pcan-queen.CHGscd.mcalls
* Pcan-queen.CHHhsm.mcalls Pcan-queen.CHHnsm.mcalls Pcan-queen.CHHscd.mcalls
* Pcan-queen.CpGhsm.mcalls Pcan-queen.CpGnsm.mcalls Pcan-queen.CpGscd.mcalls
* Pcan-queen.HSMthresholds
