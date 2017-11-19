#!/usr/bin/env python

# to use: python extract_OATpos.py oate-file.txt output-file.csv
# outputs a list of video timestamps with actual times


import sys
import os
import json
import csv

file_in = sys.argv[1]
file_out = sys.argv[2]

data = []
for line in open(file_in):
    try:
        data.append(json.loads(line))
    except ValueError:
        continue

posT = []
tick = []

myInt = 10000.0000

for i in range(len(data)):
    posT.append((data[i])["time"])
    tick.append((data[i])["tick"])

newposT = [x / myInt for x in posT]



with open(file_out,'w') as f:
    writer = csv.writer(f,delimiter='\t')
    writer.writerows(zip(newposT,tick))
