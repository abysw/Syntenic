#!/usr/bin/perl -w
=head1 Name
    /hwfssz1/ST_AGRIC/LOCAL/Pipline/Perl-pipline.1.0/06.synteny/bin/get_gene-pair.pl
Info
    Version Perl-pipline.1.0
    Author: st_agric (FuYuan), fuyuan@genomics.cn
    Created Time: 2017-11-30 16:58:26
    Created Version: get_gene-pair.pl
Usage
    get_gene-pair.pl	
=cut
use strict;
use feature qw(say);
use lib '/home/st_agric/lib';
use MCsub;
use Getopt::Long;
my ($help);
GetOptions(
	"help!"=>\$help
);
die opth() if $help;

my $file=shift;
open IN,$file||$!;
open OUT,">$file.gene_pair"||$!;
$/="\n## ";
<IN>;
my @text;
while (<IN>){
	my @line=split /\n/,$_;
	if ($line[0]=~/N=(\d+)/){
		if ($1<5){
			next;
		}else{
#			say OUT $line[0];
			for (1..$#line){
				@text = split /\s+/,$line[$_];
				next if @text < 5;
				say OUT "$text[-3]\t$text[-2]";
			}
		}
	} 
}
#my $pipath=path("Perl-pipline.1.0"); #$pipath/script/config.txt

######################### Sub Routines #########################
# The one who believes in God will live, even though they die. #
################################################################
