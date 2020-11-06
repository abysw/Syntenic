#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# Author: fuyuan (907569282@qq.com)
# Created Time: 2019-06-24 09:55:14
# Example python blocks_gene.py gene.list Medicago_truncatula.bed . Medicago_truncatula sp.list
import sys, os, re

if len(sys.argv) != 6:
	exit('python blocks_gene.py gene.list ref.bed block_dir ref_name sp.list')

gene_list = sys.argv[1]
ref_bed = sys.argv[2]
block_dir = sys.argv[3]
ref_name = sys.argv[4]
sp_list = sys.argv[5]

genes = []
fp = open(gene_list)
for line in fp:
	line = line.strip()
	list = re.split('\s+',line)
	for i in list:
		i = i + '_Metru'
		genes.append(i)

fp = open(ref_bed)
genes_r = {}
genes_scaf = {}
for line in fp:
	re_scaf = re.search('(\S+)\s+\d+\s+\d+\s+(\S+_Metru)',line)
	if not genes_scaf.has_key(re_scaf.group(1)):
		genes_scaf[re_scaf.group(1)] = []
	genes_scaf[re_scaf.group(1)].append(re_scaf.group(2));
	genes_r[re_scaf.group(2)] = re_scaf.group(1)

fo = os.popen('ls ' + block_dir + '/*anchors')
dict = {}
for i in fo:
	re_sp = re.search('\.(\w+)\.anchors',i)
	i = i.strip()
	if re_sp:
		sp_id = re_sp.group(1)
		fp = open(i)
		for line in fp:
			list = re.split('\s+',line)
			if len(list) < 3:
				continue
			else:
				re_id = re.search('(\S+_Metru)',list[0])
				gene_id = re_id.group(1)
				if not dict.has_key(sp_id):
					dict[sp_id] = {}
				dict[sp_id][gene_id] = list[1]

fp = open(sp_list)
list_sp = []
for line in fp:
	line = line.strip()
	list = re.split('\s+',line)
	for i in list:
		list_sp.append(i) 

list_gene = []
num = 15
for gene in genes:
	if not genes_r.has_key(gene):
		print 'not exists gene ' + gene
	else:
		re_ge = re.search('(MtrunA\S+)', gene)
		if re_ge:
			ft = open(re_ge.group(1) + '.xls','w')
		gene_num = len(genes_scaf[genes_r[gene]])
		for i in range(gene_num):
			if genes_scaf[genes_r[gene]][i] == gene:
				if i >= num and gene_num - i >= num:
					list_gene = genes_scaf[genes_r[gene]][i-num:i+num+1]
				elif i < num and gene_num - i >= num:
					list_gene = genes_scaf[genes_r[gene]][0:i+num+1]
				elif i >= num and gene_num - i < num:
					list_gene = genes_scaf[genes_r[gene]][i-num:gene_num]
				elif i < num and gene_num - i < num:
					list_gene = genes_scaf[genes_r[gene]][0:gene_num]
		for i in list_gene:
			out_l = []
			if i == gene:
				ft.write('r*')
#			ft.write(i)
			for j in list_sp:
#add				
				if j == ref_name:
					out_l.append(i)
				elif dict[j].has_key(i):
					out_l.append( dict[j][i])
				else:
					out_l.append('.')
			ft.write('\t'.join(out_l) + '\n')



			



