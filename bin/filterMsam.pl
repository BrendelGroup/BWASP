#!/usr/bin/perl
#
# filterMsam.pl
#  - BWASP Perl script to filter Msam records

=begin comment

Latest version: May 17, 2023	Author: Volker Brendel (vbrendel@indiana.edu)

This script will take as input a combined alignment/methylation call file in SAM format,
such as produced by Bismark, for either paired-end reads or single reads.  The script
first determines the probabilities of Z, X, and H calls.  A second pass through the
input determines read pairs (or single reads) that have a very small probability of
being properly bisulfite-treated reads - in the extreme, reads that produce methylation
calls in all possible C positions, independent of context.  The tacit assumption is that
the most parsimonious explanation of the data is that these reads represent sequence
evidence of DNA not properly exposed to the bisulfite-treatment.  Motivation for this
script came from analysis of social insect methylomes that have invariably shown very
low methylation rates (typically less than 1%).

Threshold criteria are set in the code.  Our settings:
	- reject a read (pair) with methylation call probability less than 0.01
		(Bonferroni adjusted)
	- with additional criterion that the count of non-methylation calls (z,x,h)
		be less than 0.25 times the count of methylation calls (Z,X,H)

Paired reads are rejected if either one of the reads fails the criterion (output files
*.01fail and *.10fail) or both fail (output file *.11fail).

Note that the methylation probabilities are calculated from the count date recorded in
the counts_chunk_MsamGroup* files produced by countMcalls.pl. This workflow design
enables efficient use of multiple processors in the master xfilterMsam script.

=cut


# Libraries and pragmas
use strict;
use Getopt::Long;
use Math::BigFloat ':constant';

# Set command line usage
my $usage = "
Usage: filterMsam.pl <options> --p|--s MsamFile MsamGroup

  MsamFile               Mandotory Msam file
  MsamGroup              Mandotory group label
  --p|--s                Specify either --p or --s for paired-end or single read SAM input
  --outfile1=STRING      Passed-filter Msam output file name (MsamFile.pass by default)
  --outfile2=STRING      Failed-filter Msam output file name (MsamFile.*fail by default)
  --outpfile=STRING      Summary output file name (MsamFile.summary by default)
  --help                 Print this help message and exit

";

# Get options from the command line
my $MsamFile    = '';
my $MsamGroup   = '';
my $paired      = '';
my $single      = '';
my $psoption    = '';
my $outfile1    = '';
my $outfile11   = '';
my $outfile01   = '';
my $outfile10   = '';
my $outpfile    = '';
my $help        = '';

GetOptions(
    "p"              => \$paired,
    "s"              => \$single,
    "outfile1=s"     => \$outfile1,
    "outfile2=s"     => \$outfile11,
    "outpfile=s"     => \$outpfile,
    "help"           => \$help
);

if ($help || $paired eq $single) { printf( STDERR $usage ); exit; }

my $MsamGroup = $ARGV[-1]
  or die("\n\nError: Please provide the MsamGroup label.\n$usage $!");
my $MsamFile = $ARGV[-2]
  or die("\n\nError: Please provide MsamFile file as input.\n$usage $!");
if ( !-e $MsamFile ) {
  die("\n\nError: Msam file $MsamFile does not exist.\n$usage $!");
}
if ($paired ne '') {
	$psoption = "--p";
}
else {
	$psoption = "--s";
}
if ($paired ne '') {
  printf( STDERR "\nRunning filterMsam.pl with the following options:
    MsamFile     = %s
    MsamGroup    = %s
    --s|--p      = %s
    outfile1     = %s
    outfile2     = %s %s %s
    outpfile     = %s\n\n", $MsamFile, $MsamGroup, $psoption, $outfile1,
                            $outfile11, $outfile01, $outfile10, $outpfile
  );
}
else {
  printf( STDERR "\nRunning filterMsam.pl with the following options:
    MsamFile     = %s
    MsamGroup    = %s
    --s|--p      = %s
    outfile1     = %s
    outfile2     = %s
    outpfile     = %s\n\n", $MsamFile, $MsamGroup, $psoption, $outfile1,
                            $outfile11, $outpfile
  );
}


if ($outfile1 eq "") {
	$outfile1     = $MsamFile . ".pass";
}
else {
	$outfile1     = $outfile1 . ".pass";
}
if ($outfile11 eq "") {
	if ($paired ne '') {
		$outfile11     = $MsamFile . ".11fail";
		$outfile01     = $MsamFile . ".01fail";
		$outfile10     = $MsamFile . ".10fail";
	}
	else {
		$outfile11     = $MsamFile . ".fail";
	}
}
else {
	if ($paired ne '') {
		$outfile01     = $outfile11 . ".01fail";
		$outfile10     = $outfile11 . ".10fail";
		$outfile11     = $outfile11 . ".11fail";
	}
	else {
		$outfile11     = $outfile11 . ".fail";
	}
}
if ($outpfile eq "") {
	$outpfile     = $MsamFile . ".summary";
}
open( MSPFILE, "> $outfile1" );
open( MSF11FILE, "> $outfile11" );
if ($paired ne '') {
  open( MSF01FILE, "> $outfile01" );
  open( MSF10FILE, "> $outfile10" );
}
open( OUTFILE, "> $outpfile" );

