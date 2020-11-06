#!/usr/bin/perl -w
=head1 Name
    anchors_resort.pl
Info
    Version Perl-pipline.1.0
    Author: Yuan-SW-F, yuanswf@163.com
    Created Time: 2018-04-28 13:24:31
    Created Version: anchors_resort.pl
Usage
    anchors_resort.pl	
=cut
use strict;
use feature qw(say);
#use lib '/home/***/lib';
use agric;
use Getopt::Long;
my ($block,$num,$bed1,$bed2,$anch,$help);
GetOptions(
	"bed1|1:s"=>\$bed1,
	"bed2|2:s"=>\$bed2,
	"anch:s"=>\$anch,
	"block|b!"=>\$block,
	"num:s"=>\$num,
	"help!"=>\$help
);
$num||=20;
$bed1||="Annona.bed";
$bed2||="Annona.bed";
$anch||="Annona.Annona.anchors";
my $sp1||=$1 if $bed1=~/(\w+)/;
my $sp2||=$1 if $bed2=~/(\w+)/;
my $sps1||=$1 if $bed1=~/(\w\w)/;
my $sps2||=$1 if $bed2=~/(\w\w)/;

die opth() if $help;


my %gene1 = bed($bed1);
my %gene2 = bed($bed2);

#my $pipath=path("Perl-pipline.1.0"); #$pipath/script/config.txt
my (%len1,%len2,%count1,%count2);

open IN,$anch;
	my %tmp;
	while (<IN>){
		next if /^\#/;
		my @l=split;
		$len1{$gene1{$l[0]}} = (! exists $tmp{$gene1{$l[0]}} || $l[2] > $tmp{$gene1{$l[0]}}) ? $l[2] : $tmp{$gene1{$l[0]}};
		$count1{$gene1{$l[0]}}+=1;
		$len2{$gene2{$l[1]}} = (! exists $tmp{$gene1{$l[0]}} || $l[2] > $tmp{$gene1{$l[0]}}) ? $l[2] : $tmp{$gene1{$l[0]}};
		$count2{$gene2{$l[1]}}+=1;
		$tmp{$gene1{$l[0]}}= (! exists $tmp{$gene1{$l[0]}} || $len1{$gene1{$l[0]}} > $tmp{$gene1{$l[0]}}) ? $len1{$gene1{$l[0]}} : $tmp{$gene1{$l[0]}};
	}
	
my (%chan1,%chan2);
my $i=0;
open OUT , ">$sp1.scaf1";

%len1= %count1 if $block;
%len2= %count2 if $block;

for (sort {$len1{$b} <=> $len1{$a}} keys %len1){
	
	say "$_\t$len1{$_}";
	say $i;
	last if $i == $num;
	$i++;
	$chan1{$_}="$sps1$i";
	say OUT "$_\t$chan1{$_}\t$len1{$_}";
}
my $j=0;
open OUT , ">$sp2.scaf2";
for (sort {$len2{$b} <=> $len2{$a}} keys %len2){
	last if $j == $num;
	$j++;
	if ($sps1 eq $sps2){
		if (exists $chan1{$_}){
			say OUT "$_\t$chan1{$_}\t$len1{$_}";
		}else{
			$i++;
			$chan2{$_}="$sps2$i";
			say OUT "$_\t$chan2{$_}\t$len2{$_}";
		}
	}else{
		$chan2{$_}="$sps2$j";	
		say OUT "$_\t$chan2{$_}";
	}
}

open IN,$bed1;
open OUT,">$sp1.bed.new1";
while (<IN>){
	my @line= split;
	if (exists $chan1{$line[0]}){
		$line[0]= $chan1{$line[0]};
		say OUT join "\t", @line,
	}
}
open OUT,">$sp2.bed.new2";
open IN,$bed2;
while (<IN>){
	my @line= split;
	if (exists $chan2{$line[0]}){
		$line[0]= $chan2{$line[0]};
		say OUT join "\t", @line,
	}
}

######################### Sub Routines #########################
sub bed
{
	my %hash;
	open IN,shift;
	while (<IN>){
		my @l=split;
		$hash{$l[3]} = $l[0];
	}
	%hash;
}

sub sorted
{
	my %hash=shift;
	my $i=0;
	my %scaf;
	for (sort {$b <=> $a} keys %hash){
		$scaf{$_}=1 if $i < $num;
		$i++;
	}
	%scaf;
}
