#!/usr/bin/env python


import os, sys
import pickle

infile = sys.argv[1]
ofile = infile.replace("txt", "pickle")

p = list()

with open(infile, 'r') as foo:
  for line in foo:
    p.append(line.rstrip())

pickle.dump(list(set(p)), open(ofile, "wb"))
