#!/usr/bin/env python3
r"""name_class_descriptor_strings.py -- the class-name / propdata strings that NAKA class descriptors in C
still point at by number, as labels in the assembly.

QUESTION ANSWERED
-----------------
"Which string does `.name = 0x00E55CC4` (a Class descriptor in naka_widget_descriptors.c) point at?"
name_class_string_pointers.py named the descriptor pointers whose target is an `.incbin` slice.  The
rest point into strings that the ASSEMBLY spells, as `aligned_string "PsHarmOnOffBox"` lines with no
label (naka_widget_desc_dispatch.s: the East class table 0x163's strings, naka_effects_eq_dispatch.s:
the Kubo table 0x168's).  For every numeric literal in the `name` (+12) or `propdata` (+16) field of a
class descriptor -- `{ NAKA_ADDR(<Class>Proc), NAKA_CLASS(..), allsize, selfsize, NAME, PROPDATA, .. }`
or `.proc = NAKA_ADDR(<Class>Proc), ... .name = NAME, .propdata = PROPDATA` -- this:

  * finds the assembly line that emits the target: from the nearest label at or before it (the tree's
    symbols/maincpu_<tree>_symbols_reference.txt), it walks the following lines, sizing each
    `aligned_string` (.asciz + .p2align 1, 0xff), `.byte`, `.ascii`, `.asciz`, `.short`, `.long` and
    `.incbin f, off, len`, to the line that starts exactly there (a target inside a line is reported,
    never labelled);
  * labels that line `ClassName_<Class>:` / `ClassPropdata_<Class>:` (an existing label there is used
    as it is), checks that the string it emits is the class's name (for a name), and
  * spells the literal NAKA_ADDR(<label>), with an extern and the literal's own value in the file's link
    script, so every tree's compiled blob is unchanged (v7/v6/v5 patch it as before).
Any other literal of the tree's C with the same value (naka_block_007.c's split descriptor fields)
takes the same label.
v7 / v6 / v5 afterwards: the link scripts take each label's address in that tree (its symbols file), as
generate_v7_naka_link_scripts.py does for v7, and the C-divergence jsons are recomputed
(scripts/build/regenerate_v7_c_divergence.py --apply; ported_c_rebase.py --regen for v6 / v5).  With v10's
value there, the dispatch census reads a code pointer of v7 / v6 / v5 as numeric (it rose 0 -> 1 until then).

v9 is labelled at its own addresses (they equal v10's).  v7, v6 and v5 compile v10's literals, so their
label goes where the walk from THE SAME anchor label by the same distance lands in their assembly, and
only when the string there is the one v10 has.

RUN (repository root, symbols files in sync -- make gate checks that)
    python3 scripts/converters/name_class_descriptor_strings.py --tree v10 [--apply]
    python3 scripts/converters/name_class_descriptor_strings.py --tree v9 --rev HEAD --apply   # v9 v7 v6 v5
"""
import argparse
import bisect
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ['v10', 'v9', 'v7', 'v6', 'v5']
LIT = r'0x00[EeFf][0-9A-Fa-f]{5}'
POS = re.compile(r'\{ NAKA_ADDR\((\w+?)Proc\), NAKA_CLASS\(\w+\), \d+, \d+, (' + LIT + r'|[^,]+), (' + LIT + r'|[^,]+),')
DES = re.compile(r'\.proc = NAKA_ADDR\((\w+?)Proc\),[^}]*?\.name = (' + LIT + r'|[^,]+), \.propdata = (' + LIT + r'|[^,]+),')


def read(p):
    return open(p, 'rb').read().decode('latin-1')


def syms(tree):
    out = {}
    for ln in open(os.path.join(ROOT, 'symbols', 'maincpu_%s_symbols_reference.txt' % tree)):
        p = ln.split()
        if len(p) == 2 and not ln.startswith('#'):
            out[p[0]] = int(p[1], 16)
    return out