my $datestring = localtime();
printf STDERR "Starting filtering $MsamFile at $datestring:\n";

my ( $samstring, $mthstring, $samstring2 );
my ( $zcount, $Zcount, $xcount, $Xcount, $hcount, $Hcount);
my ( $zxhcount, $ZXHcount );
my ( $Totalzcount, $TotalZcount, $Totalxcount, $TotalXcount, $Totalhcount, $TotalHcount) = (0, 0, 0, 0, 0, 0);


# Calculate methylation probabilities from the counts_chunk_MsamGroup* files produced
#  by countMcalls.pl:
#
opendir(DIR, "./");
my @files = grep{ /counts\_chunk\_${MsamGroup}.*/ } readdir(DIR);
closedir(DIR);

my $scnt = 0;
foreach my $file (@files) {
   open (CHUNKFH, "< $file" );
   my $data = <CHUNKFH>;
   my @a = split( ":", $data);
   $scnt += $a[1];
   my $data = <CHUNKFH>;
   my @a = split( "\t", $data);
   $Totalzcount += $a[1];
   $TotalZcount += $a[3];
   $Totalxcount += $a[5];
   $TotalXcount += $a[7];
   $Totalhcount += $a[9];
   $TotalHcount += $a[11];
}

my ($pz, $pZ, $px, $pX, $ph, $pH);
if ($Totalzcount+$TotalZcount > 0) {
  $pz = $Totalzcount/($Totalzcount+$TotalZcount);
  $pZ = 1.0 - $pz;
}
else {
  $pz = 0.0;
  $pZ = 0.0;
}
if ($Totalxcount+$TotalXcount > 0) {
  $px = $Totalxcount/($Totalxcount+$TotalXcount);
  $pX = 1.0 - $px;
}
else {
  $px = 0.0;
  $pX = 0.0;
}
if ($Totalhcount+$TotalHcount > 0) {
  $ph = $Totalhcount/($Totalhcount+$TotalHcount);
  $pH = 1.0 - $ph;
}
else {
  $ph = 0.0;
  $pH = 0.0;
}


printf OUTFILE "\nNumber of alignments: %12d\n", $scnt;
printf OUTFILE "Prob(z)=%6.4f\tProb(Z)=%6.4f\t\tProb(x)=%6.4f\tProb(X)=%6.4f\t\tProb(h)=%6.4f\tProb(H)=%6.4f\n", $pz, $pZ, $px, $pX, $ph, $pH;

my $logS     = log(0.01/$scnt);
my $fraction = 0.25;

open( MSFILE, "< $MsamFile" );
my ($scnt, $pcnt, $f11cnt, $f01cnt, $f10cnt) = (0,0,0,0,0);
my %ZlogP = ();
my %XlogP = ();
my %HlogP = ();
my $logP;
my $reject_read1;

