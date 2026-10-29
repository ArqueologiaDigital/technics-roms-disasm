#!/usr/bin/env python3
r"""naka_type_c_slices.py -- type the widget records the C blobs still hold as untyped members.

QUESTION ANSWERED
-----------------
"Which registered widget records sit inside a NAKA C blob without a naka_cls_<Class>_t type?"  The
nakarest lane typed 3,206 records; some 40 more are members of a positional local struct
(`NakaWidget_SVARI_t`, the work-RAM view records of naka_sequencer_channels.c) or plain byte
arrays (`uint8_t bytes_0464[22]`, an IvExit).  For every such record that ONE member covers
exactly (same offset, same size as the class's allsize) this:

  * replaces the member's type with naka_cls_<Class>_t and puts the record comment the GUI tools
    read above it (`/* element K of Viewable slot 0xS: <Class> ... */`);
  * rewrites its initializer as one designated field per class field, values from the blob the
    tree compiles (includes/generated/<bin>.bin), keeping every symbolic sub-initializer (SELF,
    NAKA_ADDR, ...) that sat exactly on a 4-byte field -- and refusing the record when one sits
    anywhere else;
  * drops the local typedef when nothing else uses it.

Then scripts/converters/naka_gui_symbolize.py names the values like every other record.  A record
that straddles members (an IvExit and the record after it in one `naka_dispatch_t`) is left and
reported.  --apply recompiles and refuses any file whose bin changes.

RUN (repository root, built tree)
    python3 scripts/converters/naka_type_c_slices.py --tree v10 [--apply]
"""
import argparse
import glob
import os
import re
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'generators'))
import nakarest_objtab_map as O          # noqa: E402
import nakarest_c_model as CM            # noqa: E402
import naka_gui_model as G               # noqa: E402
import naka_gui_symbolize as S           # noqa: E402
import gen_naka_gui_headers as H         # noqa: E402

SCAL = {'uint8_t': 1, 'int8_t': 1, 'char': 1, 'uint16_t': 2, 'int16_t': 2, 'uint32_t': 4, 'int32_t': 4}


def split_top(s):
    out, depth, cur = [], 0, ''
    for ch in s:
        if ch in '({':
            depth += 1
        elif ch in ')}':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def leaves_of_type(txt, tname):
    """[(offset, size)] of the scalar leaves of a local packed typedef, in declaration order."""
    m = re.search(r'typedef struct __attribute__\(\(packed\)\) \{([^{}]*)\} %s;' % re.escape(tname), txt)
    if not m:
        return None
    out, off = [], 0
    for ln in m.group(1).split('\n'):
        f = re.match(r'\s*(u?int(?:8|16|32)_t|char)\s+\w+((?:\[\d+\])*)\s*;', ln)
        if not f:
            continue
        n = 1
        for d in re.findall(r'\[(\d+)\]', f.group(2)):
            n *= int(d)
        for i in range(n):
            out.append((off, SCAL[f.group(1)]))
            off += SCAL[f.group(1)]
    return out


