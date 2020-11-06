### 本流程说明中介绍的是处理在特定的物种集（本例68个）中特定基因（本例235个）的共线性（块）的分析，其他脚本未做说明。
### 本流程徐结合唐海宝老师的jcvi python包使用
### 本流程为perl 和 python2 编写

##### mkdir 00.data # prepare gff and cds files in 00.data dirctory
##### mkdir 01.last-v1.0.10
##### cd 01.last-v1.0.10
##### ls `pwd`/../00.data/*cds | perl -ne 'chomp;print $_."\ ";' | perl -ne '@l=split; for $i(@l){print "perl Synteny/script/synteny-jcvi.shell.pl ../00.data/Medicago_truncatula.cds $i \n"}'
##### for i in `ls */*1.sh`;do echo $i | perl -ne '/(\S+)\/(\S+)/; print "sleep 30s; cd `pwd`/$1; nohup  sh $2 &\n"'; done    
#### get the anchors files (Syntenic blocks and links)
##### cd ..
##### mkdir 02.anchor; cp ../01.anchor/*anchors . ; cd ..
##### mkdir 03.blocks_stat; cd 03.blocks_stat; 
##### mkdir 00.bed; cd 00.bed; 
##### cp ../../01.last-v1.0.10/*bed > all.bed
##### cp ../../01.last-v1.0.10/reference_species.bed .
##### cd ..
##### mkdir 01.anchor        # 共线性结果
##### mkdir 02.anchor_pdf    # 每个基因的共线性图
##### mkdir 03.count         # 每个基因共线性统计
##### cd 01.anchor
##### python2 blocks_gene.py gene.235.lst Medicago_truncatula.bed . Medicago_truncatula 68.list
##### for i in `ls *xls`;do perl ../zcount.pl 68.list sp.list $i > ../03.count/$i.stat.xls ; done
##### for i in `ls *xls`;do python2 block-t3-plot.py $i | sh ;done 
##### perl addID.pl | sh 
#### 最终共线性图在02.anchor_pdf中
#### 最终共线性统计结果在03.count中，用inhome脚本合并，代码太短，不做赘述
