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


## Quick Start

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
[Singularity](https://apptainer.org/) container available from our
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

__Claire Morandin and Volker P. Brendel (2021)__
 _Tools and applications for integrative analysis of DNA methylation in social insects._
Molecular Ecology Resources, 00, 1-19. [https://doi.org/10.1111/1755-0998.13566](https://doi.org/10.1111/1755-0998.13566).

Original pre-print: [at BioRxiv](https://www.biorxiv.org/content/10.1101/2021.08.19.457008v3).


## Contact

Please direct all comments and suggestions to
[Volker Brendel](<mailto:vbrendel@indiana.edu>)
at [Indiana University](http://brendelgroup.org/).
