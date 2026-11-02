#!/usr/bin/env python3
r"""ported_c_rebase.py -- give a ported main-program tree (v6, v5) its own C, and shrink the raw bytes of
its C-divergence json to what the C really does differently.

QUESTION ANSWERED
-----------------
v6/maincpu and v5/maincpu compile v7's C data sources and patch the result with
TREE/maincpu/includes/TREE_c_divergence.json (scripts/build/apply_c_divergence.py).  The patch has two
kinds of entry: `reloc` (a 4-byte aligned pointer moved by a delta) and `raw` (any other byte), and
scripts/analysis/kn5000_source_coverage.py counts every raw byte as verbatim debt.  How many of those raw
bytes are real content differences, and how many are only pointers the C spells against v7's addresses?

Most are the second kind.  Each NAKA blob `naka_X.c` spells its self-pointers as
`SELF(member) = BASE + offsetof(...)` with `#define BASE 0x00EB71BEu`, v7's (= v10's) address of the blob.
In v6 most blobs sit elsewhere (naka_style_bitmaps 252 bytes lower), so every SELF pointer is off by
the same delta.  The json records the 4-byte aligned ones as relocations, but a pointer at an odd or
2-mod-4 offset (inside a packed record) cannot be a relocation and becomes raw bytes: 2,716 of
naka_style_bitmaps' 2,720 raw bytes in v6 are such pointers.

THREE STEPS (repository root, tree built with `make`)

  --need DIR     for every bin of the json whose C source is known (RULES below): compile the C as it
                 is now, apply the json entry (the same patch as apply_c_divergence.py) and write the
                 result, the bytes TREE's ROM needs there, to DIR/<bin>.  Self-check: each result must
                 equal TREE/maincpu/includes/generated/<bin> as the build left it, so the compile here
                 is make's.  Run this BEFORE editing the C.
  --set-base [--need-dir DIR]
                 rewrite `#define BASE 0x...u` in each of TREE's NAKA C files to the address its blob
                 has in TREE.  The address is read from symbols/maincpu_TREE_symbols_reference.txt
                 (kept in sync by `make gate`): every labelled slice `L: .incbin
                 "includes/generated/X.bin", off, n` implies base = addr(L) - off.  The base of the
                 slice at the LOWEST offset is used (the bytes before the blob's first internal
                 insertion or deletion); files whose slices disagree are reported, and with
                 --need-dir each of their bases (and the old one) is tried and the one that leaves the
                 fewest raw bytes is kept.
  --regen DIR    compile the C as it is now and rewrite each json entry against DIR/<bin> with the rule
                 port_maincpu_version.py --cdiv uses (aligned in-ROM pointer pair -> reloc, else raw).
                 An entry that no longer differs is removed.

The tool never reads the ROM: the needed bytes are the committed C + committed json of before the edit.
`make gate` then certifies the image.

RUN
    python3 scripts/converters/ported_c_rebase.py --tree v6 --need $TMPDIR/need-v6
    python3 scripts/converters/ported_c_rebase.py --tree v6 --set-base --need-dir $TMPDIR/need-v6
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6
"""
import argparse
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LLVM = os.path.join(os.environ.get('PROJECTS_ROOT', os.path.expanduser('~/compartilhado')), 'llvm-project',
                    'build', 'bin')
CLANG, LLD, OBJCOPY = (os.path.join(LLVM, x) for x in ('clang', 'ld.lld', 'llvm-objcopy'))
ROMLO, ROMHI = 0xE00000, 0xE00000 + 0x200000


