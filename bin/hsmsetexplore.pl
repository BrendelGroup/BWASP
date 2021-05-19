#!/usr/bin/perl -w
#
use strict;
use Getopt::Std;
STDOUT->autoflush(1);
STDERR->autoflush(1);


#----------------------------------------------------------------------------------------------------
my $USAGE="\nUsage: $0 -s scdlist -h hsmlist -l labels -a nbrCpGsn -o outfile
         [-c mincvrg] [-C maxcvrg] [-p minpcnt] [-P maxpcnt] [-n minsmpl] [-w wsize]\n

** $0 will take as input two lists of files (scdlist = *scd.mcalls files; and
   hsmlist = *hsm.mcalls files) and a string of sample labels, then produce summary
   statistics for site coverage and methylation status. Sites filtered by multiple
   criteria are identified in output files <outfile>-<parameterstring>.bed and
   <outfile>-<parameterstring>.dtl.

   Also required are arguments to -a and -o to specify the total number of CpG sites in the
   genome being analyzed (from the BWASPR <species>.par parameter file) and an output file
   name, respectively.

   Optional arguments:
     -c mincvrg	=	minimal read coverage for sites to be included
     -C maxcvrg	=	maximal read coverage for sites to be included
     -p minpcnt	=	minimal methylation percentage for HH sites to be included
     -P maxpcnt	=	maximal methylation percentage for NN sites to be included
     -n minsmpl	=	minimal number of qualifying samples for sites to be included

   For example, -c 33 -C 330 -p 90 -P 4 -n 15 -w 25 will select sites that are covered
   by 33 to 330 reads in at least 15 samples; for HH sites (see below), each C is required
   to be at least <minpcnt> methylated; for NN sites, each C is required to be at most
   <maxpcnt> methylated.

   Output:
     <outfile>.stats                 = summary statistics
     <outfile>-<parameterstring>.bed = bedfile with columns 'sequence' 'from' 'to' 'type' 'position' 'strand'
     <outfile>-<parameterstring>.dtl = details of selected sites

   CpG sites are selected if both the C on the forward and the C on the reverse strand meet
   the criteria and are typed as 'NN-x' or 'HH-x' respectively if both Cs are not signficantly
   methylated (nsm by BWASPR) or both are significantly methylated (hsm by BWASPR).
   The <outfile>-<parameterstring>.dtl entries have seven lines per site. The first line gives
   'sequence' 'type' 'position' 'strand'. The next three lines show for all samples the status of
   the forward strand C, coverage (number of reads), and methylation percentage, followed by
   the analogous data for the reverse strand C. The site status is indicated by the following integers:
   
     0 = nsc	not sufficiently covered
     1 = scd	sufficently covered, detectable
     2 = hsm	highly significantly methylated

   and for the forward strand C further qualified as

     3 = nsm/nsm
     4 = hsm/hsm
     5 = hsm/nsm
     6 = nsm/hsm
     7 = nsc/nsc

   based on the status of the forward and reverse strand Cs.

   \n";


my %args;
my $scdfile = "";
my $hsmfile = "";
my $outfname = "";
my ($mincvrg, $maxcvrg, $minpcnt, $maxpcnt, $minsmpl, $wsize) = (0, 100000000, 0, 100, 1, 0);
my (%scdstatus, %scdcovrge, %scdprcntm);

