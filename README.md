# BWASP
Bisulfite-seq data Workflow Automation Software and Protocols

The BWASP repository encompasses code we developed in the [Brendel Group](http://brendelgroup.org/) for scalable and reproducible analyses of bisulfite sequencing data. It conforms to our [RAMOSE](https://brendelgroup.github.io/)
philosophy: it generates __reproducible__, __accurate__, and
__meaningful__ results; it is __open__ (source) and designed to be __scalable__
and __easy__ to use.

## Requirements and architecture

BWASP is built on various open source software that was developed within our group and elsewhere.
To achieve a portable and reproducible workflow, we encapsulated all the dependencies in a [Singularity](http://singularity.lbl.gov) container.
The actual workflows are implemented in simple makefiles that refer to this self-contained environment.
As such, the only requirement is __singularity__ itself, and __make__.

### Obtaining the container

The container can be downloaded from the [Singularity Hub](https://www.singularity-hub.org/collections/763) by doing :


```
singularity pull --name bwasp.simg shub://littleblackfish/BWASP
```

This downloads the image built by the [Singularity Hub](https://www.singularity-hub.org) infrastructure and does not require sudo permissions.
This is the recommended way of running the workflow and it should exactly reproduce the our published results.


Alternatively, one can build the same image from scratch using the [recipe](Singularity) by doing :

```
git clone https://github.com/littleblackfish/BWASP.git
cd BWASP
sudo singularity build bwasp.simg Singularity
```

This builds the same image from scratch but requires sudo permissions.

Both methods will produce read-only images.
It is also possible to create a writable version of the image for further modification and redistribution.
For best practices regarding that, please refer to the [Singularity documentation](http://singularity.lbl.gov/docs-flow).

### Running the workflow




To proceed, please follow the instructions in the [INSTALL](./INSTALL.md)
document.  Once all preparatory steps are taken care of, see the
[HOWTO](./HOWTO.md) document

## Reference

Amy L. Toth, Saranya Sankaranarayanan, and Volker P. Brendel (2016) _Estimating
the size and dynamics of the CpG methylome of social insects._ To be submitted.

## Contact

Please direct all comments and suggestions to
[Volker Brendel](<mailto:vbrendel@indiana.edu>)
at [Indiana University](http://brendelgroup.org/).
