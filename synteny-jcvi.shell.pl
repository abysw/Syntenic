#!/usr/bin/perl -w
=head1 Name
    synteny-jcvi.shell.pl
Info
    Version Perl-pipline.1.0
    Author: Yuan-SW-F, yuanswf@163.com
    Created Time: 2018-04-27 16:00:15
    Created Version: synteny-jcvi.shell.pl
Usage
    synteny-jcvi.shell.pl	
=cut
use strict;
use feature qw(say);
#use lib '/home/***/lib';
use agric;
use Getopt::Long;
my ($help,$force,$second,$sp1,$sp2,$cds1,$cds2,$gff1,$gff2,$out,$minspan);
GetOptions(
	"sp1:s"=>\$sp1,
	"sp2:s"=>\$sp2,
	"cds1:s"=>\$cds1,
	"cds2:s"=>\$cds2,
	"gff1:s"=>\$gff1,
	"gff2:s"=>\$gff2,
	"out:s"=>\$out,
	"second|s!"=>\$second,
	"force!"=>\$force,
	"minspan:i"=>\$minspan,
	"help!"=>\$help
);
$cds1||=shift;
$cds2||=shift;
$minspan||=30;
my $bin="path/Sytenic/";
die "please prepare the cds files\nor run python -m jcvi.apps.fetch phytozome sp1,sp2" if -z $cds1;
die "please prepare the cds files\nor run python -m jcvi.apps.fetch phytozome sp1,sp2" if -z $cds2;
$cds1="./$cds1" if $cds1!~/^\//;
$cds1=~/(\S+\/([A-Za-z]+\_[A-Za-z]+)\w*)[^\/]+$/;
$sp1 =$2;
$gff1=$1 if `ls $1*gff*`=~/(\S+)/;
$cds2="./$cds2" if $cds2!~/^\//;
$cds2=~/(\S+\/([A-Za-z]+\_[A-Za-z]+)\w*)[^\/]+$/;
$sp2 =$2;
$gff2=$1 if `ls $1*gff*`=~/(\S+)/;

$out||="$sp1-$sp2";
mkdir $out if ! -f $out;
#die "please set --force " if (! -f $cds1 && ! -f $cds2 );
my $pwd=$1 if `pwd`=~/(\S+)/;
`less $cds1 |perl -ne 's/(\>\\S+).*/\$1/;print \$_' > $pwd/$out/$sp1\_raw.cds`;
#`less $cds1 |perl -ne 's/(\>[^\.]+).*/\$1/;print \$_' > $pwd/$out/$sp1\_raw.cds`;
$cds1="$pwd/$out/$sp1\_raw.cds";
`less $cds2 |perl -ne 's/(\>\\S+).*/\$1/;print \$_' > $pwd/$out/$sp2\_raw.cds`;
#`less $cds2 |perl -ne 's/(\>[^\.]+).*/\$1/;print \$_' > $pwd/$out/$sp2\_raw.cds`;
$cds2="$pwd/$out/$sp2\_raw.cds";
`less $gff1 |perl -ne 's/(=\\S+).*/\$1/;print \$_' > $pwd/$out/$sp1\_raw.gff`;
#`less $gff1 |perl -ne 's/(=[^\.]+).*/\$1/;print \$_' > $pwd/$out/$sp1\_raw.gff`;
$gff1="$pwd/$out/$sp1\_raw.gff";
`less $gff2 |perl -ne 's/(=\\S+).*/\$1/;print \$_' > $pwd/$out/$sp2\_raw.gff`;
#`less $gff2 |perl -ne 's/(=[^\.]+).*/\$1/;print \$_' > $pwd/$out/$sp2\_raw.gff`;
$gff2="$pwd/$out/$sp2\_raw.gff";
my $change=  $sp1 eq $sp2 ? "-ch" : ""; 
die opth() if $help;

#my $pipath=path("Perl-pipline.1.0"); #$pipath/script/config.txt

