#!/usr/bin/env python

# to use: python extract_OATpos.py oate-file.txt output-file.csv
#converts to correct timestamp


import sys
import os
import json
import csv
import pandas as pd

file_in = sys.argv[1]
file_out = sys.argv[2]

# Loads the json file and goes into the position part.
a = json.load(open(file_in))["positions"]

# Does a "for loop" via list comprehension to get the positon_xy quickly into a list.
b = [item["pos_xy"] for item in a]

# Makes a dataframe out of the list of lists.
c = pd.DataFrame(b)

# Converts the df to a csv.
c.to_csv(file_out, header=False, index=False)
