#!/usr/bin/env python3
r"""naka_type_straddling_records.py -- type the NAKA widget records that straddle C members.

QUESTION ANSWERED
-----------------
"Which registered widget records inside a NAKA C blob have no naka_cls_<Class>_t member because the
member boundaries of the old positional typing cut across them, and can they be typed without
changing one compiled byte?"  scripts/converters/naka_type_c_slices.py types a record that ONE member
covers exactly; it reports the others as "no single member covers it" (20 per tree on 2026-11-06).
Typically an IvExit (22 bytes) and the record after it were read as one 24-byte `naka_dispatch_t`,
so `.link_ptr = 0x00EB0000` is two rectangle words, not a ROM address (register item N-45db7885).

For each such record this:

  * replaces the members covering exactly [record start, record end) by one naka_cls_<Class>_t member
    (nakarest_c_model.CBlob.retype: a boundary inside a member splits that member into two byte pieces,
    values from the compiled blob; a member with a symbolic initializer is never split);
  * names the member after the element's assembly label when the label sits on the record
    (`m.name_of`), else `<Class>_s<slot>_e<k>`, and puts the record comment the GUI tools read above it
    (`/* element K of Viewable slot 0xS: <Class> (class id 0x...) */`);
  * writes one designated field per class field, values from the blob, keeping every symbolic
    initializer (SELF, NAKA_ADDR, ...) that sat on a field of the same offset and size -- and refusing
    the record when one sits anywhere else;
  * types the records of a file in address order, so a piece split off one record is consumed by the
    next when that one is in the list too.

--strings (a second pass, after the first is applied and symbolized): a typed record field whose value is a
numeric address inside its own blob, at the start of an untyped member that holds exactly one NUL-terminated
string (plus 0x00 / 0xFF padding), gets that member as `char <Record>_<Field>[N] = "..."` and the field as
`SELF(<Record>_<Field>)` -- the old EditSw records whose `str` points at the text right after the record.

Then scripts/converters/naka_gui_symbolize.py names the values (OBJ_ links, NAKA_XYWH, VF_ flags ...).
--apply recompiles each changed file and writes it only if the compiled blob is identical.

The records and their offsets come from v10 (its graph reads the Viewable tables from the v10 ROM); every
tree's C file of the same name has v10's struct layout.  The bytes: v10 / v9 read their own
includes/generated/<bin>.bin; v7 reads v10's bin of the same file (its C records are v10's; only BASE /
PORT_BASE / RAM-cell values differ, and those are not record fields this rewrites); v6 / v5, whose C has
values of its own since lane open11/v6v5-port2, read what their C compiles to.  Each changed
file is compiled before and after with the tree's own link script and written only when identical.  A
record already typed in a tree (by an earlier run) is found typed and left.

RUN (repository root, built tree; lane kn5000-notes, 2026-11-06)
    python3 scripts/converters/naka_type_straddling_records.py --tree v10            # report
    python3 scripts/converters/naka_type_straddling_records.py --tree v10 --apply
    python3 scripts/converters/naka_gui_symbolize.py --tree v10 --apply
    python3 scripts/converters/naka_type_straddling_records.py --tree v10 --strings --apply
    python3 scripts/converters/naka_type_c_slices.py --tree v10                      # what is left
"""
import argparse
import os
import re
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'generators'))
import nakarest_c_model as CM            # noqa: E402
import naka_gui_model as G               # noqa: E402
import naka_gui_symbolize as S           # noqa: E402
import gen_naka_gui_headers as H         # noqa: E402

NUM = re.compile(r'^-?(0x[0-9A-Fa-f]+|\d+)u?$')


def flatten(expr):
    expr = expr.strip()
    if expr.startswith('{') and expr.endswith('}'):
        out = []
        for e in CM.split_top_level(expr[1:-1]):
            if e.strip():
                out += flatten(e)
        return out
    return [expr]


def leaf_layout(mb):
    """[(offset within the member, size)] of a member's scalar leaves, or None."""
    t = mb.ctype.replace('const ', '')
    scal = {'uint8_t': 1, 'int8_t': 1, 'char': 1, 'uint16_t': 2, 'int16_t': 2, 'uint32_t': 4, 'int32_t': 4}
    if t in scal:
        n = mb.size // scal[t]
        return [(i * scal[t], scal[t]) for i in range(n)]
    if t == 'naka_dispatch_t':
        return [(0, 4), (4, 2), (6, 2), (8, 4), (12, 4), (16, 4), (20, 4)]
    return None


