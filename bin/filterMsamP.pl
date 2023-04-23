#!/usr/bin/perl
#
#filterMsamP.pl
# - BWASP Perl script to filter Msam records

=begin comment

Latest version: April 23, 2023	Author: Volker Brendel (vbrendel@indiana.edu)

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
*.01fail and *.10fail) or both (output file *.11fail).

=cut


# Libraries and pragmas
use strict;
use Getopt::Long;
use Math::BigFloat ':constant';
use Parallel::Loops;

# Set command line usage
my $usage = "
Usage: filterMsamP.pl <options> --p|--s MsamFile

  MsamFile               Mandotory Msam file
  --p|--s                Specify either --p or --s for paired-end or single read SAM input
  --n=INTEGER            Number of processors to use (default: 4)
  --outfile1=STRING      Passed-filter Msam output file name (MsamFile.pass by default)
  --outfile2=STRING      Failed-filter Msam output file name (MsamFile.*fail by default)
  --outpfile=STRING      Summary output file name (MsamFile.summary by default)
  --help                 Print this help message and exit

";

# Get options from the command line
my $MsamFile    = "";
my $paired      = "";
my $single      = "";
my $psoption    = "";
my $numprc      =  4;
my $outfile1    = "";
my $outfile11   = "";
my $outfile01   = "";
my $outfile10   = "";
my $outpfile    = "";
my $help        = '';

GetOptions(
    "p"              => \$paired,
    "s"              => \$single,
    "n=i"            => \$numprc,
    "outfile1=s"     => \$outfile1,
    "outfile2=s"     => \$outfile11,
    "outpfile=s"     => \$outpfile,
    "help"           => \$help
);

if ($help || $paired eq $single) { printf( STDERR $usage ); exit; }

my $MsamFile = shift(@ARGV)
  or die("\n\nError: Please provide MsamFile file as input.\n$usage $!");
if ( !-e $MsamFile ) {
  die("\n\nError: Msam file $MsamFile does not exist.\n$usage $!");
}


if ($paired) {
	$psoption = "--p";
}
else {
	$psoption = "--s";
}
if ($paired) {
  printf( STDERR "\nRunning filterMsamP.pl with the following options:
    MsamFile     = %s
    --s|--p      = %s
    --n          = %s
    outfile1     = %s
    outfile2     = %s %s %s
    outpfile     = %s\n\n", $MsamFile, $psoption, $numprc, $outfile1, $outfile11, $outfile01, $outfile10, $outpfile
  );
}
else {
  printf( STDERR "\nRunning filterMsamP.pl with the following options:
    MsamFile     = %s
    --s|--p      = %s
    --n          = %s
    outfile1     = %s
    outfile2     = %s
    outpfile     = %s\n\n", $MsamFile, $psoption, $numprc, $outfile1, $outfile11, $outpfile
  );
}


my $pl = Parallel::Loops->new($numprc);
my @returnedChunkLabels;


