#!/usr/bin/perl -w
#
use strict;
use Getopt::Std;


#------------------------------------------------------------------------------
my $USAGE="\nUsage: $0 -s scdlist -h hsmlist\n

** $0 will take as input two lists of files (scdlist = *scd.mcalls files; and
   hsmlist = *hsm.mcalls files) and then produce a summary of which sites are methylated
   in which sets of samples compared to not being methylated in the complementary sets.

   Sample usage:

   hsmsetcmp.pl -s scdlist -h hsmlist                                                  > hsmSetsCompared
   cat <(head -n 8 hsmSetsCompared) <(tail -n +9 hsmSetsCompared | sort -t':' -k4 -nr) > hsmSetsOrdered

   \n";


my %args;
getopts('s:h:', \%args);

if (!defined($args{s})) {
  print "\n!! Please specify an input scdlist file.\n\n";
  die $USAGE;
}
my $scdfile = $args{s};
if (!defined($args{h})) {
  print "\n!! Please specify an input hsmlist file.\n\n";
  die $USAGE;
}
my $hsmfile = $args{h};

my %scdmatrix;
my @l;

open (IN, "<$scdfile");
chomp(my @scdfiles=<IN>);
close (IN);
open (IN, "<$hsmfile");
chomp(my @hsmfiles=<IN>);
close (IN);


my $nf = @scdfiles;
my @ba = (0) x $nf;


my $l = 0;
for (my $i = 0; $i < $nf; $i++) {
  open INF,  "< $scdfiles[$i]" || die ("Cannot open file: $scdfiles[$i]");
  my $line=<INF>;
  
  print STDERR "... reading $scdfiles[$i] \n";
  my $lc = 0;
  while(defined($line=<INF>)){
    if ( ++$lc % 100000 == 0 ) {print STDERR "... line $lc \n";}
    my @l = split(/\t/,$line);
    if ( ! exists $scdmatrix{$l[0]} ) {
      my @tmpa = @ba;
      $tmpa[$i] = 1;
      $scdmatrix{$l[0]} = \@tmpa;
    }
    else {
      $scdmatrix{$l[0]}[$i] = 1;
    }
  }
  close (INF);
}

for (my $i = 0; $i < $nf; $i++) {
  open INF,  "< $hsmfiles[$i]" || die ("Cannot open file: $hsmfiles[$i]");
  my $line=<INF>;
  
  print STDERR "... reading $hsmfiles[$i] \n";
  my $lc = 0;
  while(defined($line=<INF>)){
    if ( ++$lc % 10000  == 0 ) {print STDERR "... line $lc \n";}
    my @l = split(/\t/,$line);
    $scdmatrix{$l[0]}[$i] = 2;
  }
  close (INF);
}
  
my %patcount;

foreach my $site (keys %scdmatrix) {
  my $m = 0;
  my $n = 0;
  my $pat = "p";
  for (my $i = 0; $i < $nf; $i++) {
    if ($scdmatrix{$site}[$i] == 1) {++$m;                    } # ... number of nsm sites
    if ($scdmatrix{$site}[$i] == 2) {++$n; $pat = $pat . "$i";} # ... number of hsm sites
  }
  if ( $m +$n  == 8           ) {
    if ( ! exists $patcount{$pat} ) {
      $patcount{$pat} = 1;
    }
    else {
      ++$patcount{$pat};
    }
  }
}


my @a = (0, 1, 2, 3, 4, 5, 6, 7);
my @labels = ( 'BA1', 'BA2', 'BB1', 'BB2', 'RA1', 'RA2', 'RB1', 'RB2' );
my @tmp = ();
my $cpattern = "p";

print "Occurrence of patterns of hsm sites versus nsm sites.\n";
print "x-y: x samples are hsm, y samples are nsm.\n";
print "Sample sets compared are as shown (by numerical and synonym labels).\n";
print "cCounts are the counts for the complementary comparison.\n";
print "sCounts are the symmetrized counts, i.e. the number of sites\n";
print "that are all hsm in one set and all nsm in the other, or the other way around.\n\n\n";

foreach my $pattern (sort keys %patcount) {
  my @parts = split //, $pattern;
  shift @parts;
  @tmp = @a;
  foreach my $letter (@parts) {
    for (my $i = 0; $i < $nf; $i++) {
      if ( $tmp[$i] == $letter ) { $tmp[$i]-= 2*$nf; }
    }
  }
  $cpattern = "p";
  for (my $i = 0; $i < $nf; $i++) {
    if ( $tmp[$i] >= 0 ) { $cpattern = $cpattern . "$i";}
  }

  print length($pattern)-1, "-", length($cpattern)-1, "\t$pattern\t";
  foreach my $letter (@parts) {
   print "${labels[$letter]} ";
  }
  print "\tvs. ";
  print $cpattern, "\t";
  @parts = split //, $cpattern;
  shift @parts;
  foreach my $letter (@parts) {
    print "${labels[$letter]} ";
  }
  printf "\tCount: %8d\tcCount: %8d\tsCount: %8d\n",
	 $patcount{$pattern}, $patcount{$cpattern},
	 $patcount{$pattern}+$patcount{$cpattern};
}
