#!/usr/bin/env python3
r"""port_unplaced_names.py -- spell by name the numeric ROM addresses of v6 / v5 NAKA C that no slice places.

QUESTION ANSWERED
-----------------
"Which `= 0x00XXXXXX` ROM addresses are left in a ported tree's NAKA C (naka_gui_census.py 'rom addrs'),
and can they take the name v7's C gives the same field?"  v6 / v5 compile v7's C.  Where the port reads
a field's value from the tree's bytes it may stay a number; where the tree does not have the thing at
all (v6 / v5 have no IvMPver class: naka_sound_menu_drawbar.c's classdef_161_36 and its name and
propdata strings reach no byte of their image), the number is v7's address, carried, and v7's C spells
it `NAKA_ADDR(<sym>)` with <sym> defined in v7's link script.

For each tree file and each initializer line `.f = 0x00XXXXXX` (or a `{ ... }` one-liner with such
fields), the matching v7 line (difflib over the two files' lines) is looked up; a field is rewritten
when v7 spells it NAKA_ADDR(<sym>), v7's link script gives <sym> exactly that number, and the C member
that holds the field is placed by no .incbin of the tree (ported_c_rebase.placed; the member found from
the DWARF of the compiled C, notes/v6v5-port3-2026-11-06/probes/unplaced_members.py's method).  The
tree's link script gets `<sym> = <number>; /* v7's address: nothing in <tree> places it */` -- the
port's own convention (port_maincpu_version.py) -- and the file the `extern const char <sym>;` v7 has.
The file is compiled before and after and written only when the blob is identical.

RUN (repository root, built tree; lane open12/v6v5-port3)
    python3 scripts/converters/port_unplaced_names.py --tree v6 [--apply]       # also v5
"""
import argparse
import difflib
import os
import re
import subprocess
import sys
import tempfile
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
import ported_c_rebase as R                                                    # noqa: E402

LLVM = os.path.expanduser('~/compartilhado/llvm-project/build/bin')
FIELD = re.compile(r'\.(\w+) = (0x00[0-9A-Fa-f]{6})\b')


def rd(p):
    return open(p, 'rb').read().decode('latin-1')


def wr(p, t):
    open(p, 'wb').write(t.encode('latin-1'))


def compile_text(src_path, inc, ld, text):
    tmp = tempfile.mkdtemp(prefix='port-unplaced-', dir=os.environ.get('TMPDIR'))
    try:
        src = os.path.join(os.path.dirname(src_path), '.port_unplaced_tmp_' + os.path.basename(src_path))
        wr(src, text)
        try:
            o, e, b = (os.path.join(tmp, x) for x in ('x.o', 'x.elf', 'x.bin'))
            subprocess.run([LLVM + '/clang', '-target', 'tlcs900', '-ffreestanding', '-c', '-O2', '-g', '-w']
                           + (['-I', inc] if inc else []) + ['-o', o, src], check=True)
            subprocess.run([LLVM + '/ld.lld', '-T', ld, '-o', e, o], check=True)
            subprocess.run([LLVM + '/llvm-objcopy', '-O', 'binary', '-j', '.text', e, b], check=True)
            dw = subprocess.run([LLVM + '/llvm-dwarfdump', '--debug-info', e], capture_output=True, text=True).stdout
            return open(b, 'rb').read(), dw
        finally:
            os.remove(src)
    finally:
        shutil.rmtree(tmp)


def top_members(dw):
    """[(offset, name)] of the largest struct (the blob) in DWARF text."""
    blocks = re.split(r'\n(?=0x[0-9a-f]+:\s+DW_TAG_)', dw)
    structs, cur = [], None
    for blk in blocks:
        head = blk.split('\n')[0]
        if 'DW_TAG_structure_type' in head:
            m = re.search(r'DW_AT_byte_size\s+\((0x[0-9a-f]+)\)', blk)
            cur = [int(m.group(1), 16) if m else 0, []]
            structs.append(cur)
        elif 'DW_TAG_member' in head and cur is not None:
            nm = re.search(r'DW_AT_name\s+\("([^"]+)"\)', blk)
            loc = re.search(r'DW_AT_data_member_location\s+\((0x[0-9a-f]+)\)', blk)
            if nm and loc:
                cur[1].append((int(loc.group(1), 16), nm.group(1)))
    structs.sort(key=lambda s: -s[0])
    return sorted(structs[0][1]), structs[0][0]