def symbolic_leaves(cb, k0, k1):
    """{absolute offset: (size, expr, member name)} of the symbolic scalar initializers of members k0..k1;
    None when a member's initializer cannot be mapped onto its leaves (then nothing symbolic may be in it)."""
    out = {}
    for k in range(k0, k1 + 1):
        mb, e = cb.members[k], cb.entries[k]
        if not CM.SYMBOLIC_RE.search(e.expr):
            continue
        lv = leaf_layout(mb)
        ex = flatten(e.expr)
        if mb.ctype.replace('const ', '') == 'naka_dispatch_t' and e.expr.strip().startswith('{'):
            # designated: { .header = ..., .field_04 = ... }
            ex = [re.sub(r'^\.\w+\s*=\s*', '', x) for x in ex]
        if lv is None or len(lv) != len(ex):
            return None
        for (o, n), x in zip(lv, ex):
            if CM.SYMBOLIC_RE.search(x):
                out[mb.offset + o] = (n, x, mb.name)
    return out


def presplit(cb, at, data):
    """Make `at` a member boundary like CBlob.split_word, but allow a member that is a SELF target at its
    start (the piece before `at` keeps the member's name, so SELF(name) keeps its address) and a member
    with symbolic leaves (the caller has checked that each lies in the record and is kept or is not a
    pointer).  Values of the two byte pieces come from the compiled blob.  Returns None or why not."""
    k = cb.index_at(at)
    mb = cb.members[k]
    if mb.offset == at:
        return None
    subs = cb.self_targets().get(mb.name)
    if subs and any(subs):
        return 'SELF into the middle of %s' % mb.name
    e = cb.entries[k]
    pieces = []
    for i, (a0, b0) in enumerate(((mb.offset, at), (at, mb.offset + mb.size))):
        n = b0 - a0
        nm = mb.name if (i == 0 and subs is not None) else ('field_%04x' % a0 if n == 1 else 'bytes_%04x' % a0)
        if n == 1:
            pc = CM.Member(mb.indent, 'uint8_t', nm, '', '', [])
            ex = '0x%02X' % data[a0]
        else:
            pc = CM.Member(mb.indent, 'uint8_t', nm, '[%d]' % n, '', [])
            ex = '{ ' + ', '.join('0x%02X' % x for x in data[a0:b0]) + ' }'
        pc.offset = a0
        pieces.append((pc, ex))
    pieces[0][0].pre = mb.pre
    pieces[0][0].tail = mb.tail
    cb.members[k:k + 1] = [pc for pc, _ in pieces]
    cb.entries[k:k + 1] = [CM.Entry(pieces[0][0].name, e.pre, pieces[0][1]),
                           CM.Entry(pieces[1][0].name, '\n\n    ', pieces[1][1])]
    cb._reindex()
    return None


