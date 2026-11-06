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
                 Only the bytes some .incbin of TREE's assembly places are compared: the others never
                 reach the ROM (the assembly spells them itself, e.g. as `.long Str_X` rows), so the
                 C may compile them to anything.  An entry that no longer differs is removed.

  --name-pointers DIR
                 (after --regen) in each uint32_t[N] array whose element still compiles to another
                 value than DIR/<bin> holds there, spell the element NAKA_ADDR(<label>) when the needed
                 value is the address of a labelled slice of the same bin in TREE (the targets of a
                 pointer table the port re-ordered, which no piecewise BASE expresses); the label gets
                 an extern and its TREE address in the link script.  Then --regen again.

  --ram-self DIR (after --name-pointers) in the blob that lies in the work-RAM image
                 (naka_sequencer_channels), a run of `uint16_t field_X` halfword pairs whose needed
                 32-bit values are the RAM addresses of the blob's own elements becomes one
                 `uint32_t <member>_RamPtrs[N]` spelled NAKA_WRAM(<member>[k]) (BASE-relative, so each
                 tree compiles its own value).  Then --regen again.

  --ram-self-pieces DIR
                 (after --ram-self) NAKA_WRAM takes the blob's piecewise base (WRAM_BASE(off), from the
                 slices as PORT_BASE is) and every NAKA_WRAM element is re-spelled by the member its value
                 is the RAM copy of; the bytes must not change (lane open11/v6v5-port2: v6's
                 Naka_DrawbarReg_Table[16] read entry 17).
  --own-values DIR
                 (after port_ram_names.py; lane open11/v6v5-port2) the C's own values where the json still
                 patches raw bytes: RAM names the source tree's C spells (then gen_naka_gui_headers.py),
                 link-script-only names (SE_*, Accomp_*) given the tree's address, numeric literals and
                 `#define`s (SENTINEL, a screen blob's _BASE; not a NAKA BASE) found by group testing.
                 Every edit must leave every placed byte that was right right and fix one.  Then --regen.
  --hand-c DIR   the HAND_C list: initializers that read bytes as a pointer which are not one (each
                 with its evidence).  Then --regen.

The tool never reads the ROM: the needed bytes are the committed C + committed json of before the edit.
`make gate` then certifies the image.

RUN
    python3 scripts/converters/ported_c_rebase.py --tree v6 --need $TMPDIR/need-v6
    python3 scripts/converters/ported_c_rebase.py --tree v6 --set-base --need-dir $TMPDIR/need-v6
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6
"""
import argparse
import bisect
import collections
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
        cmd = [CLANG, '-target', 'tlcs900', '-ffreestanding', '-c', '-O2', '-w'] + (['-I', inc] if inc else [])
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


ANY_SLICE = re.compile(rb'^[^;]*?\.incbin\s+"includes/generated/([\w.]+\.bin)"'
                       rb'(?:\s*,\s*(0x[0-9a-fA-F]+|\d+)(?:\s*,\s*(0x[0-9a-fA-F]+|\d+))?)?')


def placed(tree):
    """bin -> [(start, end)] of the bin's bytes that TREE's assembly places in the image (every
    .incbin of it, labelled or not).  Bytes of a bin that no .incbin places never reach the ROM."""
    out = {}
    for f in glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'), recursive=True):
        for ln in open(f, 'rb'):
            m = ANY_SLICE.match(ln)
            if m:
                off = int(m.group(2) or b'0', 0)
                end = off + int(m.group(3), 0) if m.group(3) else None
                out.setdefault(m.group(1).decode(), []).append((off, end))
    return out


def do_regen(tree, need_dir):
    d = json.load(open(json_path(tree)))
    cover = placed(tree)
    before = sum(len(e.get('raw', {})) for e in d.values())
    for name in sorted(d):
        p = os.path.join(need_dir, name)
        if not os.path.exists(p):
            continue
        raw = compile_bin(tree, name)
        need = bytearray(open(p, 'rb').read())
        # bytes no .incbin places are not the ROM's: the C may compile them to anything
        mask = bytearray(len(need))
        for a, b in cover.get(name, []):
            for i in range(a, min(len(need), b if b is not None else len(need))):
                mask[i] = 1
        for i in range(len(need)):
            if not mask[i]:
                need[i] = raw[i] if i < len(raw) else 0
        e = entry(raw, bytes(need))
        old = len(d[name].get('raw', {}))
        if e is None:
            del d[name]
        else:
            d[name] = e
        print('  %-36s raw %5d -> %5d' % (name, old, len(e['raw']) if e else 0))
    write_json(tree, d)
    after = sum(len(e.get('raw', {})) for e in d.values())
    print('%s: raw bytes %d -> %d, %d bins' % (os.path.relpath(json_path(tree), ROOT), before, after, len(d)))


def dwarf_members(tree, name):
    """[(offset, member, type)] of the blob's top-level struct, from DWARF (compiled with -g and
    linked, so the names resolve)."""
    src, inc, ld = rule(tree, name)
    tmp = tempfile.mkdtemp(prefix='ported-c-rebase-g-')
    try:
        o = os.path.join(tmp, 'x.o')
        subprocess.run([CLANG, '-target', 'tlcs900', '-ffreestanding', '-c', '-O2', '-g', '-w']
                       + (['-I', inc] if inc else []) + ['-o', o, src], check=True)
        elf = os.path.join(tmp, 'x.elf')
        subprocess.run([LLD, '-T', ld, '-o', elf, o], check=True)
        dw = subprocess.run([os.path.join(LLVM, 'llvm-dwarfdump'), '--debug-info', elf], capture_output=True,
                            text=True).stdout
    finally:
        shutil.rmtree(tmp)
    structs, cur = [], None
    for blk in re.split(r'\n(?=0x[0-9a-f]+:\s+DW_TAG_)', dw):
        head = blk.split('\n')[0]
        if 'DW_TAG_structure_type' in head:
            m = re.search(r'DW_AT_byte_size\s+\((0x[0-9a-f]+)\)', blk)
            cur = [int(m.group(1), 16) if m else 0, []]
            structs.append(cur)
        elif 'DW_TAG_member' in head and cur is not None:
            nm = re.search(r'DW_AT_name\s+\("([^"]+)"\)', blk)
            loc = re.search(r'DW_AT_data_member_location\s+\((0x[0-9a-f]+)\)', blk)
            ty = re.search(r'DW_AT_type\s+\(0x[0-9a-f]+ "([^"]*)"\)', blk)
            if nm and loc:
                cur[1].append((int(loc.group(1), 16), nm.group(1), ty.group(1) if ty else ''))
    return sorted(max(structs)[1])


def split_elems(body):
    """top-level comma-separated elements of an initializer list body, with their spans."""
    out, depth, start = [], 0, 0
    for i, ch in enumerate(body):
        if ch in '({[':
            depth += 1
        elif ch in ')}]':
            depth -= 1
        elif ch == ',' and depth == 0:
            out.append((start, i))
            start = i + 1
    if body[start:].strip():
        out.append((start, len(body)))
    return out


def do_name_pointers(tree, need_dir):
    """In every top-level uint32_t[N] array of TREE's NAKA C whose element compiles to another value
    than the tree needs (a placed byte), and whose needed value is the address of a labelled slice of
    the same bin in TREE, spell the element NAKA_ADDR(<that label>): extern + link-script value from
    symbols/maincpu_TREE_symbols_reference.txt.  For pointer tables whose targets the TREE's port
    re-ordered (a piecewise BASE cannot express that)."""
    syms = tree_syms(tree)
    by_addr = {}
    cover = placed(tree)
    lab_of_slice = {}
    for f in glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'), recursive=True):
        for ln in open(f, 'rb'):
            m = SLICE.match(ln)
            if m and m.group(1).decode() in syms:
                lab_of_slice.setdefault(m.group(2).decode(), {})[syms[m.group(1).decode()]] = m.group(1).decode()
    d = json.load(open(json_path(tree)))
    total = 0
    for name, ent in sorted(d.items()):
        if not ent.get('raw') or not name.startswith('naka_') or name not in lab_of_slice:
            continue
        rawpos = {int(o) for o in ent['raw']}
        src, inc, ld = rule(tree, name)
        need = open(os.path.join(need_dir, name), 'rb').read()
        mem = dwarf_members(tree, name)
        text = open(src, 'rb').read().decode('latin-1')
        new_ext, new_ld, edits = set(), {}, []
        for k, (off, mname, ty) in enumerate(mem):
            mt = re.fullmatch(r'uint32_t\[(\d+)\]', ty)
            if not mt:
                continue
            n = int(mt.group(1))
            hit = [i for i in range(n) if any(off + 4 * i + j in rawpos for j in range(4))]
            if not hit:
                continue
            m = re.search(r'\n    \.%s = \{' % re.escape(mname), text)
            if not m:
                continue
            b0 = m.end()
            depth, i = 1, b0
            while depth:
                depth += {'{': 1, '}': -1}.get(text[i], 0)
                i += 1
            body = text[b0:i - 1]
            spans = split_elems(body)
            if len(spans) != n:
                continue
            for e in hit:
                v = int.from_bytes(need[off + 4 * e:off + 4 * e + 4], 'little')
                lab = lab_of_slice[name].get(v)
                if not lab:
                    continue
                a, z = spans[e]
                el = body[a:z]
                lead = el[:len(el) - len(el.lstrip())]
                trail = el[len(el.rstrip()):]
                edits.append((b0 + a, b0 + z, lead + 'NAKA_ADDR(%s)' % lab + trail))
                new_ext.add(lab)
                new_ld[lab] = v
        if not edits:
            continue
        for a, z, rep in sorted(edits, reverse=True):
            text = text[:a] + rep + text[z:]
        have = set(re.findall(r'^extern const char (\w+);', text, re.M))
        add = sorted(new_ext - have)
        if add:
            last = list(re.finditer(r'^extern const char \w+;\n', text, re.M))[-1]
            text = text[:last.end()] + ''.join('extern const char %s;\n' % x for x in add) + text[last.end():]
        open(src, 'wb').write(text.encode('latin-1'))
        ldt = open(ld).read()
        have = set(re.findall(r'^(\w+) = ', ldt, re.M))
        ldt = ldt.rstrip('\n') + '\n' + ''.join('%s = 0x%08X;\n' % (x, new_ld[x]) for x in sorted(new_ld)
                                                if x not in have)
        open(ld, 'w').write(ldt)
        total += len(edits)
        print('  %-36s %d elements spelled by label (%d labels)' % (name, len(edits), len(new_ld)))
    print('%s: %d pointer elements named' % (tree, total))


WRAM_DEST = 0x3D524          # Boot_InitWorkRAM's first copy: RAM 0x3D524.. from ROM WorkRamInit_Image


def do_ram_self(tree, need_dir):
    """In the blob that lies in the work-RAM image (naka_sequencer_channels: Boot_InitWorkRAM copies
    ROM WorkRamInit_Image.. to RAM 0x3D524..), a run of `uint16_t field_X` pairs whose needed 32-bit
    values are RAM addresses of the same blob's own bytes is a pointer array: it becomes one
    `uint32_t <member before>_RamPtrs[N]` spelled NAKA_WRAM(<member>[k]) -- the RAM copy of that member
    element, BASE-relative, so each tree compiles its own value.  (The runs were typed as halfwords
    because the old C model split every word it could not explain.)"""
    syms = tree_syms(tree)
    img = syms.get('WorkRamInit_Image')
    d = json.load(open(json_path(tree)))
    name = 'naka_sequencer_channels.bin'
    if img is None or name not in d or not d[name].get('raw'):
        print('%s: nothing to do' % tree)
        return
    src, inc, ld = rule(tree, name)
    text = open(src, 'rb').read().decode('latin-1')
    base = int(re.search(r'^#define BASE\s+0x([0-9A-Fa-f]+)u', text, re.M).group(1), 16)
    stype = re.search(r'__builtin_offsetof\((\w+), field\)', text).group(1)
    need = open(os.path.join(need_dir, name), 'rb').read()
    mem = dwarf_members(tree, name)
    ram0 = WRAM_DEST + base - img                  # RAM address of the blob's offset 0
    size = len(need)
    rawpos = {int(o) for o in d[name]['raw']}

    def where(v):
        """RAM address -> 'member[k]' / 'member' of this blob, or None"""
        o = v - ram0
        if not 0 <= o < size:
            return None
        for i, (off, nm, ty) in enumerate(mem):
            end = mem[i + 1][0] if i + 1 < len(mem) else size
            if off <= o < end:
                mt = re.fullmatch(r'uint32_t\[(\d+)\]', ty)
                if o == off and not mt:
                    return nm
                if mt and (o - off) % 4 == 0:
                    return '%s[%d]' % (nm, (o - off) // 4)
                return None
        return None
    runs, i = [], 0
    while i < len(mem) - 1:
        j = i
        while j + 1 < len(mem) and re.fullmatch(r'field_[0-9a-f]+', mem[j][1]) and mem[j][2] == 'uint16_t' \
                and mem[j + 1][2] == 'uint16_t' and mem[j + 1][0] == mem[j][0] + 2 and mem[j][0] % 4 == mem[i][0] % 4:
            v = int.from_bytes(need[mem[j][0]:mem[j][0] + 4], 'little')
            if where(v) is None:
                break
            j += 2
        if j - i >= 8 and any(mem[i][0] <= r < mem[j][0] for r in rawpos):
            runs.append((i, j))
            i = j
        else:
            i += 1
    if not runs:
        print('%s: no RAM pointer runs' % tree)
        return
    for i, j in reversed(runs):
        start, n = mem[i][0], (j - i) // 2
        prev = mem[i - 1][1] if i else 'Blob'
        arr = '%s_RamPtrs' % prev
        vals = [where(int.from_bytes(need[start + 4 * k:start + 4 * k + 4], 'little')) for k in range(n)]
        names = [mem[k][1] for k in range(i, j)]
        # declarations
        decl = re.compile(r'(?:    uint16_t (?:%s);\n)+' % '|'.join(names))
        m = decl.search(text)
        assert m and m.group(0).count('\n') == len(names), arr
        text = text[:m.start()] + ('    /* %s: %d x u32, the work-RAM (RAM 0x%X..) addresses of this blob\'s own\n'
                                   '     * elements (NAKA_WRAM); read as halfword pairs field_%04x..field_%04x before */\n'
                                   '    uint32_t %s[%d];\n' % (arr, n, ram0 + start, start, mem[j - 1][0], arr, n)) + text[m.end():]
        # initializers: the .field_X = ..., lines (with the blank lines between them)
        ini = re.compile(r'(?:    \.(?:%s) = [^\n]*,\n\n?)+' % '|'.join(names))
        m = ini.search(text)
        assert m, arr
        body = '    .%s = {\n%s    },\n\n' % (arr, ''.join('        NAKA_WRAM(%s),\n' % v for v in vals))
        text = text[:m.start()] + body + text[m.end():]
        print('  %-36s %s[%d] at +0x%x: %s' % (name, arr, n, start, ', '.join(sorted(set(vals)))))
    if '#define NAKA_WRAM(' not in text:
        m = re.search(r'#define SELF\(field\) \\\n[^\n]*\n', text)
        text = text[:m.end()] + ('\n/* the RAM address of a member\'s work-RAM copy: Boot_InitWorkRAM copies ROM WorkRamInit_Image\n'
                                 ' * (0x%06X in %s) .. to RAM 0x%X .., and this blob starts BASE - WorkRamInit_Image into it */\n'
                                 '#define NAKA_WRAM(field) \\\n'
                                 '    ((uint32_t)(0x%Xu + (BASE - 0x%08Xu) + __builtin_offsetof(%s, field)))\n'
                                 % (img, tree, WRAM_DEST, WRAM_DEST, img, stype)) + text[m.end():]
    open(src, 'wb').write(text.encode('latin-1'))


def do_ram_self_pieces(tree, need_dir):
    """(after --ram-self) NAKA_WRAM(field) took the blob's one BASE, but the port moved part of the blob
    (in v6 / v5 everything from the slice at 0xC48 on sits 4 bytes lower: slice_bases), so an element
    spelled NAKA_WRAM(Naka_DrawbarReg_Table[16]) compiled to the RAM copy of entry 17 -- the right
    bytes under the wrong name (MainChordPre_AppendChordSuffix reads entries 17, 30, 43, 56: the
    bass-note spelling blocks, notes/v6v5-port2-2026-11-06/).  This gives NAKA_WRAM the slices'
    piecewise base (WRAM_BASE(off), as PORT_BASE does for SELF) and re-spells each NAKA_WRAM element by
    the member its needed value is the RAM copy of.  The compiled bytes must not change."""
    name = 'naka_sequencer_channels.bin'
    src, inc, ld = rule(tree, name)
    text = open(src, 'rb').read().decode('latin-1')
    m = re.search(r'#define NAKA_WRAM\(field\) \\\n    \(\(uint32_t\)\((0x[0-9A-Fa-f]+)u \+ \((BASE|WRAM_BASE\(__builtin_offsetof\((\w+), field\)\)) - (0x[0-9A-Fa-f]+)u\) '
                  r'\+ __builtin_offsetof\((\w+), field\)\)\)', text)
    if not m:
        print('%s: no NAKA_WRAM in %s' % (tree, os.path.relpath(src, ROOT)))
        return
    dest, img, stype = int(m.group(1), 16), int(m.group(4), 16), m.group(5)
    base = int(re.search(r'^#define BASE\s+0x([0-9A-Fa-f]+)u', text, re.M).group(1), 16)
    runs = []
    for off, b in slice_bases(tree).get(name, []):
        if not runs or runs[-1][1] != b:
            runs.append((off, b))
    if len(runs) < 2 and runs and runs[0][1] == base:
        print('%s: one base, nothing to do' % tree)
        return
    def wbase(o):
        b = base
        for off, bb in runs[1:]:
            if o >= off:
                b = bb
        return b
    chain = ''.join('(off) >= 0x%Xu ? 0x%08Xu : ' % (o, b) for o, b in reversed(runs[1:])) + 'BASE'
    macro = ('/* WRAM_BASE: %s moved parts of this blob; from each slice offset on, its ROM address is that base +\n'
             ' * offset (slice_bases, scripts/converters/ported_c_rebase.py --ram-self-pieces) */\n'
             '#define WRAM_BASE(off) (%s)\n'
             '#define NAKA_WRAM(field) \\\n'
             '    ((uint32_t)(0x%Xu + (WRAM_BASE(__builtin_offsetof(%s, field)) - 0x%08Xu) + __builtin_offsetof(%s, field)))'
             % (tree, chain, dest, stype, img, stype))
    pre = re.search(r'/\* WRAM_BASE: [^\n]*\n[^\n]*\*/\n#define WRAM_BASE\(off\) [^\n]*\n$', text[:m.start()])
    a0 = pre.start() if pre else m.start()
    text = text[:a0] + macro + text[m.end():]
    mem = dwarf_members(tree, name)
    p = os.path.join(need_dir, name)
    if not os.path.exists(p):                   # no json entry: the build's bin is what the tree needs
        p = os.path.join(ROOT, tree, 'maincpu', 'includes', 'generated', name)
    need = open(p, 'rb').read()

    def where(v):
        for i, (off, nm, ty) in enumerate(mem):
            end = mem[i + 1][0] if i + 1 < len(mem) else len(need)
            for o in range(off, end, 4):
                if dest + wbase(off) - img + o == v:
                    mt = re.fullmatch(r'uint32_t\[(\d+)\]', ty)
                    if o == off and not mt:
                        return nm
                    if mt:
                        return '%s[%d]' % (nm, (o - off) // 4)
        return None
    count = 0
    for off, nm, ty in mem:
        if not nm.endswith('_RamPtrs'):
            continue
        n = int(re.fullmatch(r'uint32_t\[(\d+)\]', ty).group(1))
        sp = re.search(r'\n    \.%s = \{\n((?:        NAKA_WRAM\([^\n]*\),\n)+)    \}' % re.escape(nm), text)
        vals = [where(int.from_bytes(need[off + 4 * k:off + 4 * k + 4], 'little')) for k in range(n)]
        assert sp and None not in vals, nm
        body = ''.join('        NAKA_WRAM(%s),\n' % v for v in vals)
        count += sum(1 for a, b in zip(sp.group(1).split('\n'), body.split('\n')) if a != b)
        text = text[:sp.start(1)] + body + text[sp.end(1):]
        text = re.sub(r'(/\* %s: \d+ x u32, the work-RAM \(RAM )0x[0-9A-F]+(\.\.\))' % re.escape(nm),
                      lambda q: '%s0x%X%s' % (q.group(1), dest + wbase(off) - img + off, q.group(2)), text)
        print('  %-36s %s: %s' % (name, nm, ', '.join(sorted(set(vals)))))
    before = compile_bin(tree, name)
    old = open(src, 'rb').read()
    open(src, 'wb').write(text.encode('latin-1'))
    after = try_compile(tree, name)
    if after != before:
        open(src, 'wb').write(old)
        sys.exit('%s: the re-spelled NAKA_WRAM compiles to other bytes; restored' % tree)
    print('%s: NAKA_WRAM piecewise (%d pieces), %d elements re-spelled, bytes unchanged' % (tree, len(runs), count))


# ---------------------------------------------------------------- --own-values (lane open11/v6v5-port2)
SRC_TREE = {'v6': 'v7', 'v5': 'v6'}          # the tree each was ported from
NUM_TOK = re.compile(r'(?<![\w.$])(0[xX][0-9A-Fa-f]+|\d+)([uUlL]*)(?![\w.])')
LD_SYM = re.compile(r'^(\s*)([A-Za-z_]\w*)(\s*=\s*)0x([0-9A-Fa-f]+)(\s*;)', re.M)


def mask_comments(t):
    """t with every comment and string / character literal blanked (same length)."""
    out = list(t)
    for m in re.finditer(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\\n])*"|\'(?:\\.|[^\'\\\n])*\'', t, re.S):
        for i in range(m.start(), m.end()):
            if out[i] != '\n':
                out[i] = ' '
    return ''.join(out)


def ram_values(tree):
    """{name: value} of the tree's main-RAM .equ names that naka_ram_cells.h can carry
    (gen_naka_gui_headers.ram_vars_used reads the same two files)."""
    out = {}
    for f in ('ram_variables_by_use.s', 'ram_variables.s'):
        p = os.path.join(ROOT, tree, 'maincpu', 'shared', f)
        if os.path.exists(p):
            for m in re.finditer(r'^\s*\.equ\s+(\w+),\s*0x([0-9A-Fa-f]+)', open(p, 'rb').read().decode('latin-1'), re.M):
                out.setdefault(m.group(1), int(m.group(2), 16))
    return out


def bins_of_rule():
    """the bins whose C a rule() knows, by C source / link script (every tree has the same files)."""
    gen = os.path.join(ROOT, 'v7', 'maincpu', 'includes', 'generated')
    return sorted(f for f in os.listdir(gen) if f.endswith('.bin'))


class Need:
    """the bytes TREE's ROM needs of each bin (need_dir, else the build's own bin: a bin without a
    json entry compiles to them already) and which of them an .incbin places."""

    def __init__(self, tree, need_dir):
        self.tree, self.dir, self.cover, self._n = tree, need_dir, placed(tree), {}

    def need(self, name):
        if name not in self._n:
            p = os.path.join(self.dir, name)
            if not os.path.exists(p):
                p = os.path.join(ROOT, self.tree, 'maincpu', 'includes', 'generated', name)
            self._n[name] = open(p, 'rb').read() if os.path.exists(p) else None
        return self._n[name]

    def bad(self, name, raw=None):
        """placed offsets where the C (as it is now, or `raw`) compiles to other bytes than needed"""
        need = self.need(name)
        if need is None:
            return set()
        raw = compile_bin(self.tree, name) if raw is None else raw
        if raw is None:
            return set()
        out = set()
        for a, b in self.cover.get(name, []):
            for i in range(a, min(len(need), b if b is not None else len(need))):
                if i >= len(raw) or raw[i] != need[i]:
                    out.add(i)
        return out


def member_spans(text, masked):
    """{member: (start, end)} of each top-level designated initializer `    .member = <init>,` (or tab) --
    the span of <init> (a balanced {...} or a scalar up to the comma)."""
    out = {}
    for m in re.finditer(r'\n(?:    |\t)\.(\w+) = ', masked):
        i = m.end()
        if masked[i] == '{':
            depth, j = 0, i
            while True:
                depth += {'{': 1, '}': -1}.get(masked[j], 0)
                j += 1
                if depth == 0:
                    break
        else:
            j = i
            while masked[j] not in ',\n':
                j += 1
        out.setdefault(m.group(1), (i, j))
    return out


DUMP_LINE = re.compile(r'^(\s*((?:0x[0-9A-Fa-f]{2},\s*)*0x[0-9A-Fa-f]{2},?)\s*)/\* (.*) \*/$')


def ascii_comments(old, new):
    """the byte-dump lines of `new` that differ from `old` (`0x41, 0x42, ...  /* AB.. */`) with their
    ASCII comment redrawn from the new bytes"""
    ol, nl = old.split('\n'), new.split('\n')
    if len(ol) != len(nl):
        return new
    for i, (a, b) in enumerate(zip(ol, nl)):
        m = DUMP_LINE.match(b)
        if a == b or not m:
            continue
        bs = [int(x, 16) for x in re.findall(r'0x([0-9A-Fa-f]{2})', m.group(2))]
        if len(bs) != len(m.group(3)):
            continue
        txt = ''.join(chr(c) if 0x20 <= c < 0x7F else '.' for c in bs).replace('*/', '*.')
        nl[i] = m.group(1) + '/* ' + txt + ' */'
    return '\n'.join(nl)


def try_compile(tree, name):
    """compile_bin, or None when the edited C does not compile"""
    try:
        return compile_bin(tree, name)
    except subprocess.CalledProcessError:
        return None


def fmt_like(tok, suffix, v):
    if tok[:2] in ('0x', '0X'):
        digits = tok[2:]
        up = any(c in 'ABCDEF' for c in digits) or not any(c in 'abcdef' for c in digits)
        h = '%0*X' % (len(digits), v) if up else '%0*x' % (len(digits), v)
        return tok[:2] + h + suffix
    return '%d%s' % (v, suffix)


def do_own_values(tree, need_dir):
    """Give TREE's C its own values where its C-divergence json still patches raw bytes, by the edits
    that leave every bin no worse (no placed byte that was right goes wrong) and fix at least one byte:
      1. RAM names: an element of a top-level uint32_t[N] array whose needed value is a main-RAM
         variable of TREE (shared/ram_variables_by_use.s, ram_variables.s) that the source tree's C
         (v7 for v6, v6 for v5) spells by that name in the same element takes the name;
         gen_naka_gui_headers.py then gives naka_ram_cells.h TREE's value of it.
      2. link-script names: an address in a link script that names no label (SE_NoteDivision_Names,
         Accomp_PartOnOff_Names, ...: the link-script-only names of the screen-data C) takes the
         TREE value its uses need -- the 4 needed bytes where the C compiles the old value;
      3. numbers: a numeric literal of a member's initializer whose compiled bytes (1, 2 or 4 of them,
         where the literal's value stands) hold a raw byte takes the needed value in the same notation.
    Each edit is compiled and kept only if it passes; the json is then rewritten with --regen."""
    N = Need(tree, need_dir)
    src_tree = SRC_TREE[tree]
    d = json.load(open(json_path(tree)))
    todo = sorted(n for n, e in d.items() if e.get('raw') and rule(tree, n) and os.path.exists(rule(tree, n)[0]))
    before = {n: N.bad(n) for n in todo}
    print('%s: %d raw bytes in %d bins to look at' % (tree, sum(len(v) for v in before.values()), len(todo)))
    stats = collections.Counter()

    # 1. RAM names
    rv = ram_values(tree)
    for name in todo:
        if not name.startswith('naka_'):
            continue
        src = rule(tree, name)[0]
        ssrc = rule(src_tree, name)[0]
        if not os.path.exists(ssrc):
            continue
        text = open(src, 'rb').read().decode('latin-1')
        stext = open(ssrc, 'rb').read().decode('latin-1')
        mem = dwarf_members(tree, name)
        need = N.need(name)
        spans, sspans = member_spans(text, mask_comments(text)), member_spans(stext, mask_comments(stext))
        edits = []
        for off, mname, ty in mem:
            mt = re.fullmatch(r'uint32_t\[(\d+)\]', ty)
            if not mt or mname not in spans or mname not in sspans:
                continue
            n = int(mt.group(1))
            if not any(off <= r < off + 4 * n for r in before[name]):
                continue
            a0, z0 = spans[mname]
            body, sbody = text[a0 + 1:z0 - 1], stext[sspans[mname][0] + 1:sspans[mname][1] - 1]
            el, sel = split_elems(body), split_elems(sbody)
            if len(el) != n or len(sel) != n:
                continue
            for k in range(n):
                word = sbody[sel[k][0]:sel[k][1]].strip()
                v = int.from_bytes(need[off + 4 * k:off + 4 * k + 4], 'little')
                if word in rv and rv[word] == v and body[el[k][0]:el[k][1]].strip() != word:
                    e = body[el[k][0]:el[k][1]]
                    lead, trail = e[:len(e) - len(e.lstrip())], e[len(e.rstrip()):]
                    edits.append((a0 + 1 + el[k][0], a0 + 1 + el[k][1], lead + word + trail))
        if edits:
            for a, z, rep in sorted(edits, reverse=True):
                text = text[:a] + rep + text[z:]
            open(src, 'wb').write(text.encode('latin-1'))
            stats['RAM names'] += len(edits)
            print('  %-36s %d elements spelled by RAM name' % (name, len(edits)))
    if stats['RAM names']:
        subprocess.run([sys.executable, os.path.join(ROOT, 'scripts', 'generators', 'gen_naka_gui_headers.py')],
                       cwd=ROOT, check=True, capture_output=True)
        for name in todo:
            b = N.bad(name)
            if not b <= before[name]:
                sys.exit('%s: RAM names made %d bytes worse; git checkout %s/maincpu' % (name, len(b - before[name]), tree))
            before[name] = b

    # 2. link-script names (shared scripts: every bin that uses the script must stay no worse)
    users = collections.defaultdict(list)
    for name in bins_of_rule():
        r = rule(tree, name)
        if r and r[2] and os.path.exists(r[0]):
            users[r[2]].append(name)
    labels = set(tree_syms(tree))
    for ld, names in sorted(users.items()):
        if not any(before.get(n) for n in names):
            continue
        cur = {n: compile_bin(tree, n) for n in names}
        for n in names:
            before.setdefault(n, N.bad(n, cur[n]))
        ldt = open(ld).read()
        for m in list(LD_SYM.finditer(ldt)):
            sym, v = m.group(2), int(m.group(4), 16)
            if sym in labels:
                continue
            vb = v.to_bytes(4, 'little')
            cands = collections.Counter()
            for n in names:
                need = N.need(n)
                for o in before[n]:
                    for a in range(o - 3, o + 1):
                        if a >= 0 and cur[n][a:a + 4] == vb and need is not None:
                            cands[int.from_bytes(need[a:a + 4], 'little')] += 1
            for nv, _ in cands.most_common():
                note = '' if '/* v7: ' in ldt[m.end():ldt.find('\n', m.end())] else '  /* v7: 0x%08X */' % v
                eol = ldt.find('\n', m.end())
                trial = (ldt[:m.start()] + '%s%s%s0x%08X%s' % (m.group(1), sym, m.group(3), nv, m.group(5))
                         + ldt[m.end():eol] + note + ldt[eol:])
                open(ld, 'w').write(trial)
                new = {n: try_compile(tree, n) for n in names}
                nb = {n: (N.bad(n, new[n]) if new[n] is not None else {-1}) for n in names}
                if all(nb[n] <= before[n] for n in names) and sum(map(len, nb.values())) < sum(len(before[n]) for n in names):
                    print('  %-36s %s 0x%06X -> 0x%06X' % (os.path.basename(ld), sym, v, nv))
                    ldt, cur, before = trial, new, dict(before, **nb)
                    stats['link-script names'] += 1
                    break
                open(ld, 'w').write(ldt)

    # 3. numbers: which literal makes which bytes is found by group testing -- every literal of the
    #    candidate initializers gets a number k; for each bit b of k the literals with that bit set are
    #    perturbed together (value ^ 0x01010101) and the bytes that change are recorded, so a byte's
    #    changes spell the k of the one literal that makes it (log2 N compiles instead of N)
    raw_of = {n: {int(o) for o in d[n]['raw']} for n in todo}
    for name in todo:
        for attempt in (0, 1):     # the members DWARF puts the raw bytes in, then the whole file
            targets = before[name] & raw_of[name]
            if not targets or (attempt and not rule(tree, name)[2]):
                break
            src = rule(tree, name)[0]
            need = N.need(name)
            text = open(src, 'rb').read().decode('latin-1')
            masked = mask_comments(text)
            cur = compile_bin(tree, name)
            if rule(tree, name)[2] and not attempt:
                mem = dwarf_members(tree, name)
                offs = [x[0] for x in mem]
                spans = member_spans(text, masked)
                hit = {mem[k][1] for k in (bisect.bisect_right(offs, o) - 1 for o in targets) if k >= 0}
                regions = sorted(spans[m] for m in hit if m in spans)
            else:                         # the whole initializer of the data object (not the type, whose
                dm = re.search(r'section\("\.text"\)[^=;]*=\s*\{', text)     # array sizes must stay)
                regions = [(dm.end() if dm else 0, len(text))]
            toks = []
            for a0, z0 in regions:
                for t in NUM_TOK.finditer(masked, a0, z0):
                    line0 = masked.rfind('\n', 0, t.start()) + 1
                    if masked[:t.start()].rstrip()[-1:] == '[' or masked[line0:t.start()].lstrip().startswith(('#', '_Static_assert')) \
                            or int(t.group(1), 0) >= 1 << 32:
                        continue
                    toks.append(t)
            if not toks:
                continue
            nbits = len(toks).bit_length()
            code = collections.Counter()
            ok = True
            for bit in range(nbits):
                pert = [t for i, t in enumerate(toks) if (i + 1) >> bit & 1]
                tt = text
                for t in sorted(pert, key=lambda t: -t.start()):
                    tt = tt[:t.start()] + '0x%X' % (int(t.group(1), 0) ^ 0x01010101) + t.group(2) + tt[t.end():]
                open(src, 'wb').write(tt.encode('latin-1'))
                new = try_compile(tree, name)
                open(src, 'wb').write(text.encode('latin-1'))
                if new is None or len(new) != len(cur):
                    ok = False
                    break
                for o in range(len(cur)):
                    if new[o] != cur[o]:
                        code[o] |= 1 << bit
            if not ok:
                print('  %-36s literal map: a perturbed compile failed, skipped' % name)
                continue
            owner = collections.defaultdict(list)
            for o, c in code.items():
                owner[c].append(o)
            edits = {}
            for r in sorted(targets):
                c = code.get(r)
                if not c or c - 1 >= len(toks):
                    continue
                span = sorted(owner[c])
                if span != list(range(span[0], span[-1] + 1)) or len(span) > 4:
                    continue
                t = toks[c - 1]
                w, o = len(span), span[0]
                if int.from_bytes(cur[o:o + w], 'little') != int(t.group(1), 0):
                    continue                          # the bytes are not the literal itself (a macro computes them)
                edits[t.start()] = (t, fmt_like(t.group(1), t.group(2), int.from_bytes(need[o:o + w], 'little')))

            def apply(es):
                tt = text
                for t, rep in sorted(es, key=lambda e: -e[0].start()):
                    tt = tt[:t.start()] + rep + tt[t.end():]
                return tt
            es = list(edits.values())
            done = []
            if es:
                tt = apply(es)
                open(src, 'wb').write(tt.encode('latin-1'))
                new = try_compile(tree, name)
                nb = N.bad(name, new) if new is not None else None
                if nb is not None and nb < before[name]:
                    done = es
                else:                                 # one at a time, keeping the ones that pass
                    open(src, 'wb').write(text.encode('latin-1'))
                    for e in es:
                        tt = apply(done + [e])
                        open(src, 'wb').write(tt.encode('latin-1'))
                        new = try_compile(tree, name)
                        nb2 = N.bad(name, new) if new is not None else None
                        if nb2 is not None and nb2 < before[name]:
                            done.append(e)
                            nb = nb2
                        open(src, 'wb').write((apply(done) if done else text).encode('latin-1'))
                if done:
                    open(src, 'wb').write(ascii_comments(text, apply(done)).encode('latin-1'))
                    before[name] = N.bad(name)
                else:
                    open(src, 'wb').write(text.encode('latin-1'))
            stats['numbers'] += len(done)
            # a `#define NAME number` the initializers use (tonegen_param_table's SENTINEL): every use moves
            # together, so it is tried on its own, kept when it leaves the bin no worse and fixes a byte
            text = open(src, 'rb').read().decode('latin-1')
            cur = compile_bin(tree, name)
            for dm in re.finditer(r'^#define\s+\w+\s+(0[xX][0-9A-Fa-f]+|\d+)([uUlL]*)\s*(?:/\*.*\*/)?\s*$', text, re.M):
                if re.match(r'#define\s+BASE\s', dm.group(0)):
                    continue                          # a NAKA blob's BASE is --set-base's (its slices' address)
                v = int(dm.group(1), 0)
                tried = set()
                # a blob base (`#define X_BASE 0x00F6A97Au`, SD_PTR(member) = base + offset): the 4 bytes at a
                # raw byte hold base + k, and the tree needs base' + k
                if ROMLO <= v < ROMHI:
                    for r in sorted(before[name] & raw_of[name]):
                        for o in range(r - 3, r + 1):
                            c, n = (int.from_bytes(x[o:o + 4], 'little') for x in (cur, need))
                            if o < 0 or not (ROMLO <= c < ROMHI and ROMLO <= n < ROMHI) or not 0 <= c - v < 0x10000:
                                continue
                            nv = v + n - c
                            if nv in tried:
                                continue
                            tried.add(nv)
                            tt = text[:dm.start(1)] + fmt_like(dm.group(1), dm.group(2), nv) + text[dm.end(1) + len(dm.group(2)):]
                            open(src, 'wb').write(tt.encode('latin-1'))
                            new = try_compile(tree, name)
                            nb = N.bad(name, new) if new is not None else None
                            if nb is not None and nb < before[name]:
                                text, cur, before[name], v = tt, new, nb, nv
                                stats['defines'] += 1
                                print('  %-36s %s' % (name, dm.group(0).split('/*')[0].strip() + ' -> ' + fmt_like(dm.group(1), dm.group(2), nv)))
                                break
                            open(src, 'wb').write(text.encode('latin-1'))
                        else:
                            continue
                        break
                    continue
                for r in sorted(before[name] & raw_of[name]):
                    for w in (4, 2, 1):
                        for o in range(r - w + 1, r + 1):
                            if o < 0 or v >= 1 << (8 * w) or int.from_bytes(cur[o:o + w], 'little') != v:
                                continue
                            nv = int.from_bytes(need[o:o + w], 'little')
                            if nv in tried or not 0 <= nv < 1 << (8 * w):
                                continue
                            tried.add(nv)
                            tt = text[:dm.start(1)] + fmt_like(dm.group(1), dm.group(2), nv) + text[dm.end(1) + len(dm.group(2)):]
                            open(src, 'wb').write(tt.encode('latin-1'))
                            new = try_compile(tree, name)
                            nb = N.bad(name, new) if new is not None else None
                            if nb is not None and nb < before[name]:
                                text, cur, before[name] = tt, new, nb
                                stats['defines'] += 1
                                print('  %-36s %s' % (name, dm.group(0).split('/*')[0].strip() + ' -> ' + fmt_like(dm.group(1), dm.group(2), nv)))
                                break
                            open(src, 'wb').write(text.encode('latin-1'))
                        else:
                            continue
                        break
            print('  %-36s %d literals -> %d edits (%d of %d raw bytes left)' % (
                name, len(toks), len(done), len(before[name] & raw_of[name]), len(raw_of[name])))
    after = sum(len(before[n] & raw_of[n]) for n in todo)
    print('%s: edits %s; raw bytes the C still compiles wrong: %d (run --regen next)' % (tree, dict(stats), after))


# ---------------------------------------------------------------- --hand-c (lane open11/v6v5-port2)
# C initializers that read bytes as a pointer which are not one; each with its evidence.  An edit is kept
# only when it leaves the bin no worse and fixes a byte (Need.bad), like --own-values.
HAND_C = [
    (('v6', 'v5'), 'naka_technichord_strings.bin',
     '    .Naka_PresentationRootState_ptr = NAKA_ADDR(Naka_PresentationRootState),\n',
     '    /* not a pointer: x2 = 319, y2 = 239, the right / bottom of FDemoText_ScreenClipRect (see its note).\n'
     '     * v10 / v9 compile NAKA_ADDR(Naka_PresentationRootState) to the same bytes by coincidence (0xEF013F);\n'
     '     * v7, v6 and v5 keep 3F 01 EF 00 while that label moves (0xEF0115, 0xEF0015, 0xEEFFFD) */\n'
     '    .Naka_PresentationRootState_ptr = 319u | 239u << 16,\n'),
    (('v6', 'v5'), 'naka_technichord_part.bin',
     '    .NakaData_DescriptorPad1_ptr = NAKA_ADDR(NakaData_DescriptorPad1),\n',
     '    /* not a pointer: the two halfwords 8, 230 (08 00 E6 00), the same in v10, v7, v6 and v5 while the\n'
     '     * label NakaData_DescriptorPad1 it was read as moves (0xE60008 in v10 / v7, 0xE6000E in v6,\n'
     '     * 0xE5FFF6 in v5) */\n'
     '    .NakaData_DescriptorPad1_ptr = 8u | 230u << 16,\n'),
]


def do_hand_c(tree, need_dir):
    N = Need(tree, need_dir)
    for trees, name, old, new in HAND_C:
        if tree not in trees:
            continue
        src = rule(tree, name)[0]
        text = open(src, 'rb').read().decode('latin-1')
        if old not in text:
            print('  %-36s %s: not there (done already?)' % (name, old.strip()[:50]))
            continue
        before = N.bad(name)
        open(src, 'wb').write(text.replace(old, new, 1).encode('latin-1'))
        new_raw = try_compile(tree, name)
        nb = N.bad(name, new_raw) if new_raw is not None else None
        if nb is None or not nb < before:
            open(src, 'wb').write(text.encode('latin-1'))
            print('  %-36s %s: does not help, not applied' % (name, old.strip()[:50]))
            continue
        print('  %-36s %s: applied (%d -> %d placed bytes wrong)' % (name, old.strip()[:50], len(before), len(nb)))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[1])
    ap.add_argument('--tree', required=True, choices=['v6', 'v5'])
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument('--need', metavar='DIR')
    g.add_argument('--set-base', action='store_true')
    g.add_argument('--regen', metavar='DIR')
    g.add_argument('--name-pointers', metavar='DIR')
    g.add_argument('--ram-self', metavar='DIR')
    g.add_argument('--own-values', metavar='DIR')
    g.add_argument('--ram-self-pieces', metavar='DIR')
    g.add_argument('--hand-c', metavar='DIR')
    ap.add_argument('--need-dir', metavar='DIR', help='with --set-base: where slices imply several bases, '
                    'try each against the --need output and keep the one with the fewest raw bytes')
    a = ap.parse_args()
    if a.need:
        do_need(a.tree, a.need)
    elif a.set_base:
        do_set_base(a.tree, a.need_dir)
    elif a.name_pointers:
        do_name_pointers(a.tree, a.name_pointers)
    elif a.ram_self:
        do_ram_self(a.tree, a.ram_self)
    elif a.hand_c:
        do_hand_c(a.tree, a.hand_c)
    elif a.ram_self_pieces:
        do_ram_self_pieces(a.tree, a.ram_self_pieces)
    elif a.own_values:
        do_own_values(a.tree, a.own_values)
    else:
        do_regen(a.tree, a.regen)


if __name__ == '__main__':
    main()
