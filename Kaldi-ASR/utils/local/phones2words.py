#phones2words.py

import sys,re,glob

pron_ali=open("exp/nnet3_ali/pron_alignment.txt","w")
pron=[]

files= glob.glob('[1-9]*.txt')

#process every file
for filex in files:
	print(filex)
	f = open(filex, 'r')
	header=True
