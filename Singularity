bootstrap: docker
From: ubuntu:16.04

%post
    apt-get -y update
    apt-get -y --force-yes install git wget unzip make python3-pip python-pip

    cd opt

    #HTSLIB
    apt-get -y --force-yes install zlib1g-dev libbz2-dev liblzma-dev ncurses-dev
    git clone git://github.com/samtools/htslib.git htslib
  	cd htslib
  	make
    make install
  	cd ..

    #SAMTOOLS
  	git clone git://github.com/samtools/samtools.git samtools
  	cd samtools
    make
    make install
    cd ..

    #BOWTIE2
    wget --content-disposition http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.3.3/bowtie2-2.3.3-linux-x86_64.zip/download
    unzip bowtie2-2.3.3-linux-x86_64.zip

    #BISMARK
    wget http://www.bioinformatics.babraham.ac.uk/projects/bismark/bismark_v0.19.0.tar.gz
    tar -xzf bismark_v0.19.0.tar.gz

    #FASTQC
    apt-get -y --force-yes install openjdk-9-jre-headless
    wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
    unzip fastqc_v0.11.5.zip
    chmod +x FastQC/fastqc

    #SRATOOLKIT
    wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2/sratoolkit.2.8.2-ubuntu64.tar.gz
    tar -xzf sratoolkit.2.8.2-ubuntu64.tar.gz

    #TRIM_GALORE
    wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v0.4.1.zip
    unzip trim_galore_v0.4.1.zip
    pip3 install --upgrade cutadapt

    #GENOMETOOLS
    apt-get -y --force-yes install libcairo2-dev libpango1.0-dev
    wget http://genometools.org/pub/genometools-1.5.9.tar.gz
    tar -xzf genometools-1.5.9.tar.gz
    cd genometools-1.5.9/
    make
    make install
    cd ..

    #AEGeAn
    git clone https://github.com/BrendelGroup/AEGeAn.git
    cd AEGeAn/
    make
    make install
    cd ..

    #Perl dependencies
    echo y |cpan install  LWP::UserAgent
    cpan install HTML::LinkExtor
    cpan install Math::Pari

    #Python dependencies
    pip3 install numpy scipy
    pip install numpy scipy

    #BWASP
    git clone https://github.com/littleblackfish/BWASP.git

%environment
    export LC_ALL=C
    export PATH=$PATH:/opt/bowtie2-2.3.3
    export PATH=$PATH:/opt/Bismark_v0.19.0
    export PATH=$PATH:/opt/FastQC
    export PATH=$PATH:/opt/sratoolkit.2.8.2-ubuntu64/bin
    export PATH=$PATH:/opt/trim_galore_zip
    export PATH=$PATH:/opt/BWASP/bin

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/




%runscript
    fortune | cowsay | lolcat
