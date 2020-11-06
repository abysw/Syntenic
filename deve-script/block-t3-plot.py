#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# Author: fuyuan (907569282@qq.com)
# Created Time: 2019-07-05 09:13:49
# Example block.py   
import sys, os, re

block = sys.argv[1]
fp = os.popen('less ' + block )
#ft = open(block + '.tmp', 'w')
dict = {}
scaf = {}
check = 0
for line in fp:
	line = line.strip()
	list = re.split('\s+',line)
	n = 0
	re_r = re.match('r\*(\S+)',line)
	for i in list:
		n += 1
		if not dict.has_key(n):
			dict[n] = []
		if not i == '.':
			if not re_r:
				dict[n].append(i)
	n = 0
	if re_r:
		check = 1
		for i in list:
			n += 1
			if i == '.':
				if len(dict[n]) > 0:
					scaf[n] = dict[n][-1]
			elif i == 'r*.':
				if len(dict[n]) > 0:
					scaf[n] = dict[n][-1]
			else:
				scaf[n] = i;
		#del scaf[1]
		if len(re_r.group(1)) >5:
			scaf[1] = re_r.group(1)

	elif check == 1:
		for j in range(1,len(list)+1):
			if not scaf.has_key(j):
				if not list[j-1] == '.':
					scaf[j] = list[j-1]

for i in scaf.keys():
	if len(dict[i]) == 0:
		del scaf[i]

fp_sp = open('sp.list')
n = 0
sp_d = {}
cor = {}
for line in fp_sp:
	n += 1
	re_sp = re.search('(\w)\*(\S+)', line)
	if re_sp:
		sp_d[n] = re_sp.group(2)
		if re_sp.group(1) == 'f':
			cor[n] = 'r'
		else:
			cor[n] = 'c'

ft_ly = open(block + '.layout', 'w')
loc = ''
edge = ''
genes = []
m = 0

for i in scaf.keys():
	genes.append(scaf[i])
	if not sp_d[int(i)] == 'Medicago_truncatula':
		loc += ',\t'.join(['0.5', str((i + 1) * 0.014), '0', 'right', 'right', cor[int(i)], '1', sp_d[int(i)]]) + '\n'
	else:
		loc += ',\t'.join(['0.5', str((i + 1) * 0.014), '0', 'right', 'right', cor[int(i)], '1', sp_d[int(i)]]) + '\n'
	if m > 0:
		edge += 'e, ' + str(m-1) + ", " + str(m) + '\n'
#		if not sp_d[int(i)] == 'Medicago_truncatula':
#			edge += 'e, ' + str(m-1) + ", 11" + '\n'
	m += 1
	
ft_ly.write('# x,   y, rotation,   ha,     va,   color, ratio,            label\n' + loc + '# edges\n' + edge)

fp = os.popen('grep -P "' + '|'.join(genes) + '" all.bed | cut -f 1 | sort -k 1 | uniq | ' + "perl -ne 's/\S+\|//;print $_'")
scafs = []
for line in fp:
	line = line.strip()
	scafs.append(line)

os.system('grep -P "' + '|'.join(scafs) + '" all.bed > ' + block + '.bed')
fp = open(block + '.bed')
gene = {}
for line in fp:
	list = re.split('\t', line)
	gene[list[3]] = 1

ngene = {}
bgene = {}
fp = open(block)
ft = open(block + ".block", 'w')
for line in fp:
	line = line.strip()
	list = re.split('\t', line)
	list_gene = []
	n = 0
	re_line = re.match('r', line)
	if re_line:
		ft.write('r*')
	for i in list:
		n += 1
		re_r = re.match('r\*(\S+)', i)
		j = i
		if not scaf.has_key(n):
			continue
		if re_r:
			j = re_r.group(1)
			i = j
#			ft.write('r*')
			for myi in list:
				ngene[myi] = 1
		if gene.has_key(j):
			list_gene.append(i)
			bgene[i] = 1
		else:
			if re_r:
				list_gene.append('.')
			else:
				list_gene.append('.')
	ft.write('\t'.join(list_gene) + '\n')

####
fp = open(block + '.bed')
ft = open(block + '.bed.tmp', 'w')
check = {}
tmp = []
bed = {}
i = 0
tmpgene = ''
chgene = {}
for line in fp:
	line = line.strip()
	list = re.split('\s+', line)
	tmp.append(line)
	if not bed.has_key(list[0]):
		bed[list[0]] = []
		chgene[list[0]] = {}
	list[5] = '-'
	if ngene.has_key(list[3]):
		list[5] = '+'
	i += 1
	if bgene.has_key(list[3]):
		chgene[list[0]][list[3]] = i
#		tmpgene = list[3]
#		if not check.has_key(list[0]):
#			check[list[0]] = 0
#		if check[list[0]] == 0:
#			bed[list[0]] = []
#		bed[list[0]].append(line)
#		check[list[0]] = 1
#		i = 1
#	else:
#		if i > 0:
#			i += 1
#			bed[list[0]].append(line)
#		if i >= 50:
			
#			if bgene.has_key(tmpgene):
#				del bgene[tmpgene]
#			check[list[0]] = 0
	ft.write("\t".join(list) + '\n')

mygene = ''
for i in chgene.keys():
	mygene = ''
	tgene  = ''
	for j in chgene[i].keys():
		if ngene.has_key(j):
			mygene = j
			for j in chgene[i].keys():
				if chgene[i][j] - chgene[i][mygene] < -30  or chgene[i][j] - chgene[i][mygene] > 30:
					del bgene[j]
			break
		else:
			if tgene == '':
				tgene = j
			elif chgene[i][tgene] > chgene[i][j]:
				tgene = j
	if mygene == '':
		for j in chgene[i].keys():
			if chgene[i][j] - chgene[i][tgene] > 60  or chgene[i][j] - chgene[i][tgene] < 0:
				del bgene[j]

fp = open(block + '.block')
ft = open(block + '.block.tmp', 'w')
for line in fp:
	line = line.strip()
	list = re.split('\t', line)
	list_gene = []
	for i in list:
		re_r = re.match('r\*(\S+)', i)
		j = i
		if re_r:
			j = re_r.group(1)
			list_gene.append(i)
		elif bgene.has_key(j):
			list_gene.append(i)
		else:
			list_gene.append('.')
	ft.write('\t'.join(list_gene) + '\n')

####

os.system('mv ' + block + '.block.tmp ' + block + '.block')
os.system('mv ' + block + '.bed.tmp ' + block + '.bed')

cmd = 'python -m jcvi.graphics.synteny ' + block + '.block' + ' ' + block + '.bed ' + block + '.layout --figsize=16x32 --dpi=300 --font=Arial --scalebar'
print cmd
