# BWASP Installation and Setup

## Obtaining BWASP

Presumably you are reading this file on our github site and thus you are
likely to know that the following commands on your local machine should get
you going:

```bash
git clone https://github.com/BrendelGroup/BWASP
cd BWASP/
```

That said, an implicit assumption is that your local machine runs some version
of Linux.  Moreover, typical BS-seq experiments involve large data sets.  BWASP
will make the analysis of these data sets __easy, accurate, meaningful,
reproducible, and scalable__ (our __EAMRS__ philosophy and promise).  Just one
data set from a modern NGS machine might require up to 500 Gb of disk space,
counting all the temporary files generated in the process.  It will be up to
you to specify the number of processors to be used in various parallel steps
during the workflow.  We like to have 10-20 processors dedicated to the task
(although most of the time, fewer processors will be used).  Even then, be
prepared to wait a day (or two) until all is done.  Sounds bad?  Not really,
because the whole analysis is quite a complex process, but both the original
setup of BWASP and the setup of particular analyses takes only a few minutes
each.  Once launched, go on thinking about your science, or start drafting the
paper!

## Preliminary Steps

BWASP is a workflow that invokes easily available third-party software as well
as scripts developed in our group.  As a first step, go to the [src](./src)
directory and install required programs as per instructions in the
[README](./src/README.md) file in that directory.  You will need to keep
track of the paths to the installed binaries, and you will need to copy the
[AEGeAn](https://github.com/BrendelGroup/AEGeAn) binaries _canon-gff3_ and
_pmrna_ into the [bin](./bin) directory.  Although quite a few external
programs are involved, typical installation can be scripted (as described) and
would not take more than a few minutes.

BWASP uses a modified version of the BISMARK _bismkark\_methylation\_extractor_
script (to appropriately handle culling of 5'-end biased positions).  This
modified script works with the current BISMARK _bismark2bedGraph_ script,
but you will need to copy that script from your BISMARK installation directory
to the BWASP [bin](./bin) directory.

BWASP relies on a number of bash, Perl, and python scripts that are placed in
the [bin](./bin) directory.  The Perl and python scripts use various packages
that must be pre-installed on your system.  Run the _xcheckprequisites_ bash
script in the [bin](./bin) directory to see what is available.  If packages
are missing, you need to install them prior to running the BWASP workflow
(there are many ways to install Perl and python packages; if in doubt, ask your
systems administrator).

## Finally

proceed to the [HOWTO](./HOWTO.md) document, and we'll tell you how to execute
sample workflows (or, equally easy, your very own data analyses).
