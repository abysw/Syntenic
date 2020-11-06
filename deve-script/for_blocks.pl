#!/usr/bin/perl -w
=head1 Name
    /hwfssz1/ST_AGRIC/LOCAL/Pipline/Perl-pipline.1.0/06.synteny/bin/for_blocks.pl
Info
    Version Perl-pipline.1.0
    Author: st_agric (FuYuan), fuyuan@genomics.cn
    Created Time: 2018-05-08 17:14:57
    Created Version: for_blocks.pl
Usage
    for_blocks.pl	
=cut
use strict;
use feature qw(say);
use lib '/home/st_agric/lib';
use agric;
use Getopt::Long;
my ($help);
GetOptions(
	"help!"=>\$help
);
die opth() if $help;

#my $pipath=path("Perl-pipline.1.0"); #$pipath/script/config.txt
open IN,shift;
$/="###";
<IN>;
my $i=1;
my $j="";
my %hash;
my %h;
my %ck;
while (<IN>){
	my @l=split /\n/,$_;
	for (@l){
		next if $_=~/#/;
		next if $_!~/\S+/;
		$_=$1 if /(\S+)/;
		$j= exists $hash{$_} ? $hash{$_} : "";
#		$hash{$_} if exists $hash{$_};
	}
	if ($j eq ""){
		for (@l){
		next if $_=~/#/;
		next if $_!~/\S+/;
			$hash{$_} = "block_$i";
			push @{$h{$hash{$_}}},$_ if ! exists $ck{$_};
			$ck{$_}=1;
		}
		$j="";
		$i++;
	}else{
		for (@l){
			next if $_=~/#/;
			next if $_!~/\S+/;
			push @{$h{$j}},$_ if ! exists $ck{$_};
			$ck{$_}=1;
		}
		$j="";
	}
}

my $m;
for (1..$i){
#	say "block_$_\t".join ",",@{$h{"block_$_"}};
	 $m+=@{$h{"block_$_"}};
#	say $i;
}
say $m;
######################### Sub Routines #########################
