# BWASP : Bisulfite-seq data Workflow Automation Software and Protocols

The BWASP repository encompasses code and scripts developed in the
[Brendel Group](http://brendelgroup.org/) for analyses of bisulfite sequencing
data.
The entire workflow relies on various other open source software as well as
[R](https://www.r-project.org/) scripts from the companion
[BWASPR](https://github.com/BrendelGroup/BWASPR) repository.
The code conforms to our [RAMOSE](https://brendelgroup.github.io/)
philosophy: it generates __reproducible__, __accurate__, and __meaningful__
results; it is __open__ (source) and designed to be __scalable__ and
__easy__ to use.


## Quick Start [![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/1203)

Input to the BWASP workflow consists of accession numbers or fastq files of
bisulfite-sequencing reads as well as the appropriate genome assembly (and, if
available, genome annotation).
Output (after read quality control and mapping) are _*.mcalls_ files that list
the sufficiently covered genomic Cs and their methylation percentage in the
given sample.
The scripts in the _bin_ directory take care of minor tasks in the overall
workflow, but configuration and execution is via
[GNU make](https://www.gnu.org/software/make/) using edited copies of the
makefiles provided in the _makefiles_ directory.
All the BWASP dependencies are encapsulated in a
[Singularity](https://www.sylabs.io/docs/) container available from our
[Singularity Hub](http://BrendelGroup.org/SingularityHub/).
Thus, once you know what you are doing, execution could be as simple as

```
singularity pull http://BrendelGroup.org/SingularityHub/bwasp.sif
singularity exec bwasp.sif make
```

(assuming you have prepared a suitable makefile in your working directory).


## Realistic Start

Please find detailed installation instructions and options in the
[INSTALL](./INSTALL.md) document.
Once all preparatory steps are taken care of, see the [HOWTO](./HOWTO.md)
document for a complete example of how to implement and run a workflow.


## Reference

Amy L. Toth, Murat Ozturk, Saranya Sankaranarayanan, and Volker P. Brendel
(2018) _Estimating the size and dynamics of the CpG methylome of social
insects._ To be submitted.


## Contact

Please direct all comments and suggestions to
[Volker Brendel](<mailto:vbrendel@indiana.edu>)
at [Indiana University](http://brendelgroup.org/).
