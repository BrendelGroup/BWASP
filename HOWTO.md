# BWASP HOWTO - an example for how to use the software

## Preparation

At this stage, you should have completed the BWASP installation steps
documented in the [INSTALL](./INSTALL.md) document.  We'll explain BWASP
use with an example from our [publication](http://brendelgroup.org/).

## Example
Our goal is to analyze BS-seq data sets from the [Patalano _et al._, 2015,](http://www.ncbi.nlm.nih.gov/pubmed/26483466) study of the paper wasp
_Polistes canadensis_.  Three BS-seq data sets from queen adult brains
were deposited in the NCBI Short Read Archive:

* [SRR1519132 21Q](http://www.ncbi.nlm.nih.gov/sra/SRX656317)
* [SRR1519133 43Q](http://www.ncbi.nlm.nih.gov/sra/SRX656318)
* [SRR1519134 75Q](http://www.ncbi.nlm.nih.gov/sra/SRX656319)

To set up a directory structure for our BWASP analysis, we go to the _data_
directory and populate subdirectories with the _xmkdirstr_ script (this
is for convenience; you can set things up however you please, as long as
a few conventions are obeyed).

```bash
cd data
./xmkdirstr Pcan Patalano2015 Queen 3 p
```

First we need to put the _Polistes canadensis_ genome assembly and
annotation files into the _Pcan/genome_ directory.  We download the files
from the links suggested at the relevant [NCBI assembly](http://www.ncbi.nlm.nih.gov/assembly/GCF_001313835.1/)
page:

```bash
cd Pcan/genome
curl -O ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA_001313835.1_ASM131383v1/GCA_001313835.1_ASM131383v1_genomic.fna.gz
curl -O ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA_001313835.1_ASM131383v1/GCA_001313835.1_ASM131383v1_genomic.gff.gz
```

Assuming that everything was downloaded nicely, we link the files to more
suggestive file names:

```bash
gunzip GCA*
ln -s GCA_001313835.1_ASM131383v1_genomic.fna Pcan.gdna.fa
ln -s GCA_001313835.1_ASM131383v1_genomic.gff Pcan.gff3
```

A last step for preparatory processing is to run the _Makefile_\__parse_\__GFF3_\__template_ workflow step:

```bash
mv Makefile_parse_GFF3_template Makefile_parse_GFF3_Pcan
make -f Makefile_parse_GFF3_Pcan
```

Note that the template _makefile_ was copied from the _bin_ directory.  For this example, no editing is necessary, but in general you will want to
customize the _makefile_ as per instructions in the file.  __BWASP__ is for
you to own and customize according to your data analysis needs - don't let the
ease of installation and sample use obscure this basic premise and opportunity.

Now we are ready to start the heavy data processing.  The subdirectory
structure is designed to organize various data sets.  _Pcan_ might hold
several studies on _Polistes canadensis_, the _Patalano2015_ study being one
example.  Under _Patalano2015_, the subdirectory _Queen_ collects 3
_replicates_ of queen data (another subdirectory might be labeled _Worker_,
for obvious reasons).  In each _replicate_ subdirectory, there is the
required link to the _genome_ directory and a copy of
_Makefile_\__WF1-6pe_\__template_.  As always, you need to customize the
_makefiles_ to suit the particular analysis task.  For our example, the
template _makefile_ is already customized for analysis of the first queen
replicate.  The instructions below customize the _makefiles_ for the other
two replicates:

```bash
mv replicate1/Makefile_WF1-6pe_template replicate1/Makefile_WF1-6pe_PcQ1
mv replicate2/Makefile_WF1-6pe_template replicate2/Makefile_WF1-6pe_PcQ2
mv replicate3/Makefile_WF1-6pe_template replicate3/Makefile_WF1-6pe_PcQ3
sed -i -e "s/SRR1519132/SRR1519133/; s/Pcan-21Q/Pcan-43Q/;" replicate2/Makefile_WF1-6pe_PcQ2
sed -i -e "s/SRR1519132/SRR1519134/; s/Pcan-21Q/Pcan-75Q/;" replicate3/Makefile_WF1-6pe_PcQ3
```

That's all for the setup.  Typically we would run the workflow as follows
(from directory _replicate1_):

```bash
make -n -f Makefile_WF1-6pe_PcQ1
make -j 4 -f Makefile_WF1-6pe_PcQ1 >& err
```

The first command with the _-n_ flag simply shows what _make_ will do (see _make_ documentation), then assuming all looks ok, the second _make_
command will get the job done (running up to 4 jobs simultaneously).  Once the
workflow is passed the common _bismark_\__genome_\__preparation_ step, you
could start _make_ in the other _replicate_ directories - however, we strongly
suggest you finish one run first to make sure that everything works and you
have enough resources on your computer to run multiple __BWASP__ workflows
simultaneously.  Check the _err_ file and your system monitor frequently.