output("$out/synteny-jcvi-setp1.sh","#!/bin/bash
source ~/.bashrc
export PATH=/public/pip-yuan/local/bin:\$PATH
export PATH=/public/software/gcc-6.4.0/bin:\$PATH
export LD_LIBRARY_PATH=/public/software/gcc-6.4.0/lib64:\$LD_LIBRARY_PATH
#python -m jcvi.apps.fetch phytozome $sp1,$sp2
#mkdir synteny-jcvi ; cd synteny-jcvi ;
python -m jcvi.formats.gff bed --type=mRNA --key=ID $gff1 -o $sp1.bed
python -m jcvi.formats.gff bed --type=mRNA --key=ID $gff2 -o $sp2.bed
python -m jcvi.formats.fasta format --sep=\"\|\" $cds1 $sp1.cds
python -m jcvi.formats.fasta format --sep=\"\|\" $cds2 $sp2.cds

python -m jcvi.compara.catalog ortholog $sp1 $sp2 > ../synteny.log");

output("$out/synteny-jcvi.sh","#!/bin/bash
source ~/.bashrc
export PATH=/public/yuan/local/bin:\$PATH
export PATH=/public/software/gcc-6.4.0/bin:\$PATH
export LD_LIBRARY_PATH=/public/software/gcc-6.4.0/lib64:\$LD_LIBRARY_PATH
#python -m jcvi.apps.fetch phytozome $sp1,$sp2
mkdir synteny-jcvi ; cd synteny-jcvi ;
python -m jcvi.formats.gff bed --type=mRNA --key=ID $gff1 -o $sp1.bed
python -m jcvi.formats.gff bed --type=mRNA --key=ID $gff2 -o $sp2.bed
python -m jcvi.formats.fasta format --sep=\"\|\" $cds1 $sp1.cds
python -m jcvi.formats.fasta format --sep=\"\|\" $cds2 $sp2.cds

python -m jcvi.compara.catalog ortholog $sp1 $sp2 > ../synteny.log
python -m jcvi.graphics.dotplot $sp1.$sp2.anchors
python -m jcvi.compara.synteny depth --histogram $sp1.$sp2.anchors
python -m jcvi.compara.synteny screen --minspan=$minspan --simple $sp1.$sp2.anchors $sp1.$sp2.anchors.new
### sort
anchors_resort_shell.pl --num 30 --bed1 $sp1.bed --bed2 $sp2.bed --anch $sp1.$sp2.anchors $change -b 
python -m jcvi.graphics.dotplot $sp1\_s1.$sp2\_s2.anchors --nosort
mv $sp1\_s1.$sp2\_s2.pdf $sp1\_s1.$sp2\_s2-b.pdf
anchors_resort_shell.pl --num 30 --bed1 $sp1.bed --bed2 $sp2.bed --anch $sp1.$sp2.anchors $change 
python -m jcvi.graphics.dotplot $sp1\_s1.$sp2\_s2.anchors --nosort
mv $sp1\_s1.$sp2\_s2.pdf $sp1\_s1.$sp2\_s2-l.pdf
python -m jcvi.graphics.dotplot $sp1\-1.$sp2\-2.anchors --nosort
python -m jcvi.graphics.karyotype seqids layout
cp *pdf ..
synteny-jcvi_stat.pl synteny.log
python -m jcvi.compara.synteny mcscan $sp1.bed $sp1.$sp2.lifted.anchors --iter=1 -o $sp1.$sp2.i1.blocks
head -50 $sp1.$sp2.i1.blocks > blocks
#blocks.layout   ### fill in 
cat $sp1.bed $sp2.bed > $sp1\_$sp2.bed
#python -m jcvi.graphics.synteny blocks $sp1\_$sp2.bed blocks.layout
echo \"\# x,   y, rotation,   ha,     va,   color, ratio,            label\n0.5, 0.6,        0, left, center,       m,     1,       $sp1 id1\n0.5, 0.4,        0, left, center, #fc8d62,     1, $sp2 id2\n# edges\ne, 0, 1\" > blocks.layout 
python -m jcvi.graphics.synteny blocks $sp1\_$sp2.bed blocks.layout

mkdir ../second ; cd ../second ;
ln -s ../synteny-jcvi/$sp1.bed ../synteny-jcvi/$sp2.bed ../synteny-jcvi/$sp1.cds ../synteny-jcvi/$sp2.cds . 
python -m jcvi.compara.catalog ortholog $sp1 $sp2 --cscore=.99 synteny.log2
python -m jcvi.graphics.dotplot $sp1.$sp2.anchors
python -m jcvi.compara.synteny depth --histogram $sp1.$sp2.anchors
python -m jcvi.compara.synteny screen --minspan=$minspan --simple $sp1.$sp2.anchors $sp1.$sp2.anchors.new
### sort
anchors_resort_shell.pl --num 30 --bed1 $sp1.bed --bed2 $sp2.bed --anch $sp1.$sp2.anchors $change -b
python -m jcvi.graphics.dotplot $sp1\_s1.$sp2\_s2.anchors --nosort
mv $sp1\_s1.$sp2\_s2.pdf $sp1\_s1.$sp2\_s2-b.pdf
anchors_resort_shell.pl --num 30 --bed1 $sp1.bed --bed2 $sp2.bed --anch $sp1.$sp2.anchors $change
python -m jcvi.graphics.dotplot $sp1\_s1.$sp2\_s2.anchors --nosort
mv $sp1\_s1.$sp2\_s2.pdf $sp1\_s1.$sp2\_s2-l.pdf
python -m jcvi.graphics.dotplot $sp1\-1.$sp2\-2.anchors --nosort
cp $sp1.$sp2.pdf ../$sp1.$sp2-fin.pdf
cp $sp1.$sp2.depth.pdf ../$sp1.$sp2.depth-fin.pdf
cp $sp1-1.$sp2-2.pdf ../$sp1-1.$sp2-2-fin.pdf
cp $sp1\_s1.$sp2\_s2-b.pdf ../$sp1\_s1.$sp2\_s2-b-fin.pdf
cp $sp1\_s1.$sp2\_s2-l.pdf ../$sp1\_s1.$sp2\_s2-l-fin.pdf

python -m jcvi.graphics.karyotype seqids ../layout
synteny-jcvi_stat.pl synteny.log2
");
#output("$out/synteny-jcvi2.sh", if $second;
output("$out/layout","# y, xstart, xend, rotation, color, label, va,  bed
 .6,	.1,	.8,	0,	, $sp1, top, $sp1-1.bed
 .4,	.1,	.8,	0,	, $sp2, top, $sp2-2.bed
# edges
e, 0, 1, $sp1.$sp2.anchors.simple
")

######################### Sub Routines #########################
