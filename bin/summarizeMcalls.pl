#!/usr/bin/perl
#
# summarizeMcalls
#  - BWASP Perl script to filter Msam records

=begin comment

Latest version: May 17, 2023	Author: Volker Brendel (vbrendel@indiana.edu)

This is a helper script to xfilterMsam. It reads all files chunk_MsamFile.*summary
in the current directory and produces the cumulated counts of passed and failed
reads in output file MsamFile-round.summary.
Here MsamFile is the input SAM file being filtered and round is the index of the
filtering cycle; see xfilterMsam for details.
--p or --s must be specified to indicated paired-end or single read input.

=cut


# Libraries and pragmas
use strict;
use Getopt::Long;
use Math::BigFloat ':constant';

# Set command line usage
my $usage = "
Usage: summarizeMcalls <options> --p|--s MsamFile

  MsamFile               Mandotory Msam file
  --p|--s                Specify either --p or --s for paired-end or single read SAM input
  --round=i              Filtering round [1 or larger]
  --help                 Print this help message and exit

";

# Get options from the command line
my $MsamFile    = '';
my $paired      = '';
my $single      = '';
my $round       = 1;
my $help        = '';

GetOptions(
    "p"              => \$paired,
    "s"              => \$single,
    "round=i"        => \$round,
    "help"           => \$help
);

if ($help || $paired eq $single) { printf( STDERR $usage ); exit; }

my $MsamFile = $ARGV[-1]
  or die("\n\nError: Please provide MsamFile as input.\n$usage $!");
my $outpfile = $MsamFile ."-" . $round . ".summary";
open( OUTFILE, "> $outpfile" );

opendir(DIR, "./");
my @files = grep{ /chunk\_${MsamFile}.*summary/ } readdir(DIR);
closedir(DIR);

my $cnt = 0;
my ($scnt, $pcnt, $f11cnt, $f01cnt, $f10cnt, $fcnt)  = (0,0,0,0,0,0);

my $ff = 1;
foreach my $file (@files) {
   open (CHUNKFH, "< $file" );

   my $line = <CHUNKFH>; if ($ff == 1) {print OUTFILE $line;}
   my $line = <CHUNKFH>; if ($ff == 1) {print OUTFILE $line;}
   my $line = <CHUNKFH>; if ($ff == 1) {print OUTFILE $line;}
   my $line = <CHUNKFH>; if ($ff == 1) {print OUTFILE $line;}
   my $line = <CHUNKFH>; if ($ff == 1) {print OUTFILE $line;}
   my $line = <CHUNKFH>; if ($ff == 1) {$ff = 0;}

   my $line = <CHUNKFH>;
   my ($cnt) = ($line =~ /scnt=\s+(\d+)/);
   $scnt += $cnt;
   my $line = <CHUNKFH>;
   my ($cnt) = ($line =~ /pcnt=\s+(\d+)/);
   $pcnt += $cnt;

   if ($paired ne '') {
     my $line = <CHUNKFH>;
     my ($cnt) = ($line =~ /f11cnt=\s+(\d+)/);
     $f11cnt += $cnt;
     my $line = <CHUNKFH>;
     my ($cnt) = ($line =~ /f01cnt=\s+(\d+)/);
     $f01cnt += $cnt;
     my $line = <CHUNKFH>;
     my ($cnt) = ($line =~ /f10cnt=\s+(\d+)/);
     $f10cnt += $cnt;
   }
   else {
     my $line = <CHUNKFH>;
     my ($cnt) = ($line =~ /fcnt=\s+(\d+)/);
     $fcnt += $cnt;
   }
}

printf OUTFILE "\nscnt=\t%12d", $scnt;
printf OUTFILE "\npcnt=\t%12d", $pcnt;
if ($paired ne '') {
  printf OUTFILE "\nf11cnt=\t%12d\t(%6.2f%%)\n", $f11cnt, 100.0*$f11cnt/$scnt;
  printf OUTFILE   "f01cnt=\t%12d\t(%6.2f%%)\n", $f01cnt, 100.0*$f01cnt/$scnt;
  printf OUTFILE   "f10cnt=\t%12d\t(%6.2f%%)\n", $f10cnt, 100.0*$f10cnt/$scnt;
}
else {
  printf OUTFILE "\nfcnt=\t%12d\t(%6.2f%%)\n", $fcnt, 100.0*$fcnt/$scnt;
}
