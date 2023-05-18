#!/usr/bin/perl
#
# countMcalls.pl
#  - BWASP Perl script to count methylation calls in input SAM file.
#  This script is used in xfilterMsam.

=begin comment

Latest version: May 17, 2023	Author: Volker Brendel (vbrendel@indiana.edu)

This script will take as input a combined alignment/methylation call file in SAM format,
such as produced by Bismark, for either paired-end reads or single reads.  The script
records the z/Z, x/X, and h/H methylation call counts for the input and stores them
in file counts_MsamFile for subsequent reading by filterMsam.pl.

=cut


# Libraries and pragmas
use strict;
use Getopt::Long;

# Set command line usage
my $usage = "
Usage: countMcalls.pl MsamFile

  MsamFile               Mandotory Msam file
  --help                 Print this help message and exit

";

# Get options from the command line
my $MsamFile    = '';
my $help        = '';

GetOptions(
    "help"           => \$help
);

if ($help) { printf( STDERR $usage ); exit; }

my $MsamFile = shift(@ARGV)
  or die("\n\nError: Please provide MsamFile file as input.\n$usage $!");
if ( !-e $MsamFile ) {
  die("\n\nError: Msam file $MsamFile does not exist.\n$usage $!");
}
my $outpfile    = "counts_".$MsamFile;

open( MSFILE,  "< $MsamFile" );
open( OUTFILE, "> $outpfile" );

my $datestring = localtime();
printf STDERR "Start counting Mcalls in $MsamFile at $datestring:\n";

my ( $samstring, $mthstring);
my ( $zcount, $Zcount, $xcount, $Xcount, $hcount, $Hcount);
my ( $Totalzcount, $TotalZcount, $Totalxcount, $TotalXcount, $Totalhcount, $TotalHcount) = (0, 0, 0, 0, 0, 0);

my $scnt = 0;
while ( $samstring = <MSFILE> ) {
	$scnt++;
	if ($scnt%500000 == 0) {
          my $datestring = localtime();
          printf STDERR "Processed from $MsamFile at $datestring:\t%12d reads\n", $scnt;
	  #printf STDERR "  scnt= %12d\n", $scnt;
	}
	my @a = split( "\t", $samstring );
	$mthstring = substr($a[13],5);
	$zcount = ($mthstring =~ tr/z//);
	$Zcount = ($mthstring =~ tr/Z//);
	$xcount = ($mthstring =~ tr/x//);
	$Xcount = ($mthstring =~ tr/X//);
	$hcount = ($mthstring =~ tr/h//);
	$Hcount = ($mthstring =~ tr/H//);

	$Totalzcount += $zcount;
	$TotalZcount += $Zcount;
	$Totalxcount += $xcount;
	$TotalXcount += $Xcount;
	$Totalhcount += $hcount;
	$TotalHcount += $Hcount;
}

printf OUTFILE "Number of alignments: %12d\n", $scnt;
printf OUTFILE "zcount\t%d\tZcount\t%d\txcount\t%d\tXcount\t%d\thcount\t%d\tHcount\t%d\n",
		$Totalzcount, $TotalZcount, $Totalxcount, $TotalXcount, $Totalhcount, $TotalHcount;

printf STDERR "End counting Mcalls in $MsamFile at $datestring:\n";
close MSFILE;
close OUTFILE;