def c_files(tree):
    return sorted(glob.glob(os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', '*.c')))


def link_script(c):
    if c.endswith('control_menu_header.c'):
        return os.path.join(os.path.dirname(c), 'naka_ctrl_menu_link.ld')
    return c[:-2] + '_link.ld'


def wanted(tree, rev=None):
    """literal value -> label name, from the class descriptors of the tree's C (at git REV if given:
    after v10 is converted, the other trees take v10's literals from the commit before)."""
    import subprocess
    out = {}
    for c in c_files(tree):
        t = read(c) if not rev else subprocess.run(
            ['git', 'show', '%s:%s' % (rev, os.path.relpath(c, ROOT))], cwd=ROOT, capture_output=True).stdout.decode('latin-1')
        for rx in (POS, DES):
            for m in rx.finditer(t):
                cls = m.group(1)
                for kind, v in (('ClassName_', m.group(2)), ('ClassPropdata_', m.group(3))):
                    if re.fullmatch(LIT, v.strip()):
                        out.setdefault(int(v, 16), (kind + cls, cls if kind == 'ClassName_' else None))
    return out


def asm_lines(tree):
    """label -> flat index; file -> lines (bytes); flat: [(file, line index)] in emission order
    (the .include tree of kn5000_<tree>_program.s expanded)."""
    base = os.path.join(ROOT, tree, 'maincpu')
    text, flat, labs = {}, [], {}

    def expand(p, depth=0):
        if p not in text:
            text[p] = open(p, 'rb').read().split(b'\n')
        for i, ln in enumerate(text[p]):
            m = re.match(rb'^\s*\.include\s+"([^"]+)"', ln)
            if m and depth < 8:
                q = os.path.join(base, m.group(1).decode())
                if os.path.exists(q):
                    expand(q, depth + 1)
                continue
            m = re.match(rb'^([A-Za-z_][\w.]*):', ln)
            if m:
                labs.setdefault(m.group(1).decode(), len(flat))
            flat.append((p, i))
    expand(os.path.join(base, 'kn5000_%s_program.s' % tree))
    return labs, (text, flat)


def strlit(s):
    """bytes of a GNU-as string literal body."""
    out, i = bytearray(), 0
    while i < len(s):
        ch = s[i]
        if ch == '\\':
            n = s[i + 1]
            if n == 'x':
                m = re.match(r'[0-9A-Fa-f]{1,2}', s[i + 2:])
                out.append(int(m.group(0), 16))
                i += 2 + len(m.group(0))
                continue
            if n in '01234567':
                m = re.match(r'[0-7]{1,3}', s[i + 1:])
                out.append(int(m.group(0), 8))
                i += 1 + len(m.group(0))
                continue
            out.append({'n': 10, 't': 9, '0': 0, '\\': 92, '"': 34}.get(n, ord(n)))
            i += 2
            continue
        out.append(ord(ch))
        i += 1
    return bytes(out)


def line_size(body, addr):
    """(bytes the directive at addr emits, its text or None) -- None when it cannot be sized."""
    b = body.split(b';')[0].strip().decode('latin-1')
    if b.startswith('//'):
        return 0, None
    m = re.match(r'^aligned_string\s+"((?:[^"\\]|\\.)*)"\s*$', b)
    if m:
        s = strlit(m.group(1))
        n = len(s) + 1
        return n + ((addr + n) & 1), s
    m = re.match(r'^\.(asciz|ascii)\s+"((?:[^"\\]|\\.)*)"\s*$', b)
    if m:
        s = strlit(m.group(2))
        return len(s) + (m.group(1) == 'asciz'), s
    m = re.match(r'^\.(byte|short|hword|long)\s+(.*)$', b)
    if m:
        return {'byte': 1, 'short': 2, 'hword': 2, 'long': 4}[m.group(1)] * len(m.group(2).split(',')), None
    m = re.match(r'^\.incbin\s+"[^"]+"\s*,\s*(\w+)\s*,\s*(\w+)\s*$', b)
    if m:
        return int(m.group(2), 0), None
    if b == '' or b.startswith(('.p2align', '.balign')) and False:
        return 0, None
    if b == '':
        return 0, None
    return None, None


def walk(tf, start, addr0, target):
    """from flat line `start` (a label line at addr0) to the line that starts at target -> ((file, line
    index), string it emits) or None."""
    text, flat = tf
    i = start
    a = addr0
    first = True
    while i < len(flat):
        p, j = flat[i]
        ln = text[p][j]
        m = re.match(rb'^([A-Za-z_][\w.]*):(.*)$', ln)
        body = m.group(2) if m else ln
        if m and not first and a > target:
            return None
        first = False
        if body.strip().startswith(b'.equ') or body.strip().startswith(b'.set'):
            i += 1
            continue
        n, s = line_size(body, a)
        if n is None:
            return None
        if a == target and n:
            return flat[i], s
        a += n
        if a > target:
            return None
        i += 1
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', default='v10', choices=TREES)
    ap.add_argument('--apply', action='store_true')
    ap.add_argument('--rev', help='read v10\'s literals from this commit (v10 already converted)')
    a = ap.parse_args()
    want = wanted('v10', a.rev)              # the literals are v10 addresses in every tree's C
    s10 = syms('v10')
    st = syms(a.tree)
    rows10 = sorted((v, k) for k, v in s10.items())
    labs10, text10 = asm_lines('v10')
    labs, text = (labs10, text10) if a.tree == 'v10' else asm_lines(a.tree)
    taken = set(st)
    place = {}                               # literal -> label
    new_labels = []                          # (file, line index, label)
    for v, (name, cls) in sorted(want.items()):
        # anchor: nearest v10 label at or before v that the asm defines (and the tree has)
        k = bisect.bisect_right(rows10, (v, '~')) - 1
        hit = None
        while k >= 0 and v - rows10[k][0] < 0x400:
            av, an = rows10[k]
            if an in labs10 and an in labs and an in st:
                r10 = walk(text10, labs10[an], av, v)
                if r10:
                    rt = walk(text, labs[an], st[an], st[an] + v - av)
                    if rt and rt[1] == r10[1]:
                        hit = (rt[0][1], r10[1], rt[0][0])
                break
            k -= 1
        if not hit:
            print('  0x%06x %-34s no line starts there' % (v, name))
            continue
        i, sbytes, p = hit
        if cls and sbytes != cls.encode():
            print('  0x%06x %-34s the line emits %r, not the class name' % (v, name, sbytes))
            continue
        m = re.match(rb'^([A-Za-z_][\w.]*):', text[0][p][i])
        if m:
            place[v] = m.group(1).decode()
            continue
        lab = name
        while lab in taken:
            lab += '_'
        taken.add(lab)
        place[v] = lab
        new_labels.append((p, i, lab))
    nlit = 0
    for c in c_files(a.tree):
        t = read(c)
        used = {}

        def rep(m):
            v = int(m.group(0), 16)
            if v in place:
                used[place[v]] = v
                return 'NAKA_ADDR(%s)' % place[v]
            return m.group(0)
        # only in code, not in comments
        parts = re.split(r'(/\*.*?\*/|//[^\n]*)', t, flags=re.S)
        t2 = ''.join(x if x.startswith(('/*', '//')) else re.sub(r'(?<![\w.])' + LIT + r'\b', rep, x) for x in parts)
        if t2 == t:
            continue
        nlit += sum(1 for _ in re.finditer(r'NAKA_ADDR\((%s)\)' % '|'.join(map(re.escape, used)), t2)) - \
            sum(1 for _ in re.finditer(r'NAKA_ADDR\((%s)\)' % '|'.join(map(re.escape, used)), t))
        add = [l for l in sorted(used) if 'extern const char %s;' % l not in t2]
        if add:
            last = list(re.finditer(r'^extern const char \w+;\n', t2, re.M))[-1]
            t2 = t2[:last.end()] + ''.join('extern const char %s;\n' % l for l in add) + t2[last.end():]
        ld = link_script(c)
        ldt = read(ld)
        ldadd = ''.join('%s = 0x%08X;\n' % (l, used[l]) for l in sorted(used) if not re.search(r'^%s = ' % re.escape(l), ldt, re.M))
        print('  %-32s %d labels' % (os.path.basename(c), len(used)))
        if a.apply:
            open(c, 'wb').write(t2.encode('latin-1'))
            open(ld, 'wb').write((ldt.rstrip('\n') + '\n' + ldadd).encode('latin-1'))
    if a.apply:
        for p, i, lab in new_labels:
            L = text[0][p]
            L[i] = lab.encode() + b':\t' + L[i].lstrip()
        for p in {p for p, _, _ in new_labels}:
            open(p, 'wb').write(b'\n'.join(text[0][p]))
    print('%s: %d targets placed, %d new asm labels, %d literals named' % (a.tree, len(place), len(new_labels), nlit))


if __name__ == '__main__':
    sys.exit(main())
