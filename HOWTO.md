# BWASP HOWTO - an example for how to use the software

## For the impatient or those just needing a reminder

Please go to [data/README](./data/README.md) for production-level workflow scripting (pretty cool!).


## Preparation

At this stage, you should have completed the BWASP installation steps
documented in the [INSTALL](./INSTALL.md) document; we'll assume that you have
downloaded the `bwasp.sif` singularity container.

The BWASP script [xgetSRAacc](./bin/xgetSRAacc) uses NCBI SRA Toolkit to download data from NCBI SRA.
If you have been using SRA Toolkit already and allow local file-caching, you need to make sure that your file-caching location is accessible to singularity.
We recommend to disable local file-caching.
To do this, run:

```bash
  singularity exec -e bwasp.sif  vdb-config -i
```

navigate to CACHE by entering C and disable local file-caching by toggeling i, followed by x for exit, and possibly o for ok.

__Note: If this is the first time you are using SRA Toolkit on the current machine, you will have to invoke _vdb-config_ at least once to set your preferences (as per NCBI instructions).__


We explain BWASP use with an example from our
[publication](http://brendelgroup.org/).


## Samples
Our goal is to analyze BS-seq data sets from the
[Patalano _et al._, 2015,](http://www.ncbi.nlm.nih.gov/pubmed/26483466) study
of the paper wasp _Polistes canadensis_.
Three BS-seq data sets from queen adult brains were deposited in the NCBIs
 Sequence Read Archive:

* [SRR1519132 21Q](http://www.ncbi.nlm.nih.gov/sra/SRX656317)
* [SRR1519133 43Q](http://www.ncbi.nlm.nih.gov/sra/SRX656318)
* [SRR1519134 75Q](http://www.ncbi.nlm.nih.gov/sra/SRX656319)


## Preparing the directory structure

BWASP expects a certain directory structure starting from the
`BWASP_ROOT/data` directory (`BWASP_DATA`).

  * BWASP_DATA/
    * species/
      * genome/
      * study/
        * caste/
          * replicate/

This hierarchy is designed to organize various data sets.
Although not mandatory, it is recommended to follow it for easier operation.
The [xmkdirstr](./data/xmkdirstr) script helps create this structure and
populates it with the relevant links and makefiles for each sample.
Please note that makefiles for each sample need to be modified prior to running the workflow.

```bash
cd data
./xmkdirstr Pcan Patalano2015 Queen 3 p
```

Here, **Pcan** is an alias for _Polistes canadensis_, and the created **Pcan**
directory might eventually hold several studies on this species, the
**Patalano2015** study being one example.
Under _Patalano2015_, the subdirectory **Queen** will contain **3**
_replicates_ of **p**aired-end reads from queens.
Each _replicate_ subdirectory will be populated with a link to the _genome_
directory and a copy of _Makefile_\__pe_\__template_.

### Getting the genome

The BWASP workflow requires a reference genome, so we need to obtain and place
it in the appropriate directory.
The _Polistes canadensis_ genome can be found at the appropriate
[NCBI Genome page](https://www.ncbi.nlm.nih.gov/genome/16494).
We can simply get the direct download links for the genome assembly (FASTA) and
annotation (GFF) files to download them directly into the `Pcan/genome`
directory as follows:

```bash
cd Pcan/genome
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/313/835/GCF_001313835.1_ASM131383v1/GCF_001313835.1_ASM131383v1_genomic.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/313/835/GCF_001313835.1_ASM131383v1/GCF_001313835.1_ASM131383v1_genomic.gff.gz
```

Assuming everything was downloaded nicely, we decompress and link the files to
more convenient file names:

```bash
gunzip GCF_*.gz
ln GCF_001313835.1_ASM131383v1_genomic.fna Pcan.gdna.fa
ln GCF_001313835.1_ASM131383v1_genomic.gff Pcan.gff3
```

Note that the annotation was not necessary for the basic BWASP run but we downloaded it anyway for use in downstream analysis.
Also note that we preferred linking the files to moving (renaming) them to keep the original filenames for future reference.


### Getting the reads

Note that the appropriate template *Makefile* was copied into each replicate
directory.
This *Makefile* contains the necessary commands (fasterq-dump) to download reads
from [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra), so all we need to do is to
fill in the appropriate accession numbers.

For our example, the template _Makefile_ already has the accession number for
the first queen replicate.
We could manually edit numbers for the other two replicates or, better, use the
following commands to substitute the SRA accession number and sample labels for
the other two replicates:

```bash
sed -i -e "s/SRR1519132/SRR1519133/; s/Pcan-21Q/Pcan-43Q/;" replicate2/Makefile
sed -i -e "s/SRR1519132/SRR1519134/; s/Pcan-21Q/Pcan-75Q/;" replicate3/Makefile
```

Now we are ready to start the heavy data processing.


### Running the workflow

Because the rest of the workflow is fire and forget, proofreading of the *Makefile*s is highly recommended at this point.
The section titled **Variable Settings** is the only part that is necessarily modified and should be double-checked before proceeding.

Once that is done, it is recommended to source the `bwasp_env.sh` (as per
installation instructions) and confirm that the `BWASP_EXEC` variable is set by
checking the output of `echo $BWASP_EXEC`.
This is merely a convenience variable that holds a command that has all the
relevant singularity parameters set for the user.
For example, if user `bumblebee` has access to plenty of disk space on
`/bigdata/bumblebee/`, this user's $BWASP_EXEC might look like the
following:

```
singularity exec -e -B /bigdata/bumblebee/BWASP/data /bigdata/bumblebee/BWASP/bwasp.sif
```

Finally, we can run the `make`-enabled workflow (from directory _replicateX_):

```bash
$BWASP_EXEC make -n
$BWASP_EXEC make Bisulfite_Genome
$BWASP_EXEC make &> bwasp.log
```

The preceding `$BWASP_EXEC` makes sure that `make` runs from inside the
singularity container, where we made sure all the moving parts are in working
condition (i.e. all required binaries are of correct version and in the path).

The first *make* command with the -n flag simply shows what _make_ will do and
is valuable for reference.
The second _make_ command runs the preparatory genome processing step which
needs to be done once and is shared for all samples of a given species.
The third _make_ command will run the main workflow.

Once the the common _bismark_\__genome_\__preparation_ step is done, you
could start _make_ in the other _replicate_ directories - however, we strongly
suggest you finish one run first to make sure that everything works and you
have enough resources on your computer to run multiple __BWASP__ workflows
simultaneously.  Check the _err_ file and your system monitor frequently.


### Output

After completion of the BWASP workflow, the working directory should contain a
fair number of output files.
Please refer to the documentation of the various constituent programs for
details as well as our
[manuscript](https://onlinelibrary.wiley.com/doi/10.1111/1755-0998).
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


### Working with large data sets
For large data sets, the simple _fasterq\_dump_ command in the _Makefile_
may not be the best choice.
You may want to review the options to _fasterq\_dump_.
For example,

```
fasterq-dump SRRaccession -e 8 -t /dev/shm -p
```

would use 8 processors to download _SRRaccession_ and put the result into
_/dev/shm_, which should be much faster than disk storage.
The _-p_ option shows the progress of the download.
You would then deposit the read files (possibly after splitting them into
manageable chunks that could be treated as pseudo-replicates) into your
working directories from where you would execute the _make_ command.


### Merging data from multiple replicates
While it is of interest to look at the methylation statistics across
different replicate data sets, typically the replicate data are pooled when
comparing between samples/conditions (_e.g._, Queen versus Worker samples).

BWASP provides an additional makefile to merge replicates and provide cumulative
statistics over all replicates.
The _xmkdirstr_ script in our example already set this up for us in the _Queen_
directory.
We only need to specify the desired output label (SYNONYM = Pcan-queen in the
_Makefile_) and run (from directory _Queen_):

```bash
$BWASP_EXEC make
```

optionally followed by _cleanup_ and _finishup_ targets here as well:

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
