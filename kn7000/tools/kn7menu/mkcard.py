#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# mkcard.py -- the SD card's folder tree for the program menu (README.md, "The card"): what to copy to the
# card's root, as it is.
#   python3 -I mkcard.py OUTDIR MENU_KN7APP.BIN AW_SDCARD_DIR RELEASES_DIR [ICONDIR]
# OUTDIR is made afresh: the menu as the root KN7APP.BIN, and a folder per program (PROGRAMS below), each
# with its KN7APP.BIN, a MANIFEST.TXT and an ICON.BMP (gen_icons.py -> PNG -> png2icon.py, into ICONDIR,
# default OUTDIR/../icons). Another World's folder takes everything its own build wrote (AW_SDCARD_DIR:
# kn5000-anotherworld kn7000/build/sdcard, KN7APP.BIN and its 43 game files). The probes' KN7APP.BINs are
# the released ones (RELEASES_DIR: ../cnv_romdump/releases), checked against each release's SHA1SUMS; DSPTONE's
# comes from ../dsptone/releases the same way.
# Writes OUTDIR.txt: every file, its size and SHA-1, as an aligned Markdown table.
import hashlib
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
# folder (8.3), what goes in it, NAME=, icon (gen_icons.py)
PROGRAMS = [
    ("AW", "aw", "Another World", "aw"),
    ("SURVEY2", "2026-10-20-survey2/sdcard-pass5-SURVEY2", "Pass 5: ROM dumper SURVEY2 (IC23, work RAM)", "survey2"),
    ("DSPPROBE", "2026-10-20-dspprobe/sdcard-pass6-DSPPROBE", "Pass 6: DSP probe, phase 1", "dspprobe"),
    ("DSPMEM", "2026-10-20-dspmem/sdcard-pass7-DSPMEM", "Pass 7: DSP probe, phase 2 (DSP memory)", "dspmem"),
    ("DSPRATE", "2026-10-20-dsprate/sdcard-pass8-DSPRATE", "Pass 8: DSP probe, frame rate", "dsprate"),
    ("CPUTIME", "2026-10-20-cputime/sdcard-pass9-CPUTIME", "Pass 9: CPU timing probe", "cputime"),
    ("DSPTONE", "dsptone:2026-10-20-iter1/sdcard-DSPTONE", "DSP tone: our own effects-DSP program", "dsptone"),
]
DSPTONE_RELEASES = os.path.join(HERE, '..', 'dsptone', 'releases')   # ../dsptone (its own releases)


def sha1(p):
    return hashlib.sha1(open(p, 'rb').read()).hexdigest()


def released(releases, rel):
    """the release's KN7APP.BIN, after checking it against that release's SHA1SUMS"""
    top, sub = rel.split('/')
    path = os.path.join(releases, top, sub, 'KN7APP.BIN')
    want = None
    for line in open(os.path.join(releases, top, 'SHA1SUMS')):
        h, name = line.split()
        if name == f'{sub}/KN7APP.BIN':
            want = h
    if want is None or sha1(path) != want:
        sys.exit(f'mkcard: {path} is not the released binary (SHA1SUMS)')
    return path


def main():
    out, menu, aw, releases = sys.argv[1:5]
    icons = sys.argv[5] if len(sys.argv) > 5 else os.path.join(os.path.dirname(os.path.abspath(out)), 'icons')
    out = os.path.abspath(out)
    parent = os.path.dirname(out)
    assert os.path.isdir(parent) and out != parent and os.path.basename(out), out
    if os.path.isdir(out):                   # only a tree this script made (its listing lies beside it)
        if os.listdir(out) and not os.path.isfile(out + '.txt'):
            sys.exit(f'mkcard: {out} exists and was not made by mkcard.py (no {out}.txt): not removing it')
        assert os.path.commonpath([out, parent]) == parent and out.startswith(parent + os.sep)
        shutil.rmtree(out)
    os.makedirs(out)
    os.makedirs(icons, exist_ok=True)
    shutil.copyfile(menu, os.path.join(out, 'KN7APP.BIN'))
    for folder, src, name, icon in PROGRAMS:
        d = os.path.join(out, folder)
        os.makedirs(d)
        if src == 'aw':
            files = sorted(os.listdir(aw))
            if 'KN7APP.BIN' not in files:
                sys.exit(f'mkcard: no KN7APP.BIN in {aw} (make -C kn5000-anotherworld/kn7000 sdcard)')
            for f in files:
                shutil.copyfile(os.path.join(aw, f), os.path.join(d, f))
        elif src.startswith('dsptone:'):
            shutil.copyfile(released(DSPTONE_RELEASES, src.split(':', 1)[1]), os.path.join(d, 'KN7APP.BIN'))
        else:
            shutil.copyfile(released(releases, src), os.path.join(d, 'KN7APP.BIN'))
        with open(os.path.join(d, 'MANIFEST.TXT'), 'w', newline='\r\n') as f:
            f.write(f'# {folder}: the KN7000 program menu shows this name and icon (kn7menu/README.md)\n')
            f.write(f'NAME={name}\nICON=ICON.BMP\n')
        png = os.path.join(icons, f'{icon}.png')
        subprocess.run([sys.executable, '-I', os.path.join(HERE, 'gen_icons.py'), '--png', icon, png], check=True)
        subprocess.run([sys.executable, '-I', os.path.join(HERE, 'png2icon.py'), png, os.path.join(d, 'ICON.BMP')],
                       check=True, stdout=subprocess.DEVNULL)
    rows = [('file', 'bytes', 'SHA-1')]
    for root, dirs, files in os.walk(out):
        dirs.sort()
        for f in sorted(files):
            p = os.path.join(root, f)
            rows.append((os.path.relpath(p, out).replace('/', '\\'), f'{os.path.getsize(p):,}', sha1(p)))
    w = [max(len(r[i]) for r in rows) for i in range(3)]
    with open(out + '.txt', 'w') as f:
        f.write('| ' + ' | '.join(c.ljust(w[i]) for i, c in enumerate(rows[0])) + ' |\n')
        f.write('|' + '|'.join('-' * (x + 2) for x in w) + '|\n')
        for r in rows[1:]:
            f.write('| ' + ' | '.join(c.ljust(w[i]) for i, c in enumerate(r)) + ' |\n')
    print(f'mkcard: {out}: the menu and {len(PROGRAMS)} program folders, {len(rows) - 1} files ({out}.txt)')


if __name__ == '__main__':
    main()
