import glob,os,hashlib
# The extracted disks: one directory per disk (floppy/tools/fat12_extract.py); override with TM_DIR.
ROOT=os.environ.get('TM_DIR', os.path.expanduser('~/compartilhado/tmp/data-floppy-kn5000/ext'))
def files():
    out=[]
    for p in sorted(glob.glob(ROOT+'/*/*')):
        if p.lower().endswith('.tm'):
            out.append((p,open(p,'rb').read()))
    return out
