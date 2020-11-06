#!/usr/bin/perl -w
=head1 Name
    synteny-jcvi_stat.pl
Info
    Version Perl-pipline.1.0
    Author: st_agric (FuYuan), fuyuan@genomics.cn
    Created Time: 2018-05-04 10:06:43
    Created Version: synteny-jcvi_stat.pl
Usage
    synteny-jcvi_stat.pl	
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
my $list=`cat $file`;
#my $text=$1 if `cat $file`=~/\[base\]\s+Load\s+file\s+\`(\w+\.\w+)\.lifted\.anchors\`\s+A\s+total\s+of\s+(\d+)\s+\(NR\:(\d+))\s+anchors\s+found\s+in\s+(\d+)\s+clusters\.\s+Stats\:\s+(Min=4 Max=101 N=1068 Mean=13.8380149813 SD=10.7344948102 Median=11.0 Sum=14779\nNR stats: Min=4 Max=57 N=1068 Mean=8.39138576779 SD=5.14748772848 Median=7.0 Sum=8962\n\S+\s+[synteny]/
my @line= split /\n/,$list;
my $i=0;
my $stat;
my $nr;
my $head;
while ($i<$#line){
	if ($line[$i]=~/\[base\].+\`(\w+\.\w+)\.anchors\`/){
		open OUT , ">$1.stat";
		$head=$1;
		$stat=$line[$i+2];
		$nr=$line[$i+3];
	say $line[$i+1];
	last;
	}
	$i++;
}
my (@id,@v1,@v2);
my @stat= split /\s+/ ,$stat;
for (@stat[1..$#stat]){
	/(\w+)\=(\S+)/;
	push @id,$1;
	push @v1,$2;
}
my @nr= split /\s+/ ,$nr;
for (@nr[2..$#nr]){
	/(\w+)\=(\S+)/;
	push @v2,$2;
}
$head="$1-$2" if $head=~/(\w\w\w)[a-z]+\.(\w\w\w)/;
say OUT join "\t","$head",@id;
say OUT join "\t","stat",@v1;
say OUT join "\t","NR",@v2;
######################### Sub Routines #########################