getopts('s:h:l:a:o:c:C:p:P:n:w:', \%args);
if (!defined($args{s})) {
  print STDERR "\n!! Please specify an input scdlist file.\n\n";
  die $USAGE;
}
else {
  $scdfile = $args{s};
  if ( ! -e $scdfile ) {
    printf STDERR "\n!! scdlist file %s not found. Please check.\n\n", $scdfile;
    die $USAGE;
  }
}
if (!defined($args{h})) {
  print STDERR "\n!! Please specify an input hsmlist file.\n\n";
  die $USAGE;
}
else {
  $hsmfile = $args{h};
  if ( ! -e $hsmfile ) {
    printf STDERR "\n!! hsmlist file %s not found. Please check.\n\n", $hsmfile;
    die $USAGE;
  }
}
if (!defined($args{l})) {
  print STDERR "\n!! Please specify a string of labels.\n\n";
  die $USAGE;
}
my @labels= split(' ',$args{l});
if (!defined($args{a})) {
  print STDERR "\n!! Please specify the total number of CpGs in the genome.\n\n";
  die $USAGE;
}
my $allcpgs = $args{a};
if (!defined($args{o})) {
  print STDERR "\n!! Please specify an output file name.\n\n";
  die $USAGE;
}
else {
  $outfname = $args{o};
  open (OUTF, ">$outfname.stats");
}

if (defined($args{c})) {
  $mincvrg = $args{c};
}
if (defined($args{C})) {
  $maxcvrg = $args{C};
}
if (defined($args{p})) {
  $minpcnt = $args{p};
}
if (defined($args{P})) {
  $maxpcnt = $args{P};
}
if (defined($args{n})) {
  $minsmpl = $args{n};
}
if (defined($args{w})) {
  $wsize = $args{w};
}

open (IN, "<$scdfile");
chomp(my @scdfiles=<IN>);
close (IN);
open (IN, "<$hsmfile");
chomp(my @hsmfiles=<IN>);
close (IN);

if ( $#scdfiles != $#hsmfiles || $#hsmfiles != $#labels ) {
  print STDERR "\n!! The number of scd files ($#scdfiles) must be equal to the number of hsm files ($#hsmfiles) and the number of labels ($#labels).\n";
  print STDERR "Please check and correct.\n";
  die $USAGE;
}

my $bedfile = $outfname . "-c" . $mincvrg . "C" . $maxcvrg . "p" . $minpcnt . "P" . $maxpcnt . "n" . $minsmpl . "w" . $wsize . ".bed";
open (BEDF, ">$bedfile");
my $dtlfile = $outfname . "-c" . $mincvrg . "C" . $maxcvrg . "p" . $minpcnt . "P" . $maxpcnt . "n" . $minsmpl . "w" . $wsize . ".dtl";
open (DTLF, ">$dtlfile");


my @l;
my $nf = @scdfiles;
my @ba = (0) x $nf;

print  OUTF "hsmsetexplore.pl: Exploring the CpG methylome.\n\n";
printf OUTF "Input files chosen: scdlist = %s; hsmlist = %s\n", $scdfile, $hsmfile;
printf OUTF "Samples analyzed: @labels\n";
printf OUTF "Total number of CpGs: $allcpgs\n";
printf OUTF "Sites filter: mincvrg = %d; maxcvrg = %d; minpcnt = %d; maxpcnt = %d; minsmpl = %d\n",
 $mincvrg, $maxcvrg, $minpcnt, $maxpcnt, $minsmpl;
printf OUTF "Window size for site context: wsize = %d\n\n", $wsize;


my $l = 0;
for (my $i = 0; $i < $nf; $i++) {
  open INF,  "< $scdfiles[$i]" || die ("Cannot open file: $scdfiles[$i]");
  my $line=<INF>;
  
  print STDERR "... reading $scdfiles[$i] \n";
  my $lc = 0;
  while(defined($line=<INF>)){
    if ( ++$lc % 1000000 == 0 ) {print STDERR "... line $lc \n";}
    my @l = split(/\t/,$line);
    my $key = $l[1] . '#' . $l[2] . '#' . $l[3];
    if ( ! exists $scdstatus{$key} ) {
      my @tmpa = @ba;
      $tmpa[$i] = 1;
      $scdstatus{$key} = \@tmpa;
      my @tmpb = @ba;
      @tmpb = @ba;
      $tmpb[$i] = $l[4];
      $scdcovrge{$key} = \@tmpb;
      my @tmpc = @ba;
      @tmpc = @ba;
      $tmpc[$i] = $l[5];
      $scdprcntm{$key} = \@tmpc;
    }
    else {
      $scdstatus{$key}[$i] = 1;
      $scdcovrge{$key}[$i] = $l[4];
      $scdprcntm{$key}[$i] = $l[5];
    }
  }
  close (INF);
  print STDERR "... done with $scdfiles[$i] ($lc lines read)\n";
}
# ... now we have:
#
#  %scdstatus, which for each position that is scd in any sample gives an
#   array of length equal to the number of samples and values 0 if the site
#   is not scd in that sample and 1 otherwise
#
#  %scdcovrge, which for each position that is scd in any sample gives an
#   array of length equal to the number of samples and values 0 if the site
#   is not scd in that sample and number of reads covering the site otherwise
#
#  %scdprcntm, which for each position that is scd in any sample gives an
#   array of length equal to the number of samples and values 0 if the site
#   is not scd in that sample and percent methylation at the site otherwise


