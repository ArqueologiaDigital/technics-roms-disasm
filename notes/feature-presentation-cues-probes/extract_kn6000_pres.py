#!/usr/bin/env python3
"""Extract the root-directory files of the KN6000 feature-presentation FAT12 images.
Usage: extract_kn6000_pres.py OUTDIR IMG...   (reader: kn7000_mame tools/slideshow/fat12_relayout.py files_of)"""
import os, sys, importlib.util
spec = importlib.util.spec_from_file_location('fr', '/home/fsanches/compartilhado/kn7000_mame/tools/slideshow/fat12_relayout.py')
fr = importlib.util.module_from_spec(spec); spec.loader.exec_module(fr)
out = sys.argv[1]
for img in sys.argv[2:]:
    tag = os.path.basename(img).split('_')[0].split('.')[0]
    d = os.path.join(out, tag); os.makedirs(d, exist_ok=True)
    for name, data in fr.files_of(open(img, 'rb').read()):
        open(os.path.join(d, name), 'wb').write(data)
        print(tag, name, len(data))
