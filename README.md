# BWASP : Bisulfite-seq data Workflow Automation Software and Protocols

The BWASP repository encompasses code we developed in the [Brendel Group](http://brendelgroup.org/) for scalable and reproducible analyses of bisulfite sequencing data. It conforms to our [RAMOSE](https://brendelgroup.github.io/)
philosophy: it generates __reproducible__, __accurate__, and
__meaningful__ results; it is __open__ (source) and designed to be __scalable__
and __easy__ to use.

## Requirements and architecture [![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/763)

BWASP is built on various open source software that was developed within our group and elsewhere.
To achieve a portable and reproducible workflow, we encapsulated all the dependencies in a [Singularity](http://singularity.lbl.gov) container.
The workflow is implemented with GNU make.
If the provided makefile is invoked via the proper singularity command using our BWASP container, no further installation of programs in necessary.
For guidance on installing (or requesting an installation of) Singularity please refer to the relevant documentation.

### Running the workflow

Please refer to the [HOWTO](HOWTO.md) for an example run.

## Reference

Amy L. Toth, Murat Ozturk, Saranya Sankaranarayanan, and Volker P. Brendel (2018) _Estimating
the size and dynamics of the CpG methylome of social insects._ To be submitted.

## Contact

Please direct all comments and suggestions to
[Volker Brendel](<mailto:vbrendel@indiana.edu>)
at [Indiana University](http://brendelgroup.org/).
