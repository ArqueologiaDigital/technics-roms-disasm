#!/usr/bin/env python3
"""Port v10's staged firmware C to v9 / v7 / v6 / v5, from the ROM bytes.

QUESTION ANSWERED: v10/maincpu/cc900-staged/*.c reproduces v10's ROM.  For each other tree, which of its functions
have the same code there, and at which addresses?  For each function (its size from a probe summary TSV, the
`bytes` column of probe_v423.py --tsv), the v10 bytes are compared with the tree's bytes at the tree's own address of
the label.  Every address the C names (a `ram_<hex>` cell, a numeric constant of 0x100 or more, or a tree name: a
`.equ` / label) is looked up in v10's bytes as a little-endian 16- or 24-bit field; the tree's bytes at the same
place give the tree's value.  A function is ported when every byte that differs lies in such a field; the tree's
file gets the function with its ram_<hex> cells and numeric constants rewritten.  Others are left out of that tree
and listed.  V4.23 has the last word (staged_v423.py --check).

usage: python3 notes/cc900-phase6-2026-11-16/port_staged.py SIZES.tsv [TREE ...]     (from the repository root)
"""
import os, re, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'model'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cc900_firmware_c as fw                                # noqa: E402
import check_bytes                                           # noqa: E402
import stage_probe as sp                                     # noqa: E402

BASE = 0xe00000


def tree_ctx(t):
    rom = open(os.path.join(REPO, 'original_ROMs', 'kn5000_%s_program.rom' % t), 'rb').read()
    ref = check_bytes.load_reference(os.path.join(REPO, 'symbols', 'maincpu_%s_symbols_reference.txt' % t))
    names = fw.Names(fw.tree_values(os.path.join(REPO, t, 'maincpu')), ref)
    return rom, ref, names


def value(names, n):
    if re.match(r'^ram_[0-9a-f]+$', n):
        return int(n[4:], 16)
    try:
        return names[n] if n in names else None
    except Exception:
        return None


def main():
    a = sys.argv[1:]
    sizes = {}
    for l in open(a[0]):
        c = l.rstrip('\n').split('\t')
        if len(c) > 2 and c[1].isdigit() and c[2] != '-':
            sizes[c[0]] = int(c[1])
    trees = a[1:] or ['v9', 'v7', 'v6', 'v5']
    r10, ref10, n10 = tree_ctx('v10')
    sdir = os.path.join(REPO, 'v10', 'maincpu', 'cc900-staged')
    for t in trees:
        rt, reft, nt = tree_ctx(t)
        for fn in sorted(os.listdir(sdir)):
            if not fn.endswith('.c'):
                continue
            text = open(os.path.join(sdir, fn), encoding='latin-1').read()
            lm = fw.label_map(os.path.join(sdir, fn))
            amap, drop = {}, []
            for kind, item in sp.items(text):
                if kind != 'fn':
                    continue
                cn = sp.fn_name(item); label = lm.get(cn, cn)
                n = sizes.get(label)
                if n is None or label not in ref10:
                    drop.append((cn, 'no size / not in v10')); continue
                if label not in reft:
                    drop.append((cn, 'no such label in %s' % t)); continue
                b10 = r10[ref10[label] - BASE:ref10[label] - BASE + n]
                bt = rt[reft[label] - BASE:reft[label] - BASE + n]
                covered, local = set(), {}
                for name in sp.idents(item) | set(re.findall(r'\b0x[0-9a-fA-F]{3,6}\b(?![0-9a-fA-FlLuU])', item)):
                    v = int(name, 16) if name.startswith('0x') else value(n10, name)
                    if v is None or v < 0x100 or v >= 0x1000000:   # not an address (an event code, a mask)
                        continue
                    for w in ((2, 3) if v < 0x10000 else (3,)):
                        enc = v.to_bytes(w, 'little')
                        for i in range(n - w + 1):
                            if b10[i:i + w] == enc:
                                nv = int.from_bytes(bt[i:i + w], 'little')
                                if w == 2 and v >= 0x10000:
                                    continue
                                local.setdefault(name, set()).add(nv)
                                covered |= set(range(i, i + w))
                bad = [i for i in range(n) if b10[i] != bt[i] and i not in covered]
                amb = [k for k, s in local.items() if len(s) > 1]
                if bad or amb:
                    drop.append((cn, 'bytes differ at +%d' % bad[0] if bad else 'ambiguous %s' % amb[0])); continue
                for k, s in local.items():
                    nv = s.pop()
                    if k.startswith('ram_') or k.startswith('0x'):
                        if amap.get(k, nv) != nv:
                            drop.append((cn, 'conflict on %s' % k)); break
                        amap[k] = nv
                    elif value(nt, k) != nv:              # a tree name with another value there: not this code
                        drop.append((cn, '%s is 0x%x in %s, the bytes say 0x%x' % (k, value(nt, k) or 0, t, nv))); break
            out = text
            for cn, why in drop:                          # take the function (and its cc900-name comment) out
                for kind, item in sp.items(text):
                    if kind == 'fn' and sp.fn_name(item) == cn:
                        out = out.replace(item + '\n', '')
                    if kind == 'name' and re.search(r'cc900-name:\s*%s\s*=' % re.escape(cn), item):
                        out = out.replace(item + '\n', '')
            # declarations that only dropped functions used go too (their ram_<hex> names would collide with remapped
            # ones): keep a declaration when a kept function, or a kept declaration, uses a name it introduces
            its = sp.items(out)
            used = set()
            for kind, item in its:
                if kind == 'fn':
                    used |= sp.idents(item)
            keep, grew = set(), True
            while grew:
                grew = False
                for n_, (kind, item) in enumerate(its):
                    if kind in ('decl', 'pp') and n_ not in keep and (sp.defines(item) & used or not sp.defines(item)):
                        keep.add(n_); used |= sp.idents(item); grew = True
            for n_, (kind, item) in enumerate(its):
                if kind in ('decl', 'pp') and n_ not in keep:
                    out = out.replace(item + '\n', '', 1)
            def sub(m):
                k = m.group(0)
                if k not in amap:
                    return k
                return 'ram_%x' % amap[k] if k.startswith('ram_') else '0x%x' % amap[k]
            out = re.sub(r'\bram_[0-9a-f]+\b|\b0x[0-9a-fA-F]{3,6}\b', sub, out)
            dst = os.path.join(REPO, t, 'maincpu', 'cc900-staged', fn)
            if not any(k == 'fn' for k, _ in sp.items(out)):
                print('%s %-30s no function left: not written%s' % (t, fn, ' (an older copy exists: remove it)' if os.path.exists(dst) else ''))
                continue
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            open(dst, 'w', encoding='latin-1').write(out)
            moved = ', '.join('%s->%x' % (k, v) for k, v in sorted(amap.items()) if int(k[4:] if k.startswith('ram_') else k, 16) != v)
            print('%s %-30s dropped %s%s' % (t, fn, ', '.join('%s (%s)' % d for d in drop) or '-',
                                              ' | moved: ' + moved if moved else ''))


if __name__ == '__main__':
    main()
