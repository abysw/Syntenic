########################################################
###count the length of the contig from the fasta file###
########################################################
#!usr/bin/perl -w
use strict;
if ( @ARGV != 2 ) {print "usage: perl $0  <*.fasta>  <*.blastx(m8 format)> [-l align_length] > output_filename\n";exit 0};
my %id_len;
my $id;
open (FASTA,$ARGV[0]) or die $!;
while(<FASTA>){
        chomp;
        if ($_=~ /^\>(\S+)/){
		$id = $1;
        }else {
		$id_len{$id} += length($_);
        }
}
close FASTA;
#########################################################################
##obtain the longest contig which has the highest score in each protein##
#########################################################################

my %bestHit;
use Getopt::Long;
my $L;
### -l   <int> :    (default: 300) min of alignmentlength###
GetOptions(
        "l=i"=>\$L,
);
$L ||=300;
open(M8, $ARGV[1]) or die;
while(<M8>){
        chomp;
        my @line = split /\t/,$_;
        if($line[3]>=$L){
        	if(exists $bestHit{$line[1]}{'contigID'}){
                	if($line[11] > $bestHit{$line[1]}{'bitscore'}){
				$bestHit{$line[1]}{'contigID'} = $line[0];
                                $bestHit{$line[1]}{'bitscore'} = $line[11];
                                $bestHit{$line[1]}{'output'} = $_;
			}elsif($line[11] == $bestHit{$line[1]}{'bitscore'}){
				my $new=$line[0];#one contig ID can only match one proteinID.
				my $past=$bestHit{$line[1]}{'contigID'};
				if($id_len{$new} >= $id_len{$past} ){
					$bestHit{$line[1]}{'contigID'} = $line[0];
                                        $bestHit{$line[1]}{'bitscore'} = $line[11];
                                        $bestHit{$line[1]}{'output'} = $_;
				}else{next;}
			}else{next;}
		}else{
			$bestHit{$line[1]}{'contigID'} = $line[0];
                        $bestHit{$line[1]}{'bitscore'} = $line[11];
                        $bestHit{$line[1]}{'output'} = $_;
		}
	}
}
close M8;
foreach my $key(keys %bestHit){
        print "$bestHit{$key}{'output'}\n";
}
