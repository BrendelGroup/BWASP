# BWASP : Bisulfite-seq data Workflow Automation Software and Protocols

The BWASP repository encompasses code we developed in the [Brendel Group](http://brendelgroup.org/) for scalable and reproducible analyses of bisulfite sequencing data. It conforms to our [RAMOSE](https://brendelgroup.github.io/)
philosophy: it generates __reproducible__, __accurate__, and
__meaningful__ results; it is __open__ (source) and designed to be __scalable__
and __easy__ to use.

## Requirements and architecture

BWASP is built on various open source software that was developed within our group and elsewhere.
To achieve a portable and reproducible workflow, we encapsulated all the dependencies in a [Singularity](http://singularity.lbl.gov) container.
The workflow is implemented with GNU make.
If the provide makefile is invoked via the proper singularity command using our BWASP container, no further installation of programs in necessary.
For guidance on installing (or requesting an installation of) Singularity please refer to the relevant documentation.

### Obtaining the container   [![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/763)

The relevant container can be downloaded from the [Singularity Hub](https://www.singularity-hub.org/collections/763) by doing :


```
singularity pull --name bwasp.simg shub://littleblackfish/BWASP
```

This downloads a pre-built container that __does not require sudo permission__ to run.
This is the recommended way of running the workflow and should exactly reproduce our published results.
Alternatively, one can build the same image from scratch using the [recipe](SingularityBWASP) by doing :

```
git clone https://github.com/BrendelGroup/BWASP.git
cd BWASP
sudo singularity build bwasp.simg SingularityBWASP
```

This builds the same container from scratch but requires sudo permission.

Although both methods will produce read-only images,
it is also possible to create a writable version of the image for further modification and redistribution.
For best practices regarding that, please refer to the [Singularity documentation](http://singularity.lbl.gov/docs-flow).

### Running the workflow

Mention that we require ~500 gb per sample and recommend 8 or more cores.

Briefly describe recommended data/ hierarchy and mention [xmkdirstr](data/xmkdirstr).

Briefly describe how makefiles work

  * WF1-pe
  * WF1-se
  * mergeX


Finally, refer to [HOWTO](./HOWTO.md) document for an example run.
That should also be modified for the new containerized flow.  

## Reference

Amy L. Toth, Murat Ozturk, Saranya Sankaranarayanan, and Volker P. Brendel (2018) _Estimating
the size and dynamics of the CpG methylome of social insects._ To be submitted.

## Contact

Please direct all comments and suggestions to
[Volker Brendel](<mailto:vbrendel@indiana.edu>)
at [Indiana University](http://brendelgroup.org/).
