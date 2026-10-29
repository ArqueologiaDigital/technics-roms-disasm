#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""bands.py -- generic bytes per 16 KB band of the program image.

QUESTION IT ANSWERS
  "Where in the data region are the generic bytes (and how many pieces) concentrated?"

RUN (from kn7000/):  python3 notes/data-rest-probes/bands.py src/program/data
"""
import re,glob,sys,os,collections
d=sys.argv[1]
band=collections.Counter(); nb=collections.Counter()
for f in sorted(glob.glob(d+"/data_*.s")):
    for ln in open(f,encoding='latin-1'):
        m=re.match(r'\.incbin_range "[^"]+", 0x([0-9A-F]+), 0x([0-9A-F]+)',ln)
        if m:
            a,b=int(m.group(1),16),int(m.group(2),16)
            band[a>>14]+=b-a; nb[a>>14]+=1
for k in sorted(band): print(f"{0x48400000+(k<<14):08X} {band[k]:7d} {nb[k]:5d}")
