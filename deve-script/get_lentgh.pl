##!/usr/bin/perl
#use Cwd;
#print getcwd;
#$pwd=`pwd`;
#print $pwd,"\n";
#print $ENV{'PWD'};

#!/usr/bin/perl
use strict;
use Data::Dumper;
#my $file=shift;
open FA,'<',$ARGV[0] or die "can't open file: $!\n";
my %sca_len;
my $id;
my $seq;
my $len;
$/="\>";<FA>;$/="\n";
while (<FA>){
        chomp;
#        if ($_=~/^\>(\S+)/){
                $id=$_;
		$/="\>";
		$seq=<FA>;
		$/="\n";
#        }else{
#                $seq .=$_;
 		chop $seq;
		$seq=~s/\s+//g;
	        $len=length($seq);
                $sca_len{$id}=$len;
		print $id,"\t",$len,"\n";
#        }
}