if ($outfile1 eq "") {
	$outfile1     = $MsamFile . ".pass";
}
else {
	$outfile1     = $outfile1 . ".pass";
}
if ($outfile11 eq "") {
	if ($paired) {
		$outfile11     = $MsamFile . ".11fail";
		$outfile01     = $MsamFile . ".01fail";
		$outfile10     = $MsamFile . ".10fail";
	}
	else {
		$outfile11     = $MsamFile . ".fail";
	}
}
else {
	if ($paired) {
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
open( MSFILE,  "< $MsamFile" );
open( MSPFILE, "> $outfile1" );
open( MSF11FILE, "> $outfile11" );
if ($paired) {
  open( MSF01FILE, "> $outfile01" );
  open( MSF10FILE, "> $outfile10" );
}
open( OUTFILE, "> $outpfile" );


my ( $samstring1, $mthstring, $samstring2, @samstrings );
my ( $zcount, $Zcount, $xcount, $Xcount, $hcount, $Hcount);
my ( $zxhcount, $ZXHcount );
my ( $Totalzcount, $TotalZcount, $Totalxcount, $TotalXcount, $Totalhcount, $TotalHcount) = (0, 0, 0, 0, 0, 0);


my $n = `cat $MsamFile | wc -l`;
my $scnt = 0;
my @samstringchunks = ();
foreach ( 0 .. $numprc-1 ) {
  $samstringchunks[$_][0] = undef;
}
my $sum = 0;
my @bindev = ();

$bindev[0] = int($n/$numprc);
foreach ( 1 .. $numprc-2 ) {
 $bindev[$_] = $bindev[$_-1] +  $bindev[0];
}
$bindev[$numprc-1] = $n;


my $bin = 0;
if ($paired == 0) {
  while ( $samstring1 = <MSFILE> ) {
	if ($samstring1 =~ /^\@(HD|SQ|RG|PG)(\t[A-Za-z][A-Za-z0-9]:[ -~]+)+$/ || $samstring1 =~ /^\@CO\t.*/) {
#         ... ignore SAM header lines, identified as per http://samtools.github.io/hts-specs/SAMv1.pdf
	  next;
	}
	$scnt++;
	if ($scnt%1000000 == 0) {
	  printf STDERR "scnt= %12d\n", $scnt;
	}
	my @a = split( "\t", $samstring1 );
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

	if ($scnt < $bindev[$bin]) {
	  push(@{$samstringchunks[$bin]}, [$scnt, $samstring1]);
	}
	else {
	  push(@{$samstringchunks[$bin]}, [$scnt, $samstring1]);
	  $bin += 1;
	}
  }
}
else {
  while ( $samstring1 = <MSFILE> ) {
	if ($samstring1 =~ /^\@(HD|SQ|RG|PG)(\t[A-Za-z][A-Za-z0-9]:[ -~]+)+$/ || $samstring1 =~ /^\@CO\t.*/) {
#         ... ignore SAM header lines, identified as per http://samtools.github.io/hts-specs/SAMv1.pdf
	  next;
	}
	$scnt++;
	if ($scnt%1000000 == 0) {
	  printf STDERR "scnt= %12d\n", $scnt;
	}
	my @a = split( "\t", $samstring1 );
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

	$samstring2 = <MSFILE>;
	$scnt++;
	@a = split( "\t", $samstring2 );
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

	if ($scnt < $bindev[$bin]) {
	  push(@{$samstringchunks[$bin]}, [$scnt/2, $samstring1, $samstring2]);
	}
	else {
	  push(@{$samstringchunks[$bin]}, [$scnt/2, $samstring1, $samstring2]);
	  $bin += 1;
	}
  }
}

foreach ( 0 .. $numprc-1 ) {
  shift @{$samstringchunks[$_]};
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

close MSFILE;

my $logS     = log(0.01/$scnt);
my $fraction = 0.25;

my $scnt = 0;
my $pcnt = 0;
my $f11cnt = 0;
my $f01cnt = 0;
my $f10cnt = 0;
my %ZlogP = ();
my %XlogP = ();
my %HlogP = ();
my $logP;
my $reject_read1;


if ($paired == 0) {
	@returnedChunkLabels = $pl->foreach( [0 .. $numprc-1], sub {
	  my @samstringsChunksLabeled = (); 
	  foreach my $samstring ( @{$samstringchunks[$_]} ) {
	    my @returnL = ( @$samstring[0] );
	    my @a = split( "\t", @$samstring[1] );
	    $mthstring = substr($a[13],5);
	    $logP = read_calls_probability($mthstring);
	    if ($logP < $logS  &&  $zxhcount < $fraction * $ZXHcount) {
	      push(@returnL, 1);
	    } else {
	      push(@returnL, 0);
	    }
	    push(@samstringsChunksLabeled, [ @returnL ]);
	  }
          sleep 10*$_;
	  while (`ps o state,command axh | egrep "perl.*filterMsamP.pl.*$MsamFile" | egrep -v "grep" | egrep "^[R]" | wc -l` > 0) {sleep 10*$_};
	  return @samstringsChunksLabeled; 
	});
}
else {
	@returnedChunkLabels = $pl->foreach( [0 .. $numprc-1], sub {
	  my @samstringsChunksLabeled = (); 
	  foreach my $samstring ( @{$samstringchunks[$_]} ) {
	    my @returnL = ( @$samstring[0] );
	    my @a = split( "\t", @$samstring[1] );
	    $mthstring = substr($a[13],5);
	    $logP = read_calls_probability($mthstring);
	    if ($logP < $logS  &&  $zxhcount < $fraction * $ZXHcount) {
	      push(@returnL, 1);
	    } else {
	      push(@returnL, 0);
	    }
	    my @a = split( "\t", @$samstring[2] );
	    $mthstring = substr($a[13],5);
	    $logP = read_calls_probability($mthstring);
	    if ($logP < $logS  &&  $zxhcount < $fraction * $ZXHcount) {
	      push(@returnL, 1);
	    } else {
	      push(@returnL, 0);
	    }
	    push(@samstringsChunksLabeled, [ @returnL ]);
	  }
	  sleep 10*$_;
	  while (`ps o state,command axh | egrep "perl.*filterMsamP.pl.*$Msamfile" | egrep -v "grep" | egrep "^[R]" | wc -l` > 0) {sleep 10*$_};
	  return @samstringsChunksLabeled; 
	});
}
my @sortedChunkLabels = sort { $a->[0] <=> $b->[0] } @returnedChunkLabels;

foreach ( 0 .. $numprc-1 ) {
  foreach my $samstring ( @{$samstringchunks[$_]} ) {
	$scnt++;
	my $v2 = shift @sortedChunkLabels;

	if ($paired == 0) {
	  if( $$v2[1] == 1) {
	    $f11cnt++;
	    print MSF11FILE "@$samstring[1]";
	  }
	  else {
	    $pcnt++;
	    print MSPFILE "@$samstring[1]";
	  }
	}

	else {	# ... paired
	  if( $$v2[1] == 1) {
	    if( $$v2[2] == 1) {
	      $f11cnt++;
	      print MSF11FILE "@$samstring[1]";
	      print MSF11FILE "@$samstring[2]";
	    }
	    else {
	      $f10cnt++;
	      print MSF10FILE "@$samstring[1]";
	      print MSF10FILE "@$samstring[2]";
	    }
	  } else {
	    if( $$v2[2] == 1) {
	      $f01cnt++;
	      print MSF01FILE "@$samstring[1]";
	      print MSF01FILE "@$samstring[2]";
	    }
	    else {
	      $pcnt++;
	      print MSPFILE "@$samstring[1]";
	      print MSPFILE "@$samstring[2]";
	    }
	  }
	}

	if ($scnt%1000000 == 0) {
	  printf STDERR "scnt= %12d: pcnt= %12d, fcnt11= %12d, fcnt01= %12d, fcnt10= %12d\n", $scnt, $pcnt, $f11cnt, $f01cnt, $f10cnt;
	}
}}


printf OUTFILE "\nThreshold:	logS=%12.2f\n", $logS;
printf OUTFILE "\nscnt=\t%12d", $scnt;
printf OUTFILE "\npcnt=\t%12d", $pcnt;
if ($paired == 0) {
  printf OUTFILE "\nfcnt=\t%12d\t(%6.2f%%)\n", $f11cnt, 100.0*$f11cnt/$scnt;
}
else {
  printf OUTFILE "\nf11cnt=\t%12d\t(%6.2f%%)\n", $f11cnt, 100.0*$f11cnt/$scnt;
  printf OUTFILE   "f01cnt=\t%12d\t(%6.2f%%)\n", $f01cnt, 100.0*$f01cnt/$scnt;
  printf OUTFILE   "f10cnt=\t%12d\t(%6.2f%%)\n", $f10cnt, 100.0*$f10cnt/$scnt;
}


close MSF11FILE;
if ($paired) {
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
