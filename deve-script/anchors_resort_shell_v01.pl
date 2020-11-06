#!/usr/bin/perl -w
=head1 Name
    anchors_resort_shell.pl
Info
    Version Perl-pipline.1.0
    Author: Yuan-SW-F, yuanswf@163.com
    Created Time: 2018-04-28 16:41:29
    Created Version: anchors_resort_shell.pl
Usage
    anchors_resort_shell.pl	
=cut
use strict;
use feature qw(say);
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
my %order1= order($bed1);
my %order2= order($bed2);
#my $pipath=path("Perl-pipline.1.0"); #$pipath/script/config.txt
my (%len,%count,%scaf,%chan1,%chan2,%gid,%gtm);
open IN,$anch;
my %tmp;
while (<IN>){
	next if /^\#/;
	my @l=split;
	
	if (! exists $tmp{$gene1{$l[0]}} || $l[2] > $tmp{$gene1{$l[0]}}){
		$len{$gene1{$l[0]}} = $l[2];
		$gid{$gene1{$l[0]}} = "$order1{$l[0]}\&$order2{$l[1]}";
	}else{
		$len{$gene1{$l[0]}} = $tmp{$gene1{$l[0]}};
	}
#	$len{$gene1{$l[0]}} = (! exists $tmp{$gene1{$l[0]}} || $l[2] > $tmp{$gene1{$l[0]}}) ? $l[2] : $tmp{$gene1{$l[0]}};
#	$gid{$gene1{$l[0]}}= (! exists $tmp{$gene1{$l[0]}} || $l[2] > $tmp{$gene1{$l[0]}}) ? "$l[0]\_$l[1]" : $gtm{$gene1{$l[0]}};
	$count{$gene1{$l[0]}}+=1;
	$scaf{$gene1{$l[0]}}=$gene2{$l[1]};
	$tmp{$gene1{$l[0]}}= (! exists $tmp{$gene1{$l[0]}} || $len{$gene1{$l[0]}} > $tmp{$gene1{$l[0]}}) ? $len{$gene1{$l[0]}} : $tmp{$gene1{$l[0]}};
#	$gtm{$gene1{$l[0]}}= (! exists $tmp{$gene1{$l[0]}} || $len{$gene1{$l[0]}} > $tmp{$gene1{$l[0]}}) ? $gid{$gene1{$l[0]}} : $gtm{$gene1{$l[0]}};
}

open OUT , ">$sp1.$sp2.scaf";
`cp $anch $sp1\_s1.$sp2\_s2.anchors`;
%len=%count if $block;
my ($i,$j)=(0,1);
`rm $sp1.bed.n1` if -f "$sp1.bed.n1";
`rm $sp2.bed.n2` if -f "$sp2.bed.n2";

my ($n1,$n2)=("","");
for (sort {$len{$b} <=> $len{$a}} keys %len){
	last if $i == $num;
	$i++;
	if (exists $chan2{$_}){
		$chan1{$_}=$chan2{$_};
	}elsif(exists $chan1{$_}){
	#	$i-- && next;
	}else{
		$chan1{$_}="$sps1$j";
		$j++;
	}
	if (exists $chan1{$scaf{$_}}){
		$chan2{$scaf{$_}}=$chan1{$_};
	}elsif(exists $chan2{$scaf{$_}}){
	#	$i-- && next;
	}else{
		$chan2{$scaf{$_}}="$sps2$j";
		$j++;
	}
	#say $j;
	say OUT "$_\t$chan1{$_}\t$scaf{$_}\t$chan2{$scaf{$_}}\t$len{$_}\t$gid{$_}";
#	`rm $sp1.bed.n1` if -f "$sp1.bed.n1";
#	`rm $sp2.bed.n2` if -f "$sp2.bed.n2";
	my $tmpn1=`grep $_ $bed1`;# >> $sp1.bed.n1 `;
	my $tmpn2=`grep $scaf{$_} $bed2`;# >> $sp2.bed.n2 `;
	$n1.=$tmpn1;
	$n2=$tmpn2.$n2;
}
output("$sp1.bed.n1",$n1);
output("$sp2.bed.n2",$n2);

open IN,"$bed1.n1";
open OUT,">$sp1\_s1.bed";
while (<IN>){
	my @line= split;
	if (exists $chan1{$line[0]}){
		$line[0]= $chan1{$line[0]};
		say OUT join "\t", @line,
	}
}
open OUT,">$sp2\_s2.bed";
open IN,"$bed2.n2";
while (<IN>){
	my @line= split;
#	say $line[0]."MMMM";
	if (exists $chan2{$line[0]}){
#	say "$line[0]\t".$chan2{$line[0]}."NNN";
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

sub order
{
	my %hash;
	open IN,shift;
	while (<IN>){
		my @l=split;
		$hash{$l[3]} = $l[-1];
	}
	%hash;
}