for (my $i = 0; $i < $nf; $i++) {
  open INF,  "< $hsmfiles[$i]" || die ("Cannot open file: $hsmfiles[$i]");
  my $line=<INF>;
  
  print STDERR "... reading $hsmfiles[$i] \n";
  my $lc = 0;
  while(defined($line=<INF>)){
    if ( ++$lc % 10000  == 0 ) {print STDERR "... line $lc \n";}
    my @l = split(/\t/,$line);
    my $key = $l[1] . '#' . $l[2] . '#' . $l[3];
    $scdstatus{$key}[$i] = 2;
  }
  close (INF);
  print STDERR "... done with $hsmfiles[$i] ($lc lines read)\n";
}
# ... now we have edited %scdstatus to the following:
#
#  %scdstatus gives for each position that is scd in any sample an array of
#   length equal to the number of samples and values 0 if the site is not scd
#   in that sample, 1 if the site is nsm, and 2 if the site is hsm
#


my ($anyscdsites, $anyhsmsites, $allscdsites, $allnsmsites, $allhsmsites) = (0) x 5;

foreach my $site (keys %scdstatus) {
  if ( ++$anyscdsites % 100000 == 0 ) {print STDERR "... processing site $anyscdsites \n";}
  my $m = 0;
  my $n = 0;
  for (my $i = 0; $i < $nf; $i++) {
    if ($scdstatus{$site}[$i] == 1) {++$m;} # ... number of nsm sites
    if ($scdstatus{$site}[$i] == 2) {++$n;} # ... number of hsm sites
  }
  if ( $n > 0 ) {
    $anyhsmsites++;
  }
  if ( $m + $n  == $nf ) {
    $allscdsites++;
    if ( $m == $nf ) {
      $allnsmsites++;
    }
    if ( $n == $nf ) {
      $allhsmsites++;
    }
  }
}
print STDERR "... done processing sites ($anyscdsites) \n";
printf OUTF "\nSite statistics:\n\n";
printf OUTF "Number of sites that are scd in at least one sample: %9d (%6.2f%% of all CpGs)\n", $anyscdsites, 100.*$anyscdsites/$allcpgs;
printf OUTF "Number of sites that are hsm in at least one sample: %9d (%6.2f%% of all scdCpGs)\n", $anyhsmsites, 100.*$anyhsmsites/$anyscdsites;
print  OUTF "\n";
printf OUTF "Number of sites that are scd in all         samples: %9d (%6.2f%% of all CpGs)\n", $allscdsites, 100.*$allscdsites/$allcpgs;
printf OUTF "Number of sites that are nsm in all         samples: %9d (%6.2f%% of all scdCpGs)\n", $allnsmsites, 100.*$allnsmsites/$allscdsites;
printf OUTF "Number of sites that are hsm in all         samples: %9d (%6.2f%% of all scdCpGs)\n", $allhsmsites, 100.*$allhsmsites/$allscdsites;
print  OUTF "\n";


my @scdscd = (0) x $nf;
my @nsmnsm = (0) x $nf;
my @hsmhsm = (0) x $nf;
my @hsmnsm = (0) x $nf;
my @nsmhsm = (0) x $nf;

