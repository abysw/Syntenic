#!/usr/bin/perl -w
=head1 Name
    blast_shell.pl
Info
    Version Perl-pipline.1.0
    Author: Yuan-SW-F, yuanswf@163.com
    Created Time: 2017-10-31 20:07:51
    Created Version: blast_shell.pl
Usage
    blast_shell.pl	
=cut
use strict;
use feature qw(say);
#use lib '/home/***/lib';
use MCsub;
use Getopt::Long;
my ($query,$database,$help);
GetOptions(
	"query:s"=>\$query,
	"database:s"=>\$database,
	"help!"=>\$help
);
$query||=shift;
$database||=shift;
$database||=$query;
die opth() if $help;
my $file=$1 if $query=~/([^\/\.]+)[^\/]+$/;
$file.="\-$1" if $database=~/([^\/\.]+)[^\/]+$/;

mkdir $file;
output("$file/step1_build.sh","makeblastdb -in $database -dbtype prot -input_type fasta");
output("$file/step2_blastp.sh","blastp -num_threads 5 -db $database -query $query -evalue 1e-10 -outfmt 6 -out $file.blastp -num_alignments 5");
output("$file/step3_filter.sh","blast_filter.pl -r 5 -self -e 1e-10 -o $file.besthit.blast $file.blastp");
output("$file/work.sh","sh step2_blastp.sh;\nsh step3_filter.sh;\n");
#my $pipath=path("Perl-pipline.1.0"); #$pipath/script/config.txt

######################### Sub Routines #########################
# The one who believes in God will live, even though they die. #
################################################################
