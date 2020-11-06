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
#use lib '/home/***/lib';
use agric;
use Getopt::Long;
my ($unknown,$block,$num,$bed1,$bed2,$anch,$change,$help);
GetOptions(
	"unknown"=>\$unknown,
	"change!"=>\$change,
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
my (%ck1,%ck2);
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
if ($change){
	if (exists $chan1{$scaf{$_}}){
		$chan2{$scaf{$_}}=$chan1{$_};
	}elsif(exists $chan2{$scaf{$_}}){
		$i-- && next;
	}else{
		$chan2{$scaf{$_}}="$sps2$j";
		$j++;
	}
}else{
	$chan2{$scaf{$_}}=$scaf{$_};
}
	#say $j;
	say OUT "$_\t$chan1{$_}\t$scaf{$_}\t$chan2{$scaf{$_}}\t$len{$_}\t$gid{$_}";
#	`rm $sp1.bed.n1` if -f "$sp1.bed.n1";
#	`rm $sp2.bed.n2` if -f "$sp2.bed.n2";
	my $tmpn1= ! exists $ck1{$_} ? `grep $_ $bed1` : "";# >> $sp1.bed.n1 `;
	$ck1{$_}=1;
	my $tmpn2= ! exists $ck2{$scaf{$_}} ? `grep $scaf{$_} $bed2` : "";# >> $sp2.bed.n2 `;
	$ck2{$scaf{$_}}=1;
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
	if (exists $chan2{$line[0]}){
		$line[0]= $chan2{$line[0]};
		say OUT join "\t", @line,
	}
}

my $new=1;
if ($new){
	my $note1="";
	my $note2="";
	my (%ckd1,%ckd2);
	for (split /\s+/,`awk '{print \$1}' $sp1.$sp2.anchors.new`){
		next if /\#/;
		next if ! $unknown && $gene1{$_} =~/know/;
		$note1.=`grep -P \"$gene1{$_}\\s\" $sp1.bed` if ! exists $ckd1{$gene1{$_}};# >> $sp1\-1.bed`;
		$ckd1{$gene1{$_}} = 1;
	}
	for (split /\s+/,`awk '{print \$2}' $sp1.$sp2.anchors.new`){
		next if /\#/;
		next if $_ !~ /\S+/;
		next if ! $unknown && $gene2{$_} =~/know/;
		$note2=`grep -P \"$gene2{$_}\\s\" $sp2.bed`.$note2 if ! exists $ckd2{$gene2{$_}};# >> $sp2\-2.bed`;
		$ckd2{$gene2{$_}}=1;
	}
	output("$sp1\-1.bed",$note1);
	output("$sp2\-2.bed",$note2);
	`ln -s $sp1.$sp2.anchors.new $sp1\-1.$sp2\-2.anchors`;
}
my (@seqids1,@seqids2);
if (1){
	my (%ckd1,%ckd2);
	for (split /\s+/,`awk '{print \$1}' $sp1.$sp2.anchors.simple`){
		`grep $_ $sp1.bed`=~/(\S+)/;
		next if exists $ckd1{$1};
		push @seqids1,$1;
		$ckd1{$1}=1;
	}
	for (split /\s+/,`awk '{print \$3}' $sp1.$sp2.anchors.simple`){
		`grep $_ $sp2.bed`=~/(\S+)/;
		next if exists $ckd2{$1};
		next if $1 eq "Unknow";
		push @seqids2,$1;
		$ckd2{$1}=1;
	}
}
my $seqids= join ",",@seqids1;
$seqids.="\n";
$seqids.= join ",",@seqids2;
$seqids.="\n";
output("seqids", $seqids);

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