my @nscnsc = (0) x $nf;
my @notbth = (0) x $nf;

my $sitesclassified = 0;
foreach my $site (sort keys %scdstatus) {
  if ( ++$sitesclassified % 100000 == 0 ) {print STDERR "... classifying site $sitesclassified \n";}
  my @sitedtls = split /#/, $site;
  if ( $sitedtls[2] eq 'F' ) {
    my $rsitepos = $sitedtls[1] + '1';
    my $rsite = $sitedtls[0] . '#' . $rsitepos . '#R';
    if ( exists $scdstatus{$rsite} ) {
      for (my $i = 0; $i < $nf; $i++) {
        if ( $scdstatus{$site}[$i] == 1 && $scdstatus{$rsite}[$i] == 1 ) {
          $nsmnsm[$i]++;
          $scdstatus{$site}[$i] = 3;
        } elsif ( $scdstatus{$site}[$i] == 2 && $scdstatus{$rsite}[$i] == 2 ) {
          $hsmhsm[$i]++;
          $scdstatus{$site}[$i] = 4;
        } elsif ( $scdstatus{$site}[$i] == 2 && $scdstatus{$rsite}[$i] == 1 ) {
          $hsmnsm[$i]++;
          $scdstatus{$site}[$i] = 5;
        } elsif ( $scdstatus{$site}[$i] == 1 && $scdstatus{$rsite}[$i] == 2 ) {
          $nsmhsm[$i]++;
          $scdstatus{$site}[$i] = 6;
        } elsif ( $scdstatus{$site}[$i] == 0 && $scdstatus{$rsite}[$i] == 0 ) {
          $nscnsc[$i]++;
          $scdstatus{$site}[$i] = 7;
        } else {
          $notbth[$i]++;
        }
        $scdscd[$i] = $nsmnsm[$i] + $hsmhsm[$i] + $hsmnsm[$i] + $nsmhsm[$i];
      }
    }
  }
}
print STDERR "... done classifying sites ($sitesclassified) \n";

my ($allscdscd, $allnsmnsm, $allhsmhsm, $allhsmnsm, $allnsmhsm) = (0) x 5;
print OUTF  "\nNumbers of CpGs in terms of forward strand C status / reverse strand C status:\n\n";
for (my $i = 0; $i < $nf; $i++) {
  printf OUTF "%s\tscdscd: %8d\t[= nsmnsm: %8d (%6.2f%%)\thsmhsm: %8d (%6.2f%%)\thsmnsm: %8d (%6.2f%%)\tnsmhsm: %8d (%6.2f%%)]\tnscnsc: %8d\tmixed %8d\n",
         $labels[$i], $scdscd[$i],
	 $nsmnsm[$i], 100*$nsmnsm[$i]/$scdscd[$i],
	 $hsmhsm[$i], 100*$hsmhsm[$i]/$scdscd[$i],
	 $hsmnsm[$i], 100*$hsmnsm[$i]/$scdscd[$i],
	 $nsmhsm[$i], 100*$nsmhsm[$i]/$scdscd[$i],
	 $nscnsc[$i], $notbth[$i];
  $allscdscd += $scdscd[$i];
  $allnsmnsm += $nsmnsm[$i];
  $allhsmhsm += $hsmhsm[$i];
  $allhsmnsm += $hsmnsm[$i];
  $allnsmhsm += $nsmhsm[$i];
}
printf OUTF "\nSum\tscdscd: %8d\t[= nsmnsm: %8d (%6.2f%%)\thsmhsm: %8d (%6.2f%%)\thsmnsm: %8d (%6.2f%%)\tnsmhsm: %8d (%6.2f%%)]\n",
         $allscdscd,
	 $allnsmnsm, 100*$allnsmnsm/$allscdscd,
	 $allhsmhsm, 100*$allhsmhsm/$allscdscd,
	 $allhsmnsm, 100*$allhsmnsm/$allscdscd,
	 $allnsmhsm, 100*$allnsmhsm/$allscdscd;