def rule(tree, name):
    """-> (C source, -I dir or None, link script or None), as PORTED_MAINCPU in the Makefile builds it."""
    m = os.path.join(ROOT, tree, 'maincpu')
    stem = name[:-4]
    if stem == 'naka_control_menu_header':
        return (os.path.join(m, 'ui_widgets', 'control_menu_header.c'), os.path.join(m, 'ui_widgets'),
                os.path.join(m, 'ui_widgets', 'naka_ctrl_menu_link.ld'))
    if stem.startswith('naka_'):
        return (os.path.join(m, 'ui_widgets', stem + '.c'), os.path.join(m, 'ui_widgets'),
                os.path.join(m, 'ui_widgets', stem + '_link.ld'))
    if stem.startswith('se_'):
        return (os.path.join(m, 'audio', 'sound_editor_screens', stem + '.c'), os.path.join(m, 'style_ui'),
                os.path.join(m, 'audio', 'sound_editor_screens', 'se_screens_link.ld'))
    if stem.startswith('accomp_'):
        return (os.path.join(m, 'sequencer', 'accomp_screens', stem + '.c'), os.path.join(m, 'style_ui'),
                os.path.join(m, 'sequencer', 'accomp_screens', 'accomp_screens_link.ld'))
    plain = {'tonegen_param_table': 'audio', 'gui_display_struct_data': 'includes',
             'tonekit_param_blocks': 'ui_widgets'}
    if stem in plain:
        return os.path.join(m, plain[stem], stem + '.c'), None, None
    return None


def compile_bin(tree, name):
    r = rule(tree, name)
    if r is None or not os.path.exists(r[0]):
        return None
    src, inc, ld = r
    tmp = tempfile.mkdtemp(prefix='ported-c-rebase-')
    try:
        o, out = os.path.join(tmp, 'x.o'), os.path.join(tmp, 'x.bin')
        cmd = [CLANG, '-target', 'tlcs900', '-ffreestanding', '-c', '-O2'] + (['-I', inc] if inc else [])
        subprocess.run(cmd + ['-o', o, src], check=True)
        obj = o
        if ld:
            obj = os.path.join(tmp, 'x.elf')
            subprocess.run([LLD, '-T', ld, '-o', obj, o], check=True)
        subprocess.run([OBJCOPY, '-O', 'binary', '-j', '.text', obj, out], check=True)
        return open(out, 'rb').read()
    finally:
        shutil.rmtree(tmp)


def patched(cur, ent):
    """apply_c_divergence.patched, verbatim."""
    data = bytearray(cur)
    size = ent['size']
    if len(data) < size:
        data.extend(b'\x00' * (size - len(data)))
    del data[size:]
    for off, delta in ent.get('reloc', []):
        v = int.from_bytes(data[off:off + 4], 'little')
        data[off:off + 4] = ((v + delta) & 0xFFFFFFFF).to_bytes(4, 'little')
    for off, val in ent.get('raw', {}).items():
        data[int(off)] = val
    return bytes(data)


def entry(raw, need):
    """port_maincpu_version.c_divergence's split, for one bin."""
    size = len(need)
    src = bytearray(raw[:size]) + b'\x00' * max(0, size - len(raw))
    reloc, rawd = [], {}
    o = 0
    while o < size:
        if src[o] == need[o]:
            o += 1
            continue
        a4 = o - o % 4
        if a4 + 4 <= size:
            v0 = int.from_bytes(src[a4:a4 + 4], 'little')
            v1 = int.from_bytes(need[a4:a4 + 4], 'little')
            if ROMLO <= v0 < ROMHI and ROMLO <= v1 < ROMHI:
                reloc.append([a4, v1 - v0])
                o = a4 + 4
                continue
        rawd[str(o)] = need[o]
        o += 1
    if reloc or rawd or size != len(raw):
        return {'size': size, 'reloc': reloc, 'raw': rawd}
    return None


def json_path(tree):
    return os.path.join(ROOT, tree, 'maincpu', 'includes', '%s_c_divergence.json' % tree)


def write_json(tree, d):
    with open(json_path(tree), 'w') as fh:
        fh.write('{\n' + ',\n'.join('  %s: %s' % (json.dumps(k), json.dumps(v, separators=(',', ':')))
                                    for k, v in sorted(d.items())) + '\n}\n')