def record_strings(tree, apply):
    """The --strings pass (docstring)."""
    total = 0
    for p in G.tree_files(tree):
        base_txt = open(p, encoding='latin-1').read()
        mb_ = re.search(r'^#define BASE\s+0x([0-9A-Fa-f]+)u', base_txt, re.M)
        if not mb_ or 'SELF(' not in base_txt or not re.search(r'= 0x00[0-9A-Fa-f]{6},', base_txt):
            continue
        base = int(mb_.group(1), 16)
        binp, ld = S.bin_rule(tree, p)
        if binp is None:
            continue
        data = open(binp if tree in ('v10', 'v9') else S.bin_rule('v10', p.replace('/%s/' % tree, '/v10/'))[0], 'rb').read()
        try:
            cb = CM.CBlob(p)
        except (KeyError, SystemExit) as ex:
            print('%-32s not parsed (%s)' % (os.path.basename(p), ex))
            continue
        done = []
        for k, (mb, e) in enumerate(list(zip(cb.members, cb.entries))):
            if not mb.ctype.startswith('naka_cls_'):
                continue
            for fm in re.finditer(r'\.(\w+) = (0x00[0-9A-Fa-f]{6}),', e.expr):
                v = int(fm.group(2), 16)
                o = v - base
                if not 0 <= o < cb.size:
                    continue
                t = cb.members[cb.index_at(o)]
                if t.offset != o or t.ctype.startswith('naka_cls_') or t.ctype.replace('const ', '') not in ('uint8_t', 'char', 'uint16_t'):
                    continue
                b = data[o:o + t.size]
                z = b.find(b'\x00')
                if z < 1 or any(x not in (0, 0xFF) for x in b[z:]) or any(x < 0x20 for x in b[:z]):
                    continue
                name = '%s_%s' % (mb.name, fm.group(1).capitalize())
                if name in cb.by_name:
                    continue
                done.append((k, fm.group(0), '.%s = SELF(%s),' % (fm.group(1), name), o, t.size, name, b))
        if not done:
            continue
        for k, old, new, o, n, name, b in done:
            cb.entries[k].expr = cb.entries[k].expr.replace(old, new, 1)
        for k, old, new, o, n, name, b in sorted(done, key=lambda x: -x[3]):
            cb.retype(o, o + n, [CM.string_member(name, b)], data)
        txt = cb.render()
        u8 = lambda t: t.encode('latin-1').decode('utf-8', 'surrogateescape')
        same = S.compile_c(p, ld, u8(txt)) == S.compile_c(p, ld, u8(base_txt))
        print('%-32s %d record strings %s' % (os.path.basename(p), len(done), 'IDENTICAL' if same else 'DIFFERS'))
        for d in done:
            print('    %s -> %s %r' % (d[1], d[5], d[6]))
        if same and apply:
            open(p, 'wb').write(txt.encode('latin-1'))
            total += len(done)
    print('%s: %d record strings named' % (tree, total))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', default='v10')
    ap.add_argument('--apply', action='store_true')
    ap.add_argument('--strings', action='store_true')
    a = ap.parse_args()
    if a.strings:
        CM.register_local_types(open(os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'naka_classes.h'),
                                     encoding='latin-1').read())
        return record_strings(a.tree, a.apply)
    CM.register_local_types(open(os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'naka_classes.h'),
                                 encoding='latin-1').read())
    # The records to type and their offsets come from v10's graph and blobs (the Viewable tables are read from
    # v10's ROM, nakarest_objtab_map.Map('v10')); a tree's C file holds the same struct layout as v10's file of
    # the same name, so the same offsets apply there, and the compile check below proves it per file.
    g = G.Graph('v10')
    m = g.m
    blobs = []
    for p in G.tree_files('v10'):
        t = G.read(p)
        mb = re.search(r'^#define BASE\s+0x([0-9A-Fa-f]+)u', t, re.M)
        sz = re.search(r'_Static_assert\(sizeof\(\w+\) == (\d+)', t)
        if mb and sz:
            blobs.append((int(mb.group(1), 16), int(sz.group(1)), p))
    todo = {}
    for key, (addr, links) in sorted(g.rom.items()):
        b = [x for x in blobs if x[0] <= addr < x[0] + x[1]]
        if b:
            tp = b[0][2].replace('/v10/', '/%s/' % a.tree)
            if os.path.exists(tp):
                todo.setdefault(tp, []).append((addr - b[0][0], key, addr))
    total, left, dropped = 0, [], []
    for p, recs in sorted(todo.items()):
        base_txt = open(p, encoding='latin-1').read()       # CBlob's own reading: bytes kept as they are
        binp, ld = S.bin_rule(a.tree, p)
        if a.tree in ('v10', 'v9'):
            data = open(binp, 'rb').read()
        elif a.tree in ('v6', 'v5'):
            # the ported trees' C has values of its own (ported_c_rebase.py --own-values / --hand-c, lane
            # open11/v6v5-port2): their records take what the tree's C compiles to now, which is the tree's
            # ROM wherever an .incbin places it -- v10's bytes made 8 records of naka_technichord_part.c and
            # NakaWidget_PanelSimulator DIFFER
            data = S.compile_c(p, ld, open(p, encoding='latin-1').read().encode('latin-1').decode('utf-8', 'surrogateescape'))
        else:
            data = open(S.bin_rule('v10', p.replace('/%s/' % a.tree, '/v10/'))[0], 'rb').read()
        good_txt, done = base_txt, 0
        cb0 = CM.CBlob(p)
        typed = {x.offset: x.size for x in cb0.members if x.ctype.startswith('naka_cls_')}
        recs = [r for r in recs if typed.get(r[0]) != m.record_class(r[2])['allsize']]
        if not recs:
            continue
        # parsed beside the source, so CBlob finds the headers it #includes
        tmp = os.path.join(os.path.dirname(p), '.naka_straddle_tmp_' + os.path.basename(p))
        try:
            for off, key, addr in sorted(recs):
                c = m.record_class(addr)
                size = c['allsize']
                open(tmp, 'w', encoding='latin-1', newline='').write(good_txt)
                cb = CM.CBlob(tmp)
                why = None
                lo, hi = off, off + size
                k0, k1 = cb.index_at(lo), cb.index_at(hi - 1)
                sym = symbolic_leaves(cb, k0, k1)      # of the whole members, before any split
                fl, csize = H.class_layout(m, c)
                parts, used, fp = [], set(), []
                if sym is None:
                    why = 'a symbolic initializer that cannot be mapped to its bytes'
                else:
                    out = [v for o, v in sym.items() if o + v[0] <= lo or o >= hi]
                    if out:
                        why = 'symbolic %s = %s outside the record, in a member it shares' % (out[0][2], out[0][1])
                    sym = {o: v for o, v in sym.items() if not (o + v[0] <= lo or o >= hi)}
                if why is None:
                    for fo, fname, n, ch in fl:
                        b0 = data[lo + fo: lo + fo + n]
                        if len(b0) != n:
                            why = 'the blob ends inside field %s' % fname
                            break
                        sv = sym.get(lo + fo)
                        if sv and sv[0] == n == 4:
                            parts.append('        .%s = %s,' % (fname, sv[1]))
                            used.add(lo + fo)
                        elif n == 8:
                            parts.append('        .%s = { %d, %d, %d, %d },' % ((fname,) + struct.unpack('<4h', b0)))
                        else:
                            parts.append('        .%s = 0x%0*X,' % (fname, 2 * n, int.from_bytes(b0, 'little')))
                if why is None:
                    # a symbolic leaf on no 4-byte field of the class (inside a rectangle, across two 16-bit
                    # fields or across the record's edge) is not a pointer of this record: its bytes are
                    # spelled as the field values they are, and the drop is reported
                    fp = [(v[2], v[1], o - lo) for o, v in sorted(sym.items()) if o not in used]
                    cur = 0
                    for fo, f_, n, ch in fl:
                        if fo > cur:
                            parts.append('        ._pad_%d = { %s },' % (cur, ', '.join('0x%02X' % v for v in data[lo + cur: lo + fo])))
                        cur = fo + n
                    if cur < csize:
                        parts.append('        ._pad_%d = { %s },' % (cur, ', '.join('0x%02X' % v for v in data[lo + cur: lo + csize])))
                    for at in (lo, hi):
                        if why is None and at < cb.size:
                            why = presplit(cb, at, data)
                if why is None:
                    lab = m.name_of(addr)
                    name = lab[1] if lab and lab[0] == addr else '%s_s%03X_e%d' % (c['name'], key[0], key[1])
                    name = re.sub(r'\W', '_', name)
                    if name in cb.by_name:
                        name = '%s_s%03X_e%d' % (c['name'], key[0], key[1])
                    cid = [k for k, v in m.classes.items() if v is c][0]
                    keeps = {cb.members[k].name for k in range(cb.index_at(lo), cb.index_at(hi - 1) + 1)}
                    nm = CM.NewMember('naka_cls_%s_t' % c['name'], name, '', size,
                                      '{\n' + '\n'.join(parts) + '\n    }',
                                      pre_lines=['    /* element %d of Viewable slot 0x%X: %s (class id 0x%08X) */'
                                                 % (key[1], key[0], c['name'], cid)],
                                      keeps=keeps)
                    try:
                        cb.retype(lo, hi, [nm], data)
                    except SystemExit as ex:
                        why = str(ex).split(': ', 1)[-1]
                if why is not None:
                    left.append('%s %s element %d (%s) +0x%x: %s' % (os.path.basename(p), hex(key[0]), key[1],
                                                                       c['name'], off, why))
                    continue
                good_txt = cb.render()
                done += 1
                for mbn, ex, rel in fp:
                    dropped.append('%s %s +%d: %s = %s (not on a 4-byte field)' % (os.path.basename(p), name, rel, mbn, ex))
        finally:
            if os.path.exists(tmp):
                assert os.path.dirname(tmp) == os.path.dirname(p) and os.path.basename(tmp).startswith('.naka_straddle_tmp_')
                os.remove(tmp)
        if done:
            u8 = lambda t: t.encode('latin-1').decode('utf-8', 'surrogateescape')
            same = S.compile_c(p, ld, u8(good_txt)) == S.compile_c(p, ld, u8(base_txt))
            print('%-32s %d records typed %s' % (os.path.basename(p), done, 'IDENTICAL' if same else 'DIFFERS'))
            if same and a.apply:
                open(p, 'wb').write(good_txt.encode('latin-1'))
            total += done if same else 0
    print('%s: %d records typed; %d left' % (a.tree, total, len(left)))
    for s in left:
        print('  ' + s)
    print('false pointers spelled as field values: %d' % len(dropped))
    for s in dropped:
        print('  ' + s)


if __name__ == '__main__':
    main()