print OUTF "\n";


print STDERR "... now filtering the CpG hsm set according to the specified criteria\n";
#Using the filter options:
#
my $sitesfiltered = 0;
foreach my $fsite (sort keys %scdstatus) {
  if ( ++$sitesfiltered % 100000 == 0 ) {print STDERR "... filtering site $sitesfiltered \n";}
  my @fsitedtls = split /#/, $fsite;
  my $rsitedtls = $fsitedtls[1] + '1';
  my $rsite = $fsitedtls[0] . '#' . $rsitedtls . '#R';

  my $nsmplnn = 0;
  my $nsmplhh = 0;
  for (my $i = 0; $i < $nf; $i++) {
    if ( $scdstatus{$fsite}[$i] == 3 ) {	# ... selecting nsm/nsm CpGs	
      if ($scdcovrge{$fsite}[$i] >= $mincvrg && $scdcovrge{$fsite}[$i] <= $maxcvrg && $scdprcntm{$fsite}[$i] <= $maxpcnt &&
          $scdcovrge{$rsite}[$i] >= $mincvrg && $scdcovrge{$rsite}[$i] <= $maxcvrg && $scdprcntm{$rsite}[$i] <= $maxpcnt   ) {
        $nsmplnn++;
      }
    }
    if ( $scdstatus{$fsite}[$i] == 4 ) {	# ... selecting hsm/hsm CpGs	
      if ($scdcovrge{$fsite}[$i] >= $mincvrg && $scdcovrge{$fsite}[$i] <= $maxcvrg && $scdprcntm{$fsite}[$i] >= $minpcnt &&
          $scdcovrge{$rsite}[$i] >= $mincvrg && $scdcovrge{$rsite}[$i] <= $maxcvrg && $scdprcntm{$rsite}[$i] >= $minpcnt   ) {
        $nsmplhh++;
      }
    }
  }
  if ($nsmplnn >= $minsmpl) {	# ... at this point we should have captured qualified nsm/nsm CpG sites
    printf BEDF "%s\t%d\t%d\tNN-%d\t%d\t%s\n", $fsitedtls[0], $fsitedtls[1]-$wsize-1, $fsitedtls[1]+$wsize+1, $nsmplnn, $fsitedtls[1], $fsitedtls[2];

    printf DTLF "%s\tNN-%d\t%d\t%s\n", $fsitedtls[0], $nsmplnn, $fsitedtls[1], $fsitedtls[2];
    print  DTLF "@{$scdstatus{$fsite}}\n";
    print  DTLF "@{$scdcovrge{$fsite}}\n";
    print  DTLF "@{$scdprcntm{$fsite}}\n";
    print  DTLF "@{$scdstatus{$rsite}}\n";
    print  DTLF "@{$scdcovrge{$rsite}}\n";
    print  DTLF "@{$scdprcntm{$rsite}}\n";
  }
  if ($nsmplhh >= $minsmpl) {	# ... at this point we should have captured qualified hsm/hsm CpG sites
    printf BEDF "%s\t%d\t%d\tHH-%d\t%d\t%s\n", $fsitedtls[0], $fsitedtls[1]-$wsize-1, $fsitedtls[1]+$wsize+1, $nsmplhh, $fsitedtls[1], $fsitedtls[2];

    printf DTLF "%s\tHH-%d\t%d\t%s\n", $fsitedtls[0], $nsmplhh, $fsitedtls[1], $fsitedtls[2];
    print  DTLF "@{$scdstatus{$fsite}}\n";
    print  DTLF "@{$scdcovrge{$fsite}}\n";
    print  DTLF "@{$scdprcntm{$fsite}}\n";
    print  DTLF "@{$scdstatus{$rsite}}\n";
    print  DTLF "@{$scdcovrge{$rsite}}\n";
    print  DTLF "@{$scdprcntm{$rsite}}\n";
  }
}
print STDERR "... done filtering sites ($sitesfiltered) \n";
