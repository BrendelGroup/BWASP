bootstrap: docker
From: ubuntu:16.04

%help
    This container provides portable & reproducible components for BWASP:
    Bisulfite-seq data Workflow Automation Software and Protocols from Brendel Group.
    Please see https://github.com/littleblackfish/BWASP for complete documentation.

%post
    apt-get -y update
    apt-get -y install build-essential
    apt-get -y install git wget zip unzip tcsh

    echo 'Installing HTSLIB from http://www.htslib.org/'
    #### Prerequisites
    apt-get -y install zlib1g-dev libbz2-dev liblzma-dev
    #### Install
    cd /opt
    git clone git://github.com/samtools/htslib.git htslib
  	cd htslib
  	make && make install

    echo 'Installing SAMTOOLS from http://www.htslib.org/'
    #### Prerequisites
    apt-get -y install ncurses-dev
    #### Install
    cd /opt
  	git clone git://github.com/samtools/samtools.git samtools
  	cd samtools
    make && make install

    echo 'Installing BOWTIE2 from http://bowtie-bio.sourceforge.net/bowtie2'
    ######
    cd /opt
    wget --content-disposition http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.3.3/bowtie2-2.3.3-linux-x86_64.zip/download
    unzip bowtie2-2.3.3-linux-x86_64.zip

    echo 'Installing BISMARK from http://www.bioinformatics.babraham.ac.uk/projects/bismark/'
    ######
    cd /opt
    git clone https://github.com/littleblackfish/Bismark
    # Note that we are using the slightly modified Brendel Group version of Bismark

    echo 'Installing FASTQC from http://www.bioinformatics.babraham.ac.uk/projects/fastqc/'
    #### Prerequisites
    apt-get -y install openjdk-8-jre-headless
    #### Install
    cd /opt
    wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
    unzip fastqc_v0.11.5.zip
    chmod +x FastQC/fastqc


    echo 'Installing SRATOOLKIT from http://www.ncbi.nlm.nih.gov/books/NBK158900/'
    ######
    cd /opt
    wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2/sratoolkit.2.8.2-ubuntu64.tar.gz
    tar -xzf sratoolkit.2.8.2-ubuntu64.tar.gz

    echo 'Installing TRIM_GALORE from http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/'
    #### Prerequisites
    apt-get -y install python-pip
    pip install --upgrade cutadapt
    #### Install
    cd /opt
    wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v0.4.1.zip
    unzip trim_galore_v0.4.1.zip

    echo 'Installing GENOMETOOLS from from http://genometools.org/'
    #### Prerequisites
    apt-get -y install libcairo2-dev libpango1.0-dev
    #### Install
    cd /opt
    wget http://genometools.org/pub/genometools-1.5.9.tar.gz
    tar -xzf genometools-1.5.9.tar.gz
    cd genometools-1.5.9/
    make && make install

    echo 'Installing AEGeAn from https://github.com/BrendelGroup/AEGeAn/'
    ######
    cd /opt
    git clone https://github.com/BrendelGroup/AEGeAn.git
    cd AEGeAn/
    make && make install

    echo 'Installing BWASP from https://github.com/littleblackfish/BWASP.git'
    #### Prerequisites
    apt-get -y install python-numpy python-scipy
    cpan install Math::Pari
    #### Install
    cd /opt
    git clone https://github.com/littleblackfish/BWASP.git

%environment
    export LC_ALL=C
    export PATH=$PATH:/opt/bowtie2-2.3.3
    export PATH=$PATH:/opt/Bismark
    export PATH=$PATH:/opt/FastQC
    export PATH=$PATH:/opt/sratoolkit.2.8.2-ubuntu64/bin
    export PATH=$PATH:/opt/trim_galore_zip
    export PATH=$PATH:/opt/BWASP/bin

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/

%labels
    Maintainer littleblackfish
    Version v1.0
