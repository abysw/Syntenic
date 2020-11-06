package agric;
use strict qw(subs refs);
use feature qw(say);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(output inhash inarray libinf gun step allhash myhash bin dir fasta opth path species);

sub species
{
	my $species= `pwd`=~/(\w+)[^\/]*\/[\d\.]+survey\// ? $1 : "species"; 
}
sub output
{
	my @line=@_;
	my $ck=0;
	$ck=1 if open OUT,">$line[0]";
	say "------Warning!!!------\nPrint on closed filehandle $line[0]\nPermission Denied!!!\n" if $ck==0;
	open OUT,">$line[0]"||$!;
	for my $i(1..$#line){
		if ($ck==1){
			print OUT $line[$i];
		}else{
			print $line[$i];
		}
	}
	close OUT;
}

sub inhash
{
	my (%hash);
	open IN,shift||$!;
	while (<IN>){
	$hash{$1}=$2 if /^(\S+)\s+(\S+)/;
	$hash{$1}="1" if /^(\S+)$/;
	}
	close IN;
	%hash;
}

sub myhash
{
	my %hash;
	my ($file,$key,$valu,$type)=@_;
	open IN,$file||$!;
	$key||=1;
	$valu||=0;
	$type||="0";
	my $keys=$key-1;
	my $value=$valu-1;
	my @lines;
	while (<IN>){
		if ($type eq "0"){
		@lines=split /\s+/;
		}else{
		@lines=split /\t/;
		}
	$hash{$lines[$keys]}=$lines[$value];
	}
	%hash;
}

sub allhash
{
	my %hash;
	open IN,shift||$!;
	while (<IN>){
	chomp;
	$hash{$1}=$2 if /^(\S+)\s+(.+)$/;
	}
	close IN;
	%hash;
}

sub inarray
{
	my @array;
	open IN,shift||$!;
	while (<IN>){
	chomp;
	push @array,$1 if /^(\S+)/;
	}
	close IN;
	@array;
}

sub libinf
{
	my %libinf;
	for (@_){
	my $seq=$1 if /([^\/\s]+)$/;	#151023_I132_FCH3LLMBBXX_L6_RFINunlTAAAARAAPEI-8_1.fq.gz.clean.dup.clean
		if ($seq=~/((L(\d)\_(\w+\-\S+))\_(\d)(\.\S+))/){
		$libinf{body}=$1;	#L6_RFINunlTAAAARAAPEI-8_1.fq.gz.clean.dup.clean
		$libinf{head}=$2;	#L6_RFINunlTAAAARAAPEI-8_1
		$libinf{lane}=$3;	#6
		$libinf{lib}=$4;	#RFINunlTAAAARAAPEI-8
		$libinf{reads}=$5;	#1
		$libinf{end}=$6;	#.fq.gz.clean.dup.clean
		}else{
			if ($seq=~/((\S+)\_(\d)(\.\S+))/){
				$libinf{body}=$1;
				$libinf{head}=$2;
				$libinf{lane}=$2;
				$libinf{lib}="";
				$libinf{reads}=$3;
				$libinf{end}=$4;
			}
		}
	}
	%libinf;
}

sub gun
{
	my $shfile;
	for (@_){
		if (/([^\/]+)\.gz$/){
		$shfile.= /([^\/]+)\.gz$/ ? "gunzip -c $_ > ./$1\n" : "";
		}else{
		/([^\/]+)$/;
		$shfile.= "ln -s $_ $1\n" if ! -e $1;
		}
	}
	$shfile;
}

sub step
{
	my $step=shift;
		while ($step=~/(\d)\.\.(\d)/){
		my @m=($1..$2);
		my $j=join "",@m;
		$step=~s/\d\.\.\d/$j/;
		}
	$step;
}

sub dir
{
	my $dir=shift||".";
	`pwd`=~/(\S+)/;
	$dir="$1/$dir" if $dir!~/^\//;
	$dir=~/(\S+)\/[^\/]+$/;
	$dir=$1 if -f $dir;
	$dir= $dir=~/(\S+)\/\.$/ ? $1 : $dir; 
}

