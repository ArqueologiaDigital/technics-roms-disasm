#!/usr/bin/env python3
"""kn7000_migration_paths.py -- repoint kn7000/'s paths after it moved one directory deeper (2026-10-19).

QUESTION ANSWERED
  The KN7000 disassembly used to be its own repository at ~/compartilhado/kn7000_disassembly; it is now
  kn7000/ inside technics-roms-disasm. Which of its paths still assume the old place, and what must they
  become? Three kinds, each rewritten here:

    1. sibling repositories named relative to the old root (`../kn7000_extraction`, `../KN7000`,
       `../technics_romsets`, `../technics_roms`, `../nonfree`, `../mame-sony-video`,
       `../kn7000_mame[_build]`): one more `../`, wherever they are written as one, two or three levels
       up (Makefile defaults and tool defaults resolve from the kn7000 root; dsp/*.md links from dsp/;
       tools/cnv_romdump/Makefile from its own directory). `$REPO/../X` in shell scripts likewise.
    2. the old absolute path, `~/compartilhado/kn7000_disassembly` or `/home/.../kn7000_disassembly`:
       becomes `.../technics-roms-disasm/kn7000`.
    3. prose naming the old repository as the place to run from ("the kn7000_disassembly root").

  NOT rewritten, on purpose:
    - tools/cnv_romdump/releases/2026-10-19/: a frozen copy of what went to a real instrument, covered
      by its SHA1SUMS;
    - tools/make_placeholder_waveroms.py's two provenance strings, which are written into generated
      files whose hashes other repositories record.

USAGE
  python3 scripts/repair/kn7000_migration_paths.py            # list what would change
  python3 scripts/repair/kn7000_migration_paths.py --apply    # rewrite the files
  Then: cd kn7000 && make verify verify-sp7001 verify-picture (the byte-exact gates).
"""
import os
import re
import subprocess
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
SIBLINGS = r'(kn7000_extraction|KN7000|technics_romsets|technics_roms|nonfree|mame-sony-video|kn7000_mame_build|kn7000_mame)\b'
SKIP_PREFIX = 'kn7000/tools/cnv_romdump/releases/'
KEEP_FILES = {'kn7000/tools/make_placeholder_waveroms.py'}

RULES = [
    # 1. relative sibling paths: exactly one, two or three '../' (not part of a longer run)
    (re.compile(r'(?<![./\w])((?:\.\./){1,3})' + SIBLINGS), lambda m: '../' + m.group(1) + m.group(2)),
    (re.compile(r'\$REPO/\.\./' + SIBLINGS), lambda m: '$REPO/../../' + m.group(1)),
    # 2. the old absolute path
    (re.compile(r'(/home/fsanches/compartilhado|~/compartilhado|\$HOME/compartilhado)/kn7000_disassembly\b'),
     lambda m: m.group(1) + '/technics-roms-disasm/kn7000'),
    # 3. prose: "the kn7000_disassembly root" / "checkout"
    (re.compile(r'\bthe kn7000_disassembly (root|checkout)'), lambda m: 'technics-roms-disasm/kn7000'),
    (re.compile(r'\bkn7000_disassembly (tools/|notes/|src/)'), lambda m: 'technics-roms-disasm kn7000/' + m.group(1)),
]

apply = '--apply' in sys.argv
# Rule 1 adds a level every time it runs, so it must run once: kn7000/Makefile's first sibling default
# says whether it already has.
if 'EXTRACT_DIR ?= ../../kn7000_extraction' in open(os.path.join(ROOT, 'kn7000', 'Makefile')).read():
    sys.exit('already applied: kn7000/Makefile has EXTRACT_DIR ?= ../../kn7000_extraction; nothing to do')
files = subprocess.check_output(['git', '-C', ROOT, 'ls-files', 'kn7000'], text=True).split()
changed = 0
for rel in files:
    if rel.startswith(SKIP_PREFIX) or rel in KEEP_FILES:
        continue
    path = os.path.join(ROOT, rel)
    try:
        text = open(path, encoding='utf-8').read()
    except (UnicodeDecodeError, IsADirectoryError):
        continue                                    # binaries (pictures, images) hold no paths
    new = text
    for rx, fn in RULES:
        new = rx.sub(fn, new)
    if new != text:
        changed += 1
        for a, b in zip(text.splitlines(), new.splitlines()):
            if a != b:
                print(f'{rel}:\n  - {a.strip()[:150]}\n  + {b.strip()[:150]}')
        if apply:
            open(path, 'w', encoding='utf-8').write(new)
print(f'{changed} file(s) {"rewritten" if apply else "would change"}')
