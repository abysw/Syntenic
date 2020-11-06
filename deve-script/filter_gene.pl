#!/usr/bin/perl -w
=head1 Name
    /hwfssz1/ST_AGRIC/LOCAL/Pipline/Perl-pipline.1.0/06.synteny/bin/filter_gene.pl
Info
    Version Perl-pipline.1.0
    Author: st_agric (FuYuan), fuyuan@genomics.cn
    Created Time: 2018-04-17 16:45:24
    Created Version: filter_gene.pl
Usage
    filter_gene.pl	
=cut
use strict;
use feature qw(say);
use lib '/home/st_agric/lib';
use agric;
use Getopt::Long;
my ($num,$help);
GetOptions(
	"num:i"=>\$num,
	"help!"=>\$help
);
$num||=10;
die opth() if $help;

#my $pipath=path("Perl-pipline.1.0"); #$pipath/script/config.txt
open IN,shift;#Annona_senegalensis_gene-Annona_senegalensis_gene.collinearity

$/="## A";
my $head=<IN>;
print $head;
while (<IN>){
	/N=(\d+)/;
	chop;chop;chop;chop;
	$_="## A".$_;
	print $_ if $1>$num;
}
######################### Sub Routines #########################
