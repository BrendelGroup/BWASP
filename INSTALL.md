# BWASP Installation and Setup

## Requirements

  * BWASP should run on any platform that supports [Singularity](http://singularity.lbl.gov/) (Linux, MacOS, Windows), although we have only tested on Linux.

  * BWASP can execute on a single processor machine, but realistically you would want to have 10-20 cores available.

  * BWASP requires a considerable amount of memory (>16 GB) and free disk space (~500 GB for temporary output files for a typical experimental data set).


## Installation as a singularity container

Assuming _git_ and  _singularity_ are installed on your system, you can get the
BWASP code from GitHub and the container from the
[Singularity Hub](https://www.singularity-hub.org/collections/763) as follows:

```bash
git clone https://github.com/brendelgroup/BWASP.git
cd BWASP
singularity pull shub://BrendelGroup/BWASP
source bin/bwasp_env.sh
```

Sourcing `bwasp_env.sh` sets up the environment variables `BWASP_ROOT`,
`BWASP_DATA`, and `BWASP_EXEC`.
You may want to do this before every run to make sure these variables are in
place.
For a gentle introduction to singularity, see our group
[handbook article](https://github.com/BrendelGroup/bghandbook/blob/master/doc/06.2-Howto-Singularity-run.md).


## Optional: System-wide Installation

BWASP use via the singularity container is highly recommended, with no known
drawbacks.
However, if desired, you can of course install all the required software and
packages individually on your computer system.
The singularity [recipe file](./Singularity) in this repository chould serve as
a guide to perform such an installation.
The `bwasp.simg` container was built on the 
[current long-term supported Ubuntu 18.04 distribution](https://www.ubuntu.com/download/desktop)
and thus the instructions apply to that particular Linux version.


## Finally

proceed to the [HOWTO](./HOWTO.md) document, and we'll tell you how to execute
sample workflows (or, equally easy, your very own data analyses).