while ( $samstring = <MSFILE> ) {
	$scnt++;
	my @a = split( "\t", $samstring );
	$mthstring = substr($a[13],5);

	$logP = read_calls_probability($mthstring);

	if ($paired ne '') {  # ... paired-read data
		if ($logP < $logS  &&  $zxhcount < $fraction * $ZXHcount) {
			$reject_read1 = 1;
		}
		else {
			$reject_read1 = 0;
		}
		$samstring2 = <MSFILE>;
		@a = split( "\t", $samstring2 );
		$mthstring = substr($a[13],5);

		$logP = read_calls_probability($mthstring);

		if ($logP < $logS  &&  $zxhcount < $fraction * $ZXHcount) {
			if ($reject_read1) {
				$f11cnt++;
				print MSF11FILE "$samstring";
				print MSF11FILE "$samstring2";
			}
			else {
				$f01cnt++;
				print MSF01FILE "$samstring";
				print MSF01FILE "$samstring2";
			}
		}
		else {
			if ($reject_read1) {
				$f10cnt++;
				print MSF10FILE "$samstring";
				print MSF10FILE "$samstring2";
			}
			else {
				$pcnt++;
				print MSPFILE "$samstring";
				print MSPFILE "$samstring2";
			}
		}
	}
	else {	# ... single-read data
		if ($logP < $logS  &&  $zxhcount < $fraction * $ZXHcount) {
			$f11cnt++;
			print MSF11FILE "$samstring";
		}
		else {
			$pcnt++;
			print MSPFILE "$samstring";
		}
	}

	if ($scnt%500000 == 0) {
	  my $datestring = localtime();
          printf STDERR "Filtering status for $MsamFile at $datestring:\t";
	  if ($paired ne '') {
	    printf STDERR "  scnt= %12d: pcnt= %12d, fcnt11= %12d, fcnt01= %12d, fcnt10= %12d\n", $scnt, $pcnt, $f11cnt, $f01cnt, $f10cnt;
	  }
	  else {
	    printf STDERR "  scnt= %12d: pcnt= %12d, fcnt= %12d\n", $scnt, $pcnt, $f11cnt;
	  }
	}
}
printf OUTFILE "\nThreshold:	logS=%12.2f\n", $logS;
printf OUTFILE "\nscnt=\t%12d", $scnt;
printf OUTFILE "\npcnt=\t%12d", $pcnt;
if ($paired ne '') {
  printf OUTFILE "\nf11cnt=\t%12d\t(%6.2f%%)\n", $f11cnt, 100.0*$f11cnt/$scnt;
  printf OUTFILE   "f01cnt=\t%12d\t(%6.2f%%)\n", $f01cnt, 100.0*$f01cnt/$scnt;
  printf OUTFILE   "f10cnt=\t%12d\t(%6.2f%%)\n", $f10cnt, 100.0*$f10cnt/$scnt;
}
else {
  printf OUTFILE "\nfcnt=\t%12d\t(%6.2f%%)\n", $f11cnt, 100.0*$f11cnt/$scnt;
}
my $datestring = localtime();
printf STDERR "Done filtering $MsamFile at $datestring:\n";


close MSFILE;
close MSF11FILE;
if ($paired ne '') {
  close MSF01FILE;
  close MSF10FILE;
}
close OUTFILE;


sub read_calls_probability {
  my ($mthstring) = @_;

  $zcount = ($mthstring =~ tr/z//);
  $Zcount = ($mthstring =~ tr/Z//);
  $xcount = ($mthstring =~ tr/x//);
  $Xcount = ($mthstring =~ tr/X//);
  $hcount = ($mthstring =~ tr/h//);
  $Hcount = ($mthstring =~ tr/H//);

  $zxhcount = $zcount + $xcount + $hcount;
  $ZXHcount = $Zcount + $Xcount + $Hcount;

  if (! exists $ZlogP{"$Zcount,$zcount"} ) {
    $ZlogP{"$Zcount,$zcount"} = log_binomial_tail($Zcount,$Zcount+$zcount,$pZ);
  }
  if (! exists $XlogP{"$Xcount,$xcount"} ) {
    $XlogP{"$Xcount,$xcount"} = log_binomial_tail($Xcount,$Xcount+$xcount,$pX);
  }
  if (! exists $HlogP{"$Hcount,$hcount"} ) {
    $HlogP{"$Hcount,$hcount"} = log_binomial_tail($Hcount,$Hcount+$hcount,$pH);
  }

  $logP = $ZlogP{"$Zcount,$zcount"} + $XlogP{"$Xcount,$xcount"} + $HlogP{"$Hcount,$hcount"};

  return ($logP);
}


sub log_binomial_tail {
   my ($k, $n, $p) = @_;
   my $x;
   my $TP = 0.0;
   my $MINTP = 1e-20;

  if ($n == 0) {
    return 0.0;
  }
  if ($p == 0.0) {
    return 0.0;
  }

  if ($k > $n/2) {
    for ($x = $k; $x <= $n; $x++) {
      $TP += (binomial($n,$x) * gpui($p,$x) * gpui(1.0 - $p, $n - $x));
    }
    if ($TP < $MINTP) {$TP = $MINTP;}
    return log($TP);
  }
  else {
    for ($x = $k-1; $x >= 0; $x--) {
      $TP += (binomial($n,$x) * gpui($p,$x) * gpui(1.0 - $p, $n - $x));
    }
    if ($TP > 1.0 - $MINTP) {$TP = 1.0 - $MINTP;}
    return log(1.0-$TP);
  }
}


sub binomial {
   my ($n, $k) = @_;
   my $retv = 1; 
  
   if ($k > $n - $k) {$k = $n - $k;}
  
   ## Calculate value of [n * (n-1) *---* (n-k+1)] / [k * (k-1) *----* 1] 
   for (my $i = 0; $i < $k; ++$i) { 
     $retv *= ($n - $i); 
     $retv /= ($i + 1); 
   } 
   return $retv; 
}


sub gpui {
   my ($p, $k) = @_;
   return $p ** $k;
}