sub bin
{
	my $prg="$0";
	#my $prg="$1/$0" if `pwd`=~/(\S+)/;
	while (`ls -l $prg`=~/\s+\-\>\s+/){
		if (`ls -l $prg`=~/(\S+)\s+\-\>\s+(\S+)$/){
			my $pgps=$1;
			my $pgpl=$2;
			if ($pgpl=~/^\//){
				$prg=$pgpl;
			}else{
				$prg=$1."/$pgpl" if $pgps=~/(\S+)\/[^\/]+$/;
			}
		}
#	$prg=$1 if `ls -l $prg`=~/(\S+)$/;
	}
	$pwd=$1 if `pwd`=~/(\S+)/;
	my $bin= $prg=~/(\S+)\/[^\/]+$/ ? $1 : $pwd;
}

sub fasta
{
	my $fasta=shift;
	$fasta||= `ls *fa *fasta 2>/dev/null` =~/(\S+)/ ? $1 : "assembly.fasta";
	$fasta= dir()."/$fasta" if $fasta!~/^\//;
		if (-e $fasta){
		say "please check the format of $fasta" if `less $fasta|head -n 1` !~/^\>/;
		}else{
		say "please input fasta format file $1 !" if $fasta=~/([^\/]+)$/;
		$fasta||="assembly.fasta";
		}
	$fasta;
}
sub opth
{
	my $opth=`pod2text $0`;
	my (%opth1,%opth2,%opth3,@opth,%opts,@opts);
	my $len=5;
	@opts=split /\s+\-\-?/,$opth;
	for (@opts){
	$opts{$1}=1 if /(\S+)/;
	}
	open IN,"$0"||$!;
	while (<IN>){
		if (/GetOptions/){
			while (<IN>){
			next if /\"help\!\"/;
				if (/\"([^\"\!\:\=]+)([\:\!\=]\S?)\s*\"\s*\=\>\s*\\(\$\S+)\,/){
				$opth1{$1}=$3;
				$opth3{$1}=$2;
				my $opth3=$1;
				$opth3{$opth3}="\<Option\>" if $opth3{$opth3}=~/\!/;
				$opth3{$opth3}="\[Int\]" if $opth3{$opth3}=~/\:i/;
				$opth3{$opth3}="\[String\]" if $opth3{$opth3}=~/s/;
					if ($opth3=~/(\S+)/){
					push @opth,$1 if ! exists $opts{$1};
					$len=length($1) if length($1) > $len;
					}
				}
			last if  /\)\;/;
			}
			while (<IN>){
				if (/(\$\S+)\|\|\=\s*(\S.+)\;$/){
				my $optth=$1;
				$opth2{$optth}=$2;
				$opth2{$optth}=$1 if $opth2{$optth}=~m#\"(\S*)\"#;
				$opth2{$optth}=$1 if $opth2{$optth}=~/([\"\'][^\"'`]+[\"\'])/;
				}
			last if /die/;
			}
			for (@opth){
			next if exists $opts{$_};
			my $spf= sprintf "%-$len"."s",$_;
			$opth.="\t--$spf\t";
			$opth.= exists $opth2{$opth1{$_}} ? "$opth3{$_}\t\(default: $opth2{$opth1{$_}}\)\n" : "$opth3{$_}\n";
			}
		}
	}
	my $help=sprintf "%-$len"."s","help";
	$opth.="\t--".sprintf "%-$len"."s","$help"."\toutput help information to screen\n" if !exists $opts{help};
	$opth;
}

sub path
{
	my ($path,%path,$pathway);
	my @paths=@_;
	push @paths,"/home/st_agric/lib/config.txt" if @paths == 1;
	if (@paths == 2){
		$path=$paths[0];
		$config= $paths[1];
		open IN,$config||$!;
		while (<IN>){
			next if /^\s*\#/;
			if (/\s*(\S+)\s*\=\s*(\S+)/ || /\s*(\S+)\s+([^\s\=]+)/){
			$path{$1}=$2;
			}
			}
#		$path=$1 if `which $path 2>/dev/null`=~/(\S+)/;
		$pathway=$path{$path} if exists $path{$path} && -e $path{$path};
		$pathway||=$1 if `which $path 2>/dev/null`=~/(\S+)/;
	}
	$pathway||=`echo "wrong program or database name"`;
}
__END__