def link_syms(ld):
    return {m.group(1): int(m.group(2), 16) for m in re.finditer(r'^(\w+) = 0x([0-9A-Fa-f]+);', rd(ld), re.M)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True, choices=['v6', 'v5'])
    ap.add_argument('--apply', action='store_true')
    a = ap.parse_args()
    uw = os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets')
    cover = R.placed(a.tree)
    total = 0
    for p in sorted(os.listdir(uw)):
        if not (p.startswith('naka_') and p.endswith('.c')):
            continue
        path, v7p = os.path.join(uw, p), os.path.join(ROOT, 'v7', 'maincpu', 'ui_widgets', p)
        ld, v7ld = path[:-2] + '_link.ld', v7p[:-2] + '_link.ld'
        if not (os.path.exists(v7p) and os.path.exists(ld) and os.path.exists(v7ld)):
            continue
        t, t7 = rd(path), rd(v7p)
        if not FIELD.search(t):
            continue
        L, L7 = t.split('\n'), t7.split('\n')
        v7syms, syms = link_syms(v7ld), link_syms(ld)
        sm = difflib.SequenceMatcher(None, L, L7, autojunk=False)
        cand = []                                    # (line index, field, number, sym)
        for tag, i1, i2, j1, j2 in sm.get_opcodes():
            if tag != 'replace' or i2 - i1 != j2 - j1:
                continue
            for i, j in zip(range(i1, i2), range(j1, j2)):
                for m in FIELD.finditer(L[i]):
                    m7 = re.search(r'\.%s = NAKA_ADDR\((\w+)\)' % m.group(1), L7[j])
                    if m7 and v7syms.get(m7.group(1)) == int(m.group(2), 16):
                        cand.append((i, m.group(1), m.group(2), m7.group(1), m.group(0)))
        if not cand:
            continue
        name = p[:-2] + '.bin'
        before, dw = compile_text(path, uw, ld, t)
        mem, size = top_members(dw)
        places = cover.get(name, [])
        ok = []
        for i, f, num, sym, txt in cand:
            # the top-level member holding the line: the last member initialized at or before line i
            owner = None
            for k in range(i, -1, -1):
                mm = re.match(r'^    \.(\w+) = ', L[k])
                if mm:
                    owner = mm.group(1)
                    break
            offs = [o for o, n in mem if n == owner]
            if not offs:
                print('  %s %s: %s %s: no DWARF member %s; skipped' % (a.tree, p, f, num, owner))
                continue
            o = offs[0]
            nxt = [x for x, _ in mem if x > o]
            end = min(nxt) if nxt else size
            hit = [(s, e) for s, e in places if (e is None or e > o) and s < end]
            if hit:
                print('  %s %s: %s.%s = %s is placed (%s); kept' % (a.tree, p, owner, f, num, hit))
                continue
            if sym in syms and syms[sym] != int(num, 16):
                print('  %s %s: %s is 0x%X in the tree\'s link script; skipped' % (a.tree, p, sym, syms[sym]))
                continue
            ok.append((i, f, num, sym, txt, owner))
        if not ok:
            continue
        for i, f, num, sym, txt, owner in ok:
            L[i] = L[i].replace(txt, '.%s = NAKA_ADDR(%s)' % (f, sym), 1)
        nt = '\n'.join(L)
        ext = sorted({sym for _, _, _, sym, _, _ in ok if 'extern const char %s;' % sym not in nt})
        if ext:
            m = re.search(r'^extern const char \w+;\n', nt, re.M)
            if not m:
                sys.exit('port_unplaced_names: %s has no extern block' % p)
            # put each extern where v7 has it: right after the extern v7 lists before it
            for sym in ext:
                m7 = re.search(r'^extern const char (\w+);\nextern const char %s;\n' % sym, t7, re.M)
                anchor = 'extern const char %s;\n' % m7.group(1) if m7 else None
                if anchor and anchor in nt:
                    nt = nt.replace(anchor, anchor + 'extern const char %s;\n' % sym, 1)
                else:
                    nt = nt[:m.start()] + 'extern const char %s;\n' % sym + nt[m.start():]
        lt = rd(ld)
        add = ['%s = 0x%08X; /* v7\'s address: nothing in %s places it */' % (sym, int(num, 16), a.tree)
               for _, _, num, sym, _, _ in ok if sym not in syms]
        nl = lt.rstrip('\n') + '\n' + '\n'.join(add) + '\n' if add else lt
        tmp_ld = os.path.join(os.environ.get('TMPDIR', '/home/fsanches/compartilhado/tmp'),
                              'port_unplaced_%s_%s' % (a.tree, os.path.basename(ld)))
        wr(tmp_ld, nl)
        after, _ = compile_text(path, uw, tmp_ld, nt)
        os.remove(tmp_ld)
        same = after == before
        for i, f, num, sym, txt, owner in ok:
            print('  %s %s: %s.%s = %s -> NAKA_ADDR(%s)' % (a.tree, p, owner, f, num, sym))
        print('%s %s: %d fields, compiled blob %s' % (a.tree, p, len(ok), 'IDENTICAL' if same else 'DIFFERS'))
        if same and a.apply:
            wr(path, nt)
            wr(ld, nl)
            total += len(ok)
    print('port_unplaced_names %s: %d fields named%s' % (a.tree, total, '' if a.apply else ' (dry run)'))


if __name__ == '__main__':
    main()