def do_need(tree, out):
    d = json.load(open(json_path(tree)))
    os.makedirs(out, exist_ok=True)
    bad = 0
    for name, ent in sorted(d.items()):
        raw = compile_bin(tree, name)
        if raw is None:
            print('  %-36s no C rule: kept as it is' % name)
            continue
        need = patched(raw, ent)
        built = os.path.join(ROOT, tree, 'maincpu', 'includes', 'generated', name)
        ok = os.path.exists(built) and open(built, 'rb').read() == need
        bad += not ok
        open(os.path.join(out, name), 'wb').write(need)
        print('  %-36s %7d B  %s' % (name, len(need), 'equals the build' if ok else 'DIFFERS FROM THE BUILD'))
    if bad:
        sys.exit('%d bins differ from the build: build the tree first (make), then rerun' % bad)


def tree_syms(tree):
    syms = {}
    for ln in open(os.path.join(ROOT, 'symbols', 'maincpu_%s_symbols_reference.txt' % tree)):
        p = ln.split()
        if len(p) == 2 and not ln.startswith('#'):
            syms[p[0]] = int(p[1], 16)
    return syms


SLICE = re.compile(rb'^([A-Za-z_][\w.]*):\s*\.incbin\s+"includes/generated/([\w.]+\.bin)"'
                   rb'(?:\s*,\s*(0x[0-9a-fA-F]+|\d+))?')
BASE_RE = re.compile(rb'^#define BASE(\s+)0x([0-9A-Fa-f]{8})u', re.M)


def slice_bases(tree):
    """bin -> sorted [(offset, implied base)] over its labelled slices."""
    syms = tree_syms(tree)
    out = {}
    for f in glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'), recursive=True):
        for ln in open(f, 'rb'):
            m = SLICE.match(ln)
            if m and m.group(1).decode() in syms:
                off = int(m.group(3) or b'0', 0)
                out.setdefault(m.group(2).decode(), []).append((off, syms[m.group(1).decode()] - off))
    return {k: sorted(set(v)) for k, v in out.items()}


def raw_count(tree, name, need_dir):
    p = os.path.join(need_dir, name)
    e = entry(compile_bin(tree, name), open(p, 'rb').read())
    return len(e['raw']) if e else 0


SELF_RE = re.compile(rb'(?:/\* PORT_BASE: [^\n]*\*/\n(?:#define PORT_BASE\(off\)[^\n]*\n)?)?'
                     rb'#define SELF\(field\) \\\n\s+\(\(uint32_t\)\((?:BASE|PORT_BASE\(__builtin_offsetof\(\w+, field\)\))'
                     rb' \+ __builtin_offsetof\((\w+), field\)\)\)')


def render(t, cfg, tree):
    """t with BASE = cfg[0] base and, when cfg has several (offset, base) pieces, a PORT_BASE(off)
    chain that SELF() uses: the base of the piece the member's offset falls in."""
    m = BASE_RE.search(t)
    t = t[:m.start()] + b'#define BASE%s0x%08Xu' % (m.group(1), cfg[0][1]) + t[m.end():]
    s = SELF_RE.search(t)
    ty = s.group(1)
    if len(cfg) == 1:
        body = b'#define SELF(field) \\\n    ((uint32_t)(BASE + __builtin_offsetof(%s, field)))' % ty
    else:
        chain = b''.join(b'(off) >= 0x%Xu ? 0x%08Xu : ' % (o, b) for o, b in reversed(cfg[1:])) + b'BASE'
        body = (b'/* PORT_BASE: %s moved parts of this blob; from each offset on, its ROM address is that base + '
                b'offset (scripts/converters/ported_c_rebase.py) */\n'
                b'#define PORT_BASE(off) (%s)\n'
                b'#define SELF(field) \\\n    ((uint32_t)(PORT_BASE(__builtin_offsetof(%s, field)) + '
                b'__builtin_offsetof(%s, field)))') % (tree.encode(), chain, ty, ty)
    t = t[:s.start()] + body + t[s.end():]
    if len(cfg) > 1 and b'#undef PORT_BASE' not in t:
        t = t.replace(b'#undef SELF\n', b'#undef SELF\n#undef PORT_BASE\n', 1)
    if len(cfg) == 1:
        t = t.replace(b'#undef SELF\n#undef PORT_BASE\n', b'#undef SELF\n', 1)
    return t


