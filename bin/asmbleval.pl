#!/usr/bin/env perl
#
#asmbleval.pl
# - a simple Perl script to report basic assembly statistics on a
#   BWASP workflow entering *.fa FASTA-formatted genome file.
#
#   Contributed by Daniel Standage
use strict;
 
$/ = ">";
<STDIN>; # Discard "junk", if any, at beginning of the file.
 
my @sequencelengths;
my $gccontent = 0;
my $atcontent = 0;
my $combinedlength = 0;
while(my $record = <STDIN>)
{
  chomp($record);
  my ($defline, @seqlines) = split(/\n/, $record);
  my $sequence = join("", @seqlines);
 
  my $gc = $sequence =~ tr/GCSgcs//;
  my $at = $sequence =~ tr/ATWatw//;
  $gccontent += $gc;
  $atcontent += $at;
 
  $combinedlength += length($sequence);
  push(@sequencelengths, length($sequence));
}
 
my $n50 = 0;
my $n90 = 0;
my $templength = $combinedlength;
my $combinedlength50perc = $combinedlength * 0.5;
my $combinedlength10perc = $combinedlength * 0.1;
 
@sequencelengths = sort {$b<=>$a} @sequencelengths;
foreach my $len(@sequencelengths)
{
  if($n50 == 0 and $templength - $len < $combinedlength50perc)
  {
    $n50 = $len;
  }
  if($templength - $len < $combinedlength10perc)
  {
    $n90 = $len;
    last;
  }
  $templength -= $len;
}
 
report("%-25s %d bp\n", "Combined length:", $combinedlength);
report("%-25s %.2lf%%\n", "Percent GC content:", $gccontent / ($gccontent+$atcontent) * 100);
report("%-25s %d\n", "Number of sequences:", scalar(@sequencelengths));
report("%-25s %.2lf bp\n", "Mean sequence length:", $combinedlength / scalar(@sequencelengths));
report("%-25s %d bp\n", "Sequence n50:", $n50);
report("%-25s %d bp\n", "Sequence n90:", $n90);
report("%-25s %d bp\n", "Longest sequence:", $sequencelengths[0]);
 
sub report
{
  my($format, @args) = @_;
  my $string = sprintf($format, @args);
  $string =~ s{(\: +)}{ my $per = "." x length($1); qq{ $per }}e;
  print($string);
}
