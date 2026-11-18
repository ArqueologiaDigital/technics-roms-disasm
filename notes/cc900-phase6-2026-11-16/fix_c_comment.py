#!/usr/bin/env python3
"""fix_c_comment.py TREE_C_FILE ... -- point each function's `; C: cc900/<file>` label comment at the C file that
now defines it.

QUESTION ANSWERED / WHY: a hand source's include line for a function built from C ends in a comment naming its C
file (`Label:	.include "includes/generated/cc900/Label.s"	; C: cc900/x.c`).  When a promotion's C moves to a
sibling file after the splice (2026-11-18: dsp_config_sysex_m293.c -> _b.c, a staged prototype clashing with a built
definition), the comment still names the old file.  For every function the given C file defines (through its
`cc900-name:` map), this rewrites that comment on the label's line in the tree's .s files.  Comments only: no byte
of any image can change.  Prints each rewritten line's file and label.

usage: python3 -B notes/cc900-phase6-2026-11-16/fix_c_comment.py v10/maincpu/cc900/dsp_config_sysex_m293_b.c ...
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import stage_probe as sp                                     # noqa: E402


def main():
    for cpath in sys.argv[1:]:
        cpath = os.path.abspath(cpath)
        cdir = os.path.dirname(cpath)
        tree = os.path.dirname(cdir)
        assert os.path.basename(cdir) == 'cc900' and tree.startswith(REPO + os.sep), cpath
        text = open(cpath, encoding='latin-1').read()
        lm = {m.group(1): m.group(2) for m in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', text)}
        labels = {lm.get(sp.fn_name(d), sp.fn_name(d)) for k, d in sp.items(text) if k == 'fn'}
        want = ('; C: cc900/%s' % os.path.basename(cpath)).encode()
        for dp, dn, fn in os.walk(tree):
            if '/generated' in dp:
                continue
            for f in fn:
                if not f.endswith('.s'):
                    continue
                p = os.path.join(dp, f)
                data = open(p, 'rb').read()
                lines = data.split(b'\n')
                changed = False
                for i, line in enumerate(lines):
                    m = re.match(rb'([A-Za-z_]\w*):(\s*\.include "includes/generated/cc900/[^"]+"\s*)(; C: cc900/\S+)(.*)$',
                                 line)
                    if m and m.group(1).decode() in labels and m.group(3) != want:
                        lines[i] = m.group(1) + b':' + m.group(2) + want + m.group(4)
                        changed = True
                        print('%s: %s' % (os.path.relpath(p, REPO), m.group(1).decode()))
                if changed:
                    open(p, 'wb').write(b'\n'.join(lines))


if __name__ == '__main__':
    main()
