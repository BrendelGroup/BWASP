++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
BWASP - system wide installation of required software
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

README
	Sources and installation notes (current as of December 31, 2015)

	Our recommendation is to install the required programs system-wide.
	Typical would be to run the installation steps as superuser after
	"cd /usr/local/src".  Even better might be to create a directory
	/usr/local/src/BWASP and install the programs there; this might
	avoid clashes with other programs you are running that possibly
	depend on earlier versions of the same packages.

	For a quick install (at your own risk), you can try:

		mkdir <preferred-install-directory>
		cp README.txt <preferred-install-directory>
		cd <preferred-install-directory>
		egrep "^#" README.txt | cut -c2- > xinstall
		chmod a+x xinstall
		./xinstall

	We would recommend you look at xinstall first and decide whether
	this script represents how you want to install the programs.

	Source of the programs are listed.  Please see the cited URLs for
	details on the software and installation.

##!/bin/bash
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


BISMARK
	from http://www.bioinformatics.babraham.ac.uk/projects/bismark/
#	mkdir BISMARK; cd BISMARK
#	wget http://www.bioinformatics.babraham.ac.uk/projects/bismark/bismark_v0.14.5.tar.gz
#	tar -xzf bismark_v0.14.5.tar.gz
#	cd bismark_v0.14.5/
##	cp bismark bismark2* bismark_genome_preparation bismark_methylation_extractor coverage2cytosine deduplicate_bismark /usr/local/bin/
#	cd ../..


BOWTIE2
	from http://bowtie-bio.sourceforge.net/bowtie2/index.shtml
#	mkdir BOWTIE2; cd BOWTIE2
#	wget http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip/download
#	mv download bowtie2-2.2.6-linux-x86_64.zip
#	unzip bowtie2-2.2.6-linux-x86_64.zip
#	cd bowtie2-2.2.6/
##	cp bowtie2* /usr/local/bin/
#	cd ../..


FASTQC
	from http://www.bioinformatics.babraham.ac.uk/projects/fastqc/
#	mkdir FASTQC; cd FASTQC
#	wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.4.zip
#	unzip fastqc_v0.11.4.zip
#	cd FastQC
#	chmod a+x fastqc
#	cd ../..


SAMTOOLS
	from http://www.htslib.org/
#	mkdir SAMTOOLS; cd SAMTOOLS
#	git clone git://github.com/samtools/htslib.git htslib
#	cd htslib
#	make
#	cd ..
#
#	git clone git://github.com/samtools/samtools.git samtools
#	cd samtools
#	make
#
##	cp samtools /usr/local/bin
#	cd ../..


SRATOOLKIT
	from http://www.ncbi.nlm.nih.gov/books/NBK158900/
#	mkdir SRATOOLKIT; cd SRATOOLKIT
#	wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.5.7/sratoolkit.2.5.7-centos_linux64.tar.gz
#	tar -xzf sratoolkit.2.5.7-centos_linux64.tar.gz
#	cd ..


TRIM_GALORE
	from http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/
#	mkdir TRIM_GALORE; cd TRIM_GALORE
#	wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v0.4.1.zip
#	unzip trim_galore_v0.4.1.zip
#	pip install --upgrade cutadapt
##	 (version 1.9.1)
#	cd ..


GENOMETOOLS
	from http://genometools.org/
#	mkdir GENOMETOOLS; cd GENOMETOOLS
#	curl -O http://genometools.org/pub/genometools-1.5.7.tar.gz
#	tar -xzf genometools-1.5.7.tar.gz 
#	cd genometools-1.5.7/
#	make
#	make install
#	cd ../..


AEGeAn
	from https://github.com/BrendelGroup/AEGeAn/
#	git clone https://github.com/BrendelGroup/AEGeAn.git
#	cd AEGeAn/
##	 (make sure that the packages cairo and cairo-devel are
##	  installed; e.g., on Fedora 23: "dnf install cairo cairo-devel")
#	make
#	make install
#	cd ..
