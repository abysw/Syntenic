open IN,"../03.count/zgene.xlsx";
while (<IN>){
	/(\S+)\s+(\S+)/;
	$nm = $1;
	$id = $2;
	$id =~ s/_//;
	$nm =~ s/\//./g;
	print "cp $id\_Metru.xls.pdf ../02.anchor_pdf/$nm-$id.Syntenic.pdf\n";
}


