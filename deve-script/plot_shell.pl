#!/usr/bin/perl -w
=head1 Name
    /hwfssz1/ST_AGRIC/LOCAL/Pipline/Perl-pipline.1.0/06.synteny/bin/plot_shell.pl
Info
    Version Perl-pipline.1.0
    Author: st_agric (FuYuan), fuyuan@genomics.cn
    Created Time: 2017-10-31 20:55:03
    Created Version: plot_shell.pl
Usage
    plot_shell.pl	
=cut
use strict;
use feature qw(say);
use lib '/home/st_agric/lib';
use MCsub;
use Getopt::Long;
my ($blast,$mcscan,$help);
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
$blast="$1.besthit.blast" if `less  $sh`=~/ln -s (\S+).blastp/;
$blast=$1 if `less  $sh`=~/ln -s (\S+besthit.blast)/;
$gff=~s/\s+$//;
my @pep=split /\s+/,$gff;
for (@pep){
	$_=~s/.gff$//;
}
my ($spe1,$spe2,$paralog,$ortholog);
if (@pep == 2){
	($spe1,$spe2)=@pep if $pep[0]=~/$sp1/;
	($spe2,$spe1)=@pep if $pep[1]=~/$sp1/;
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

#`/hwfssz1/ST_AGRIC/USER/heshixu/Program/script/comparative_genomics/chainNet_v2/faSize $spg1 -detailed |sort -k2,2nr |sed -n \'1,50p\' >$sp1.size`;
#`/hwfssz1/ST_AGRIC/USER/heshixu/Program/script/comparative_genomics/chainNet_v2/faSize $spg2 -detailed |sort -k2,2nr |sed -n \'1,50p\' >$sp2.size`;

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
output("plot.sh","# fa-size
/hwfssz1/ST_AGRIC/USER/heshixu/Program/script/comparative_genomics/chainNet_v2/faSize $spg1 -detailed |sort -k2,2nr |sed -n \'1,50p\' >$sp1.size;
/hwfssz1/ST_AGRIC/USER/heshixu/Program/script/comparative_genomics/chainNet_v2/faSize $spg2 -detailed |sort -k2,2nr |sed -n \'1,50p\' >$sp2.size;
perl /hwfssz1/ST_AGRIC/LOCAL/Pipline/Perl-pipline.1.0/06.synteny/bin/get_gene-pair.pl $file
perl /hwfssz1/ST_AGRIC/USER/chenlei/software/P-genome/bin/P-genome config.ini
");
chdir "..";
######################### Sub Routines #########################
