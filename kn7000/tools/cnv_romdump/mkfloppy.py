#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# mkfloppy.py OUT.img LABEL FLOPPY_TOOLS FILE... -- the files on a blank disk the KN7000 formatted
# (kn7000_mame tools/floppy-images: base/kn7000_formatted.img.gz and technics_floppy.py).
import gzip
import os
import subprocess
import sys
import tempfile
import zipfile

out, label, tools, files = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
with tempfile.TemporaryDirectory() as tmp:
    z = os.path.join(tmp, 'files.zip')
    with zipfile.ZipFile(z, 'w') as zf:
        for f in files:
            info = zipfile.ZipInfo(os.path.basename(f).upper(), date_time=(2026, 10, 19, 0, 0, 0))
            info.external_attr = 0x20
            zf.writestr(info, open(f, 'rb').read())
    base = os.path.join(tmp, 'base.img')
    open(base, 'wb').write(gzip.open(os.path.join(tools, 'base', 'kn7000_formatted.img.gz')).read())
    subprocess.run([sys.executable, '-I', os.path.join(tools, 'technics_floppy.py'), base, z, out,
                    '--label', label], check=True)
