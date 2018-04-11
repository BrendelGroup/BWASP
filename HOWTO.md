# TUTORIAL

In this tutorial we will re-analyze the BS-seq data from the [Patalano _et al._, 2015,](http://www.ncbi.nlm.nih.gov/pubmed/26483466) study of the paper wasp _Polistes canadensis_.
This should serve to familiarize the new user with how BWASP is intended to be utilized.

## Installation

Assuming we have Git and  Singularity installed on the system, we can pull the BWASP code from GitHub and the container from the
[Singularity Hub](https://www.singularity-hub.org/collections/763) by doing :

```bash
git clone https://github.com/littleblackfish/BWASP.git
cd BWASP
singularity pull --name bwasp.simg shub://littleblackfish/BWASP
```

This puts the container file in the project root where it is expected by the makefiles and effectively completes the installation.

## Directory structure

BWASP will work with a certain directory structure starting from the data/ directory.

  * BWASP/data/
    * Species/
      * genome/
      * study/
        * caste/
          * replicate/

The [xmkdirstr](data/xmkdirstr) script helps create this structure and populates it with the relevant links and makefiles.

```bash
cd data
./xmkdirstr Pcan Patalano2015 Queen 3 p
```
Prepares the necessary structure for this tutorial run.
The subdirectory structure is designed to organize various data sets.  **Pcan** might hold several studies on _Polistes canadensis_, the **Patalano2015** study being one
example.
Under _Patalano2015_, the subdirectory **Queen** collects **3** _replicates_ of **p** aired-end reads from queens.
In each _replicate_ subdirectory, there is the required link to the _genome_ directory and a copy of _Makefile_\__WF1-6pe_\__template_.

## Getting the genome

First we need to put the _Polistes canadensis_ genome assembly and annotation files into the _Pcan/genome_ directory.
We download the files from the RefSeq FTP site link provided at the relevant
[NCBI assembly](http://www.ncbi.nlm.nih.gov/assembly/GCF_001313835.1/) page:

```bash
cd Pcan/genome
wget  ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/313/835/GCF_001313835.1_ASM131383v1/GCF_001313835.1_ASM131383v1_genomic.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/313/835/GCF_001313835.1_ASM131383v1/GCF_001313835.1_ASM131383v1_genomic.gff.gz
```

Assuming that everything was downloaded nicely, we decompress and link the files to more suggestive file names:

```bash
gunzip GCF_*.gz
ln -s GCF_001313835.1_ASM131383v1_genomic.fna Pcan.gdna.fa
ln -s GCF_001313835.1_ASM131383v1_genomic.gff Pcan.gff3
```

## Getting the reads

Three sets of BS-seq reads from queen adult brains were deposited in the NCBI Short Read Archive:

* [SRR1519132 21Q](http://www.ncbi.nlm.nih.gov/sra/SRX656317)
* [SRR1519133 43Q](http://www.ncbi.nlm.nih.gov/sra/SRX656318)
* [SRR1519134 75Q](http://www.ncbi.nlm.nih.gov/sra/SRX656319)

Note that the template makefile was copied into each replicate directory.
These makefiles contain instructions to download the reads from SRA, so they need to be edited  either to specify the SRA accession numbers or to point to manually acquired read files.

For our example, the template _makefile_ is already customized for analysis of the first queen replicate.  
The instructions below simply modify the sample name and SRA accession numbers for the _makefiles_ for the other two replicates:

```bash
sed -i -e "s/SRR1519132/SRR1519133/; s/Pcan-21Q/Pcan-43Q/;" replicate2/Makefile
sed -i -e "s/SRR1519132/SRR1519134/; s/Pcan-21Q/Pcan-75Q/;" replicate3/Makefile
```

Now we are ready to start the heavy data processing.

## Workflow

Since the rest of the workflow is fire and forget, a thorough proofreading of the makefiles is highly recommended at this point.
The section titled **Variable Settings** is the only part that is necessarily modified, and should be double checked before proceeding.  
Once that is done, we would run the workflow as follows (from directory _replicateX_):

```bash
make Bisulfite_Genome
make -j 4  &> bwasp.log
```

The first command with the _-n_ flag simply shows what _make_ will do (see
_make_ documentation), the second _make_ command runs the preparatory genome
processing step, and then assuming all looks ok, the third _make_
command will get the job done (running up to 4 jobs simultaneously).  Once the
the common _bismark_\__genome_\__preparation_ step is done, you
could start _make_ in the other _replicate_ directories - however, we strongly
suggest you finish one run first to make sure that everything works and you
have enough resources on your computer to run multiple __BWASP__ workflows
simultaneously.  Check the _err_ file and your system monitor frequently.

## Output

After completion of the BWASP workflow, the working directory should contain a
fair number of output files.  Please refer to the documentation of the various
constituent programs for details as well as our
[manuscript](http://brendelgroup.org/research/publications.php).
To remove unneeded intermediate files and archive files that may be of
interest later but are not needed in subsequent __BWASP__ analysis steps
we recommend running the following commands at this stage:

```bash
make cleanup
make finishup
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

### Read preparation, mapping, and quality reports
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

### Genome statistics
* Pcan.gdna.stats

Take a look and explore.  The _.stats_ and _report_ files would be good
starting points.


## Merging data from multiple replicates
While it is of interest to look at the methylation statistics across
different replicate data sets, typically the replicate data are pooled when
comparing between samples/conditions (_e.g._, Queen versus Worker samples).
The _bin_ directory contains template _makefiles_ for this step, and in fact
the _xmkdirstr_ script in our example already set this up for us in the
_Queen_ directory.  Just copy the _Makefile_\__merge_\__3replicates_ into
_Makefile\_\__merge_\__PcQ_, then edit and run as per instructions in the
_makefile_.  You will likely want to run the _cleanup_ and _finishup_
targets here as well:

```bash
make -f Makefile_merge_PcQ cleanup
make -f Makefile_merge_PcQ finishup
```

This will leave you with the

#### Combined methylation calls and statistics
* Pcan-queen.mstats
* Pcan-queen.CHGhsm.mcalls Pcan-queen.CHGnsm.mcalls Pcan-queen.CHGscd.mcalls
* Pcan-queen.CHHhsm.mcalls Pcan-queen.CHHnsm.mcalls Pcan-queen.CHHscd.mcalls
* Pcan-queen.CpGhsm.mcalls Pcan-queen.CpGnsm.mcalls Pcan-queen.CpGscd.mcalls
* Pcan-queen.HSMthresholds