def flatten(expr):
    expr = expr.strip()
    if expr.startswith('{') and expr.endswith('}'):
        out = []
        for e in split_top(expr[1:-1]):
            out += flatten(e)
        return out
    return [expr]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', default='v10')
    ap.add_argument('--apply', action='store_true')
    a = ap.parse_args()
    CM.register_local_types(open(os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'naka_classes.h'),
                                 encoding='latin-1').read())
    g = G.Graph(a.tree)
    m = g.m
    blobs = []
    for p in G.tree_files(a.tree):
        t = G.read(p)
        mb = re.search(r'^#define BASE\s+0x([0-9A-Fa-f]+)u', t, re.M)
        sz = re.search(r'_Static_assert\(sizeof\(\w+\) == (\d+)', t)
        if mb and sz:
            blobs.append((int(mb.group(1), 16), int(sz.group(1)), p))
    todo = {}
    for key, (addr, links) in sorted(g.rom.items()):
        if key in g.rec:
            continue
        b = [x for x in blobs if x[0] <= addr < x[0] + x[1]]
        if b:
            todo.setdefault(b[0][2], []).append((key, addr - b[0][0]))
    nsum, skipped = 0, []
    for p, recs in sorted(todo.items()):
        txt = G.read(p)
        cb = CM.CBlob(p)
        binp, ld = S.bin_rule(a.tree, p)
        data = open(binp, 'rb').read() if a.tree in ('v10', 'v9') else open(S.bin_rule('v10', p.replace('/%s/' % a.tree, '/v10/'))[0], 'rb').read()
        done = 0
        for key, off in recs:
            c = m.record_class(g.rom[key][0])
            mem = [x for x in cb.members if x.offset == off and x.size == c['allsize']]
            if not mem:
                skipped.append('%s %s element %d (%s): no single member covers it' % (os.path.basename(p), hex(key[0]), key[1], c['name']))
                continue
            mb = mem[0]
            im = re.search(r'^(    \.%s = )(.*?)(,\n\n|,\n(?=    \.|\}))' % re.escape(mb.name), txt, re.M | re.S)
            if not im:
                skipped.append('%s %s: initializer not found' % (os.path.basename(p), mb.name))
                continue
            old = im.group(2)
            if mb.ctype in SCAL:
                lv = [(i * SCAL[mb.ctype], SCAL[mb.ctype]) for i in range(mb.size // SCAL[mb.ctype])]
            else:
                lv = leaves_of_type(txt, mb.ctype)
            ex = flatten(old)
            if lv is None or len(lv) != len(ex):
                skipped.append('%s %s: cannot map its initializer' % (os.path.basename(p), mb.name))
                continue
            sym = {o: e for (o, n), e in zip(lv, ex) if not re.match(r'^-?(0x[0-9A-Fa-f]+|\d+)$', e)}
            sym_sz = {o: n for (o, n), e in zip(lv, ex) if o in sym}
            fl, size = H.class_layout(m, c)
            parts, ok, used = [], True, set()
            for fo, fname, n, ch in fl:
                b0 = data[off + fo: off + fo + n]
                if fo in sym and sym_sz[fo] == n:
                    parts.append('        .%s = %s,' % (fname, sym[fo]))
                    used.add(fo)
                    continue
                if any(fo <= so < fo + n for so in sym):
                    ok = False
                    break
                if n == 8:
                    v = struct.unpack('<4h', b0)
                    parts.append('        .%s = { %d, %d, %d, %d },' % ((fname,) + v))
                else:
                    v = int.from_bytes(b0, 'little')
                    parts.append('        .%s = 0x%0*X,' % (fname, 2 * n, v))
            gaps, cur = [], 0
            for fo, f_, n, ch in fl:
                if fo > cur:
                    gaps.append((cur, fo - cur))
                cur = fo + n
            if cur < size:
                gaps.append((cur, size - cur))
            if not ok or set(sym) - used:
                skipped.append('%s %s: a symbolic initializer is not on a 4-byte field' % (os.path.basename(p), mb.name))
                continue
            for go, gn in gaps:
                parts.append('        ._pad_%d = { %s },' % (go, ', '.join('0x%02X' % v for v in data[off + go: off + go + gn])))
            new_init = '{\n' + '\n'.join(parts) + '\n    }'
            txt = txt[:im.start(2)] + new_init + txt[im.end(2):]
            decl = re.compile(r'^(\s+)%s %s((?:\[\d+\])?);[^\n]*$' % (re.escape(mb.ctype), re.escape(mb.name)), re.M)
            res = G.read(p)
            rn = ''
            r_ = m.by_slot.get(key[0] + 0x300)
            cid = [k for k, v in m.classes.items() if v is c][0]
            txt, nsub = decl.subn(lambda d: '%s/* element %d of Viewable slot 0x%X: %s (class id 0x%08X) */\n%snaka_cls_%s_t %s;'
                                  % (d.group(1), key[1], key[0], c['name'], cid, d.group(1), c['name'], mb.name), txt, count=1)
            if not nsub:
                skipped.append('%s %s: declaration not found' % (os.path.basename(p), mb.name))
                continue
            # drop the local typedef when nothing uses it any more
            if mb.ctype not in SCAL and len(re.findall(r'\b%s\b' % re.escape(mb.ctype), txt)) == 1:
                txt = re.sub(r'(/\*[^\n]*\*/\n)?typedef struct __attribute__\(\(packed\)\) \{[^{}]*\} %s;\n\n?' % re.escape(mb.ctype), '', txt, count=1)
            done += 1
        if done:
            same = S.compile_c(p, ld, txt) == S.compile_c(p, ld, G.read(p))
            print('%-32s %d records typed %s' % (os.path.basename(p), done, 'IDENTICAL' if same else 'DIFFERS'))
            if same and a.apply:
                open(p, 'wb').write(txt.encode('utf-8', 'surrogateescape'))
            nsum += done if same else 0
    print('%s: %d records typed; %d left' % (a.tree, nsum, len(skipped)))
    for s in skipped:
        print('  ' + s)


if __name__ == '__main__':
    main()