def do_set_base(tree, need_dir=None):
    sb = slice_bases(tree)
    for c in sorted(glob.glob(os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', '*.c'))):
        t = open(c, 'rb').read()
        m = BASE_RE.search(t)
        if not m or not SELF_RE.search(t):
            continue
        name = 'naka_control_menu_header.bin' if c.endswith('control_menu_header.c') else \
            os.path.basename(c)[:-2] + '.bin'
        if name not in sb:
            print('  %-36s no labelled slice: BASE kept' % name)
            continue
        old = int(m.group(2), 16)
        # runs of consecutive slices (by offset) at one base
        runs = []
        for off, b in sb[name]:
            if not runs or runs[-1][1] != b:
                runs.append((off, b))
        cfg = [(0, runs[0][1])] + runs[1:]
        note = ''
        if need_dir and len(runs) > 1 and os.path.exists(os.path.join(need_dir, name)):
            def score(cf):
                open(c, 'wb').write(render(t, cf, tree))
                return raw_count(tree, name, need_dir)
            best, bs = cfg, score(cfg)
            for b in sorted({b for _, b in runs} | {old}):      # one base for the whole blob
                k = score([(0, b)])
                if k < bs:
                    best, bs = [(0, b)], k
            changed = len(best) > 1
            while changed:                                      # drop pieces that do not help
                changed = False
                for i in range(1, len(best)):
                    cand = best[:i] + best[i + 1:]
                    k = score(cand)
                    if k <= bs:
                        best, bs, changed = cand, k, True
                        break
            cfg = best
            note = '  raw %d with %d piece(s)' % (bs, len(cfg))
        elif len(runs) > 1:
            cfg = [(0, runs[0][1])]
            note = '  (slices imply %d bases; pass --need-dir to try pieces)' % len({b for _, b in runs})
        t2 = render(t, cfg, tree)
        open(c, 'wb').write(t2)
        print('  %-36s BASE %06x -> %s%s' % (name, old, ' '.join('%x:%06x' % x for x in cfg), note))


def do_regen(tree, need_dir):
    d = json.load(open(json_path(tree)))
    before = sum(len(e.get('raw', {})) for e in d.values())
    for name in sorted(d):
        p = os.path.join(need_dir, name)
        if not os.path.exists(p):
            continue
        raw = compile_bin(tree, name)
        need = open(p, 'rb').read()
        e = entry(raw, need)
        old = len(d[name].get('raw', {}))
        if e is None:
            del d[name]
        else:
            d[name] = e
        print('  %-36s raw %5d -> %5d' % (name, old, len(e['raw']) if e else 0))
    write_json(tree, d)
    after = sum(len(e.get('raw', {})) for e in d.values())
    print('%s: raw bytes %d -> %d, %d bins' % (os.path.relpath(json_path(tree), ROOT), before, after, len(d)))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[1])
    ap.add_argument('--tree', required=True, choices=['v6', 'v5'])
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument('--need', metavar='DIR')
    g.add_argument('--set-base', action='store_true')
    g.add_argument('--regen', metavar='DIR')
    ap.add_argument('--need-dir', metavar='DIR', help='with --set-base: where slices imply several bases, '
                    'try each against the --need output and keep the one with the fewest raw bytes')
    a = ap.parse_args()
    if a.need:
        do_need(a.tree, a.need)
    elif a.set_base:
        do_set_base(a.tree, a.need_dir)
    else:
        do_regen(a.tree, a.regen)


if __name__ == '__main__':
    main()
