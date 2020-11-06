#!/usr/bin/perl -w
=head1 Name
    4dtv_shell.pl
Info
    Version Perl-pipline.1.0
    Author: Yuan-SW-F, yuanswf@163.com
    Created Time: 2018-04-07 23:04:13
    Created Version: 4dtv_shell.pl
Usage
    4dtv_shell.pl	
=cut
use strict;
use feature qw(say);
#use lib '/home/***/lib';
use agric;
use Getopt::Long;
my ($help);
GetOptions(
	"help!"=>\$help
);
die opth() if $help;

#my $pipath=path("Perl-pipline.1.0"); #$pipath/script/config.txt
my $file=shift;
my ($sh,$sp1,$sp2)=($1,$2,$3) if $file=~/(\S+\/)(\w+)\-(\w+)\.collinearity/;
#say $sh;
mkdir "$sp1-$sp2";
chdir "$sp1-$sp2";
$sh= $sh."mcscanx.sh";
my $gff=$1 if `less  $sh`=~/cat\s+([^\|]+)\|/;
my $blast="$1.besthit.blast" if `less  $sh`=~/ln -s (\S+).blastp/
$gff=~s/\s+$//;
my @pep=split /\s+/,$gff;
for (@pep){
	$_=~s/.gff$//;
}
my ($spe1,$spe2,$paralog,$ortholog);
if (@pep == 2){
	($spe1,$spe2)=@pep;
	$paralog="paralog=false";
	$ortholog="ortholog=true";
}elsif(@pep == 1){
	($spe1,$spe2)=($pep[0],$pep[0]);
	$paralog="paralog=true";
	$ortholog="ortholog=false";
}

my ($spg1,$spg2)=($spe1,$spe2);
$spg1=~s/\_gene/\_genome.fa/;
$spg2=~s/\_gene/\_genome.fa/;

output("config.ini","#configuration file
spec_A=$sp1
spec_B=$sp2
4dtv_blast_plot=true
4dtv_mcscan_plot=true
Ks_distribution_plot=true
Ka_distribution_plot=true
KaDKs_distribution_plot=true
dotplot_blast=true
dotplot_mcscan=true
blast_similarity_plot=false

$paralog
$ortholog
pep1=$spe1.pep
pep2=$spe2.pep
cds1=$spe1.cds
cds2=$spe2.cds

[4dtv_blast_plot_section]
4dtv_blast_file=$blast
4dtv_blast_plot_outdir=./4dtv_blast_plot
scale=0.01

[4dtv_mcscan_plot_section]
4dtv_mcscan_file=$file
4dtv_mcscan_plot_outdir=./4dtv_mcscan_plot
scale=0.01

[Ka_Ks_KaDKs_plot_section]
KaKs_blast_file=$file.gene_pair
KaKs_outdir=./KaKs_mcscan
scale=0.01

[dotplot_blast_section]
dotplot_blast_file=$blast
dotplot_blast_outdir=./dotplot_blast
gff1=$spe1.gff
gff2=$spe2.gff
size1=$sp1.size
size2=$sp2.size

[dotplot_mcscan_section]
dotplot_mcscan_file=$file
dotplot_mcscan_outdir=./dotplot_mcscan
Nnum=5
type=gene-pair

gff1=$spe1.gff
gff2=$spe2.gff
size_save=50
size1=$sp1.size
size2=$sp2.size

[blast_similarity_plot_section]
similarity_blast_file=$blast
similarity_blast_outdir=./similarity_blast_distribution
scale=0.01
Graph_type=histogram
");
output("plot_4dtv.sh","# fa-size
faSize $spg1 -detailed |sort -k2,2nr |sed -n \'1,50p\' >$sp1.size;
faSize $spg2 -detailed |sort -k2,2nr |sed -n \'1,50p\' >$sp2.size;
get_gene-pair.pl $file
P-genome config.ini
");
chdir "..";
######################### Sub Routines #########################
