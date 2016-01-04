#!/usr/bin/perl
#mergeCreports.pl
# - a Perl script to combine two Bismark Creport files from two different read samples
#   mapped to the same genome

=begin comment


Latest version: February 15, 2015

=cut

# Libraries and pragmas
use strict;
use Getopt::Long;

# Set command line usage
my $usage = "
Usage: mergeCreports.pl <options> Creport1 Creport2

  Creport1               Mandotory Creport file 1
  Creport2               Mandotory Creport file 2
  --outfile=STRING	 Merged Creport output file name (Creport12 by default)
  --help                 Print this help message and exit

";

# Get options from the command line
my $Creport1    = "";
my $Creport2    = "";
my $outfile     = "Creport12";
my $help        = '';

GetOptions(
    "outfile=s"      => \$outfile,
    "help"           => \$help
);

if ($help) { printf( STDERR $usage ); exit; }

my $Creport1 = shift(@ARGV)
  or die("\n\nError: Please provide Creport1 file as input.\n$usage $!");
if ( !-e $Creport1 ) {
    die("\n\nError: Creport file $Creport1 does not exist.\n$usage $!");
}

my $Creport2 = shift(@ARGV)
  or die("\n\nError: Please provide Creport2 file as input.\n$usage $!");
if ( !-e $Creport2 ) {
    die("\n\nError: Creport file $Creport2 does not exist.\n$usage $!");
}
  

printf( STDERR "\nRunning mergeCreports.pl with the following options:
  Creport1     = %s
  Creport2     = %s
  outfile      = %s
", $Creport1, $Creport2, $outfile
) if (1);

#
#
my ( $ln1, $ln2, @a, @b );

open( C1FILE, "< $Creport1" );
open( C2FILE, "< $Creport2" );
open( C12FILE, "> $outfile" );

while ( $ln1 = <C1FILE> ) {
        @a = split( "\t", $ln1 );
	$ln2 = <C2FILE>;
        @b = split( "\t", $ln2 );
#	foreach (@a) {print $_, "\t"};
#	foreach (@b) {print $_, "\t"};
	if ($a[0] ne $b[0]  ||  $a[1] != $b[1]) {
		print "Error: $a[0] $a[1] != $b[0] $b[1]. This should not happen.\n";	
		print "  Please check that the Creport input files are compatible.\n\n";
		close C1FILE;
		close C2FILE;
		close C12FILE;
		die("aborting");
	}
	print C12FILE "$a[0]\t$a[1]\t$a[2]\t", $a[3]+$b[3], "\t", $a[4]+$b[4], "\t$a[5]\t$a[6]";
}
close C1FILE;
close C2FILE;
close C12FILE;
