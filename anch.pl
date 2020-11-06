#!/usr/bin/perl -w
=head1 Info
    Script Author  : Yuan-SW-F, yuanswf@163.com
    Created Time   : 2020-07-09 13:00:47
    please prepare anchorNanme.list first
    Example: anch.pl sorted_alignment_file
=cut
use strict;
use feature qw(say);
use Getopt::Long;
my ($help);
GetOptions(
	"help!"=>\&USAGE,)
or USAGE();

open O1, "> seqids";
my %hash;
open IN,shift;
my @com;
my %check;
my @ref;
open O2, "> anchors";
while (<IN>){
	/((\S+)\-(common_\d+))/;
	$hash{$2}{$3} = $1;
	#say "$1\t$2\t$3";
	push @ref, $2 if ! exists $check{$2};
	push @com, $3 if ! exists $check{$3};
	$check{$2} = 1;
	$check{$3} = 1;
}

open O3, "> layout";
say O3 "# x,   y, rotation,   ha,     va,   color, ratio,            label";
#say O3 "# y, xstart, xend, rotation, color, label, va,  bed";
for my $i (@ref){
	say O1 $i;
} 

my $e;
my $k = 90;
my $nnn = shift;
@ref = split /\s+/,`cat anchorNanme.list`;
$nnn ||= $#ref+1;
for (0..$nnn-1){
	say O3 "0.65, 0.$k,        0, left, center,       m,     1,       $ref[$_]";
#	say O3 " .$k,    .1,     .8,     0,      ,  $ref[$_-1].bed, top, $ref[$_].bed";
	if ($_>0){
		$e .= "e, ";
		$e .= $_-1;
		$e .= ", $_\n";
	}
	$k -= 6;
}
print O3 $e;
for my $i (@com){
	print O2 $hash{$ref[0]}{$i};
	for my $j (@ref[1..$#ref]){
		print O2 exists $hash{$j}{$i} ? "\t$hash{$j}{$i}" : "\t.";
	}
	print O2 "\n";
}
######################### Sub Routines #########################
sub USAGE{
my $uhead=`pod2text $0`;
my $usage=<<"USAGE";
USAGE:
	perl $0
	--help	output help information to screen
USAGE
print $uhead.$usage;
exit;}
