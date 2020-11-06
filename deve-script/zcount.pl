#!/usr/bin/perl -w
=head1 Info
    Script Author  : fuyuan, 907569282@qq.com
    Created Time   : 2019-09-24 08:57:04
    Example: zcount.pl
=cut
use strict;
use feature qw(say);
use Getopt::Long;
my ($help);
GetOptions(
	"help!"=>\&USAGE,)
or USAGE();

open IN,shift; #"sp.lt";
my @h;
while (<IN>){
	push @h, $1 if /(\S+)/;
	}

my %num;
open IN,shift;#"sp-81.list";
my $i = 0;
while (<IN>){
	/\*(\S+)/;
	$i += 1;
	$num{$1} = $i;
	}

my $file = shift;
open IN,$file;
my %c;
while (<IN>){
	chomp;
	my @l = split /\s+/,$_;
	for my $i (0..$#l){
		$c{$h[$i]} += $l[$i]=~/[A-Z0-9]/ ? 1 : 0;
		}
	}
my $head = "species";
my $count = $1 if $file =~ /([^\.]+)/;
for (sort {$num{$a} <=> $num{$b}} keys %num){
	 if (exists $c{$_}){
	 	$head .= "\t$_";
	 	$count .= "\t$c{$_}";
	 }
	}
say $head;
say $count;
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
