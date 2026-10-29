#!/usr/bin/env python3
r"""naka_gui_symbolize.py -- spell the NAKA widget records of the C sources by name, byte-identically.

QUESTION ANSWERED
-----------------
"Can a reader see what each GUI record is -- its class, its place in the screen's object tree, its
geometry, colours, fonts, titles, functions -- without decoding numbers?"  This rewrites every
widget record of <tree>/maincpu/ui_widgets/*.c (the `naka_cls_<Class>_t` members the nakarest lane
typed, scripts/analysis/naka_gui_model.py) so that:

  * `.class_ = 0x01600034` becomes `.class_ = NAKA_CLASS(TtlScreen)` (naka_classes.h);
  * `.super/.sub/.next/.prev = <index>` name the element: each Viewable table the file holds gets
    `#define <Table>_SLOT 0x...u` and `enum <Table>_objects { OBJ_<member>, ... }`, one constant
    per element in index order, INDENTED BY DEPTH in the object tree (index order is the tree's
    preorder in every table whose elements the file holds), so the hierarchy is visible in the
    enum and the links in the records are names (`.super = OBJ_normal`).  Elements whose record
    is not in this file keep a slot in the enum, named after where they are;
  * `.rect = { x1, y1, x2, y2 }` becomes `.rect = NAKA_XYWH(x, y, w, h)` (the firmware's own
    reading: RectX2Proc/RectY2Proc edit x2/y2 as width/height, naka_classes.h);
  * enumerated properties use the firmware's value names (SupportClass_PropTypeRecords): colours
    CL_*, borders BD_*, view flags VF_* (or'ed), alignment AL_*, edit switches ES_*, edit-switch
    styles SS_*, line modes LM_*, frames FR_*, parts PT_*, tracks TR_*, times IT_*, users idu*;
    fonts / bitmaps / icons their dump names (idCHARA1, idTrashIcon, idICON_i12);
  * title ids (letter a) TITLE_*, mode ids (`) NAKA_MODE_*, function objects (j, k)
    NAKA_APFUNC_* / NAKA_FUNC_* / NAKA_MAINFUNC_*, from event_codes.s (naka_ids.h);
  * the per-file copies of the class typedefs are dropped: naka_classes.h defines every class
    (the script checks the fields agree before it drops one).

A value with no name stays a number (scripts/analysis/naka_gui_census.py counts them).  Nothing
changes a value, so nothing changes a byte; --apply recompiles each changed file and refuses to
write it unless the compiled blob is identical to the tree's current includes/generated/ bin
(v10, v9: the bin is the C's own output; v7/v6/v5 compile v10's C then patch it, so for those
the file is compared against the transformed v10 file instead -- see RUN).

RUN (repository root, built tree)
    python3 scripts/generators/gen_naka_gui_headers.py
    python3 scripts/converters/naka_gui_symbolize.py --tree v10 [--apply] [file.c ...]
    python3 scripts/converters/naka_gui_symbolize.py --tree v9 --apply
    # v7/v6/v5: their GUI C files are byte-for-byte v10's; copy v10's result where the old
    # file equalled v10's old file (--sync-from v10), then make gate.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'generators'))
import naka_gui_model as G               # noqa: E402
import nakarest_objtab_map as O          # noqa: E402
import gen_naka_gui_headers as H         # noqa: E402

LLVM = os.path.expanduser('~/compartilhado/llvm-project/build/bin')
NONE = 0xFFFF
NUM = re.compile(r'^-?(0x[0-9A-Fa-f]+|\d+)$')
LINKS = ('super', 'sub', 'next', 'prev')


# ------------------------------------------------------------------ names
class Names:
    def __init__(self, m):
        self.m = m
        self.cls = G.class_ids('v10')
        self.cls_by_id = {v: n for n, v in self.cls.items()}
        self.prop = {}            # letter -> {value: name}
        for ch, (proc, vals, src) in H.prop_types(m).items():
            d = {}
            for n, v in vals:
                if re.match(r'^[A-Za-z_]\w*$', n):
                    d.setdefault(v, n)
            self.prop[ch] = d
        self.ids = {}             # prefix -> {value: name}
        txt = G.read(os.path.join(ROOT, 'v10', 'maincpu', 'ui_widgets', 'naka_ids.h'))
        for n, v in re.findall(r'^#define (\w+)\s+(0x[0-9A-F]+)u', txt, re.M):
            for pre in ('TITLE_', 'NAKA_MODE_', 'NAKA_APFUNC_', 'NAKA_FUNC_', 'NAKA_MAINFUNC_', 'NAKA_VIEW_'):
                if n.startswith(pre):
                    self.ids.setdefault(pre, {}).setdefault(int(v, 16), n)

    def idname(self, prefixes, v):
        for p in prefixes:
            n = self.ids.get(p, {}).get(v)
            if n:
                return n
        return None


def view_flags(v):
    names = [(1, 'VF_Invisible'), (2, 'VF_Fixed'), (4, 'VF_Change'), (8, 'VF_Const'), (0x10, 'VF_InvisibleBox')]
    if v == 0:
        return 'VF_None'
    parts, rest = [], v
    for bit, n in names:
        if v & bit:
            parts.append(n)
            rest &= ~bit
    if rest:
        parts.append('0x%04X' % rest)
    return ' | '.join(parts)


def rect_text(v):
    m = re.match(r'^\{\s*(-?\d+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+)\s*\}$', v.strip())
    if not m:
        return None
    x1, y1, x2, y2 = (int(g) for g in m.groups())
    w, h = x2 - x1 + 1, y2 - y1 + 1
    if w <= 0 or h <= 0:
        return 'NAKA_XYXY(%d, %d, %d, %d)' % (x1, y1, x2, y2)
    return 'NAKA_XYWH(%d, %d, %d, %d)' % (x1, y1, w, h)


def field_value(nm, letter, fname, v):
    """the named spelling of field value text v, or None to leave it."""
    if not NUM.match(v.strip()):
        return None
    x = int(v, 0)
    if letter == 'M':
        n = nm.cls_by_id.get(x)
        return 'NAKA_CLASS(%s)' % n if n else None
    if letter == ']':
        return view_flags(x)
    if letter in nm.prop:
        return nm.prop[letter].get(x if letter != 'l' else x & 0xFFFFFFFF)
    if letter == 'a':
        return nm.idname(('TITLE_',), x)
    if letter == '`':
        return nm.idname(('NAKA_MODE_',), x)
    if letter == 'j':
        return nm.idname(('NAKA_APFUNC_', 'NAKA_FUNC_', 'NAKA_MAINFUNC_'), x)
    if letter == 'k':
        return nm.idname(('NAKA_MAINFUNC_', 'NAKA_FUNC_', 'NAKA_APFUNC_'), x)
    return None


# ------------------------------------------------------------- tables / enums
class Tables:
    """Every Viewable table of the v10 ROM: slot -> dict(label, count, init, elems=[addr],
    links=[(super, sub, next, prev)])."""

    def __init__(self, m):
        self.m = m
        self.t = {}
        for r in m.regs:
            if r['cls'] != 0x1600010 or not m.inrom(r['table']):
                continue
            el = [a if m.inrom(a) else (G.rom_image_of(a) or a) for a in m.entries(r)]
            lab = m.name_of(r['table'])
            self.t[r['slot']] = dict(label=lab[1] if lab[0] == r['table'] else 'ViewTable_%03X' % r['slot'],
                                     count=r['count'], init=r['init'], elems=el, reg=r,
                                     links=[tuple(m.u16(a + o) for o in (4, 6, 8, 10)) if m.inrom(a)
                                            else (NONE,) * 4 for a in el])

    def depth(self, slot, k):
        d, seen = 0, set()
        links = self.t[slot]['links']
        while 0 <= k < len(links) and links[k][0] != NONE and k not in seen:
            seen.add(k)
            k = links[k][0]
            d += 1
        return d


def c_ident(s):
    s = re.sub(r'[^A-Za-z0-9_]', '_', s)
    return s if re.match(r'^[A-Za-z_]', s) else '_' + s


def build_global(files):
    """(slot, elem) -> (file name, member, class) over all files of the tree."""
    g = {}
    for f in files:
        for r in f.records:
            g[(r['slot'], r['elem'])] = (f.name, r['member'], r['cls'])
    return g


def enum_names(f, tabs, glob_index):
    """per slot of f: [OBJ name per element] (unique within f)."""
    out, used = {}, set()
    for slot in sorted({r['slot'] for r in f.records}):
        t = tabs.t.get(slot)
        n = t['count'] if t else 1 + max(r['elem'] for r in f.records if r['slot'] == slot)
        names = []
        for k in range(n):
            g = glob_index.get((slot, k))
            if g:
                base = 'OBJ_' + g[1]
            elif t and k < len(t['elems']):
                lab = tabs.m.name_of(t['elems'][k])
                base = 'OBJ_' + (lab[1] if lab[0] == t['elems'][k] else 's%03X_e%d' % (slot, k))
            else:
                base = 'OBJ_s%03X_e%d' % (slot, k)
            base = c_ident(base)
            nmx, j = base, 2
            while nmx in used:
                nmx = '%s_%d' % (base, j)
                j += 1
            used.add(nmx)
            names.append(nmx)
        out[slot] = names
    return out


def enum_block(f, slot, names, tabs, glob_index, nm):
    t = tabs.t.get(slot)
    label = t['label'] if t else 'ViewTable_%03X' % slot
    lines = []
    lines.append('/* Viewable table %s, registry slot 0x%X, %s elements.' % (label, slot, t['count'] if t else '?'))
    if t:
        lines.append(' * %s registers it: `RegObjTabl NAKA_CLASS_Viewable, ViewableProc, %d, %s, 0x%X`.'
                     % (t['init'], t['count'], label, slot))
    lines.append(' * One constant per element, in index order, indented by depth in the object tree:')
    lines.append(' * the records below link to each other (super = parent, sub = first child, next /')
    lines.append(' * prev = siblings) by these names.  View id of element OBJ_x: NAKA_VIEW_ID(%s, OBJ_x). */'
                 % label)
    lines.append('#define %s_SLOT 0x%03Xu' % (label, slot))
    lines.append('enum %s_objects {' % label)
    width = max(len(n) for n in names) + 4 + 2 * max([tabs.depth(slot, k) for k in range(len(names))] or [0])
    width = min(width, 56)
    for k, n in enumerate(names):
        d = tabs.depth(slot, k) if t else 0
        g = glob_index.get((slot, k))
        if g and g[0] == f.name:
            r = f.by_member[g[1]]
            what = '%s%s' % (g[2], (' "%s"' % r['resname']) if r['resname'] else '')
        elif g:
            what = '%s, record in %s' % (g[2], g[0])
        elif t and k < len(t['elems']):
            c = tabs.m.record_class(t['elems'][k])
            lab = tabs.m.name_of(t['elems'][k])
            where = lab[1] if lab[0] == t['elems'][k] else '0x%06X' % t['elems'][k]
            ram = not tabs.m.inrom(tabs.m.entries(t['reg'])[k])
            what = '%s, %s (%s)' % (c['name'] if c else '?', 'RAM record initialised from the work-RAM image'
                                    if ram else 'record outside the C sources', where)
        else:
            what = 'not in the registered table'
        item = '    ' + '  ' * d + n + ','
        lines.append('%-*s /* %2d %s */' % (width + 1, item, k, what))
    lines.append('};')
    return '\n'.join(lines) + '\n'


# ------------------------------------------------------------------ typedefs
def drop_local_typedefs(txt, generated):
    """remove `naka_cls_X_t` typedefs (and their "NAKA class X" comment) that naka_classes.h
    defines with the same fields."""
    lines = txt.split('\n')
    out, i, dropped, kept = [], 0, 0, []
    gen_fields = {}
    for m in re.finditer(r'typedef struct __attribute__\(\(packed\)\) \{\n(.*?)\} naka_cls_(\w+)_t;', generated, re.S):
        gen_fields[m.group(2)] = re.findall(r'^\s+(\w+) (\w+(?:\[\d+\])?);', m.group(1), re.M)
    # find the spans first
    spans = []
    for j, ln in enumerate(lines):
        mm = re.match(r'^\} naka_cls_(\w+)_t;$', ln)
        if not mm:
            continue
        k = j
        while k >= 0 and not lines[k].startswith('typedef struct __attribute__((packed)) {'):
            k -= 1
        body = '\n'.join(lines[k + 1:j])
        fields = re.findall(r'^\s+(\w+) (\w+(?:\[\d+\])?);', body, re.M)
        if gen_fields.get(mm.group(1)) != fields:
            kept.append(mm.group(1))
            continue
        # the class comment: either right above, or anywhere -- "/* NAKA class X -- class id"
        spans.append((k, j, mm.group(1)))
    drop = set()
    for k, j, name in spans:
        for x in range(k, j + 1):
            drop.add(x)
        if j + 1 < len(lines) and lines[j + 1] == '':
            drop.add(j + 1)
        dropped += 1
        # its comment block
        for c, ln in enumerate(lines):
            if ln.startswith('/* NAKA class %s -- class id ' % name):
                e = c
                while not lines[e].rstrip().endswith('*/'):
                    e += 1
                for x in range(c, e + 1):
                    drop.add(x)
                break
    out = [ln for x, ln in enumerate(lines) if x not in drop]
    return '\n'.join(out), dropped, kept


# ------------------------------------------------------------------ rewrite
def rewrite(path, nm, tabs, glob_index, letters, generated):
    f = G.CFile(path)
    if not f.records:
        txt, dropped, kept = drop_local_typedefs(f.text, generated)
        return (txt if dropped else None), {'typedefs dropped': dropped}
    txt = f.text
    stats = dict(records=len(f.records))
    names = enum_names(f, tabs, glob_index)
    name_of = {(s, k): n for s, ns in names.items() for k, n in enumerate(ns)}

    def fix_block(m):
        r = f.by_member.get(m.group(1))
        if r is None:
            return m.group(0)
        lt = dict(letters.get(r['cls'], []))

        def fix_field(fm):
            fname, v = fm.group(1), fm.group(2)
            letter = lt.get(fname)
            new = None
            if fname in LINKS and letter == '[':
                if NUM.match(v.strip()):
                    k = int(v, 0)
                    new = 'NAKA_NONE' if k == NONE else name_of.get((r['slot'], k))
            elif fname == 'rect' and letter == 'P':
                new = rect_text(v)
            elif letter in ('t', 'N') and NUM.match(v.strip()):
                x = int(v, 0)
                tgt = name_of.get((x >> 16, x & 0xFFFF)) if x not in (0, 0xFFFFFFFF) else None
                if tgt:
                    t = tabs.t.get(x >> 16)
                    new = 'NAKA_VIEW_ID(%s, %s)' % (t['label'] if t else 'ViewTable_%03X' % (x >> 16), tgt)
            elif letter:
                new = field_value(nm, letter, fname, v)
            if new is None or new == v:
                return fm.group(0)
            stats[letter] = stats.get(letter, 0) + 1
            return '        .%s = %s,' % (fname, new)
        return FIELDSUB.sub(fix_field, m.group(0))

    txt = G.BLOCK.sub(fix_block, txt)
    # the object enums, before the initializer
    if not re.search(r'^enum \w+_objects \{', txt, re.M):
        blocks = [enum_block(f, s, names[s], tabs, glob_index, nm) for s in sorted(names)]
        mm = re.search(r'^const \w+ \w+\n    __attribute__', txt, re.M)
        if not mm:
            raise SystemExit('%s: no initializer found' % path)
        sec = ('/* ── Object tables: the element names the records link by ─────────── */\n\n'
               + '\n'.join(blocks) + '\n')
        txt = txt[:mm.start()] + sec + txt[mm.start():]
    txt, dropped, kept = drop_local_typedefs(txt, generated)
    stats['typedefs dropped'] = dropped
    if kept:
        stats['typedefs kept'] = kept
    return txt, stats


FIELDSUB = re.compile(r'^        \.(\w+) = ([^\n]*),$', re.M)

HEADER_RE = re.compile(r'^    /\* ==== (?:SCREEN|VIEW) .*?\*/\n', re.M | re.S)


def wrap(text, first, rest, width=100):
    words, lines, cur = text.split(), [], first
    for w in words:
        if len(cur) + 1 + len(w) > width and cur.strip() not in ('*', ''):
            lines.append(cur)
            cur = rest + w
        else:
            cur = cur + ('' if cur.endswith(' ') else ' ') + w
    lines.append(cur)
    return lines


def screen_headers(g):
    """file name -> {member: header comment text} for every title's screen record and every
    top-level view with children."""
    paths = g.menu_paths()
    menu, exits, into = G.title_links(g)
    out = {}
    for f in g.files:
        hs = {}
        for r in f.records:
            key = (r['slot'], r['elem'])
            tids = g.view_titles.get(key, [])
            L = []
            if tids:
                for tid in tids:
                    t = g.titles[tid]
                    st = G.title_screen_text(g, tid)
                    L.append('    /* ==== SCREEN %s%s -- "%s", title id 0x%X, function %s ===='
                             % (g.title_name(tid), (' "%s"' % st) if st else '', t['name'], t['index'],
                                g.name_by_value.get(t['func'], '0x%08X' % (t['func'] or 0))))
                    d = G.title_description(g, tid)
                    if d:
                        L += wrap(d, '     * What:', '     *       ')
                    pth = G.title_path(g, tid, paths)
                    L.append('     * Path: %s' % (pth or 'no menu entry opens it (opened by code)'))
                    for lab, to in menu.get(tid, []):
                        L.append('     * Menu: "%s" -> %s' % (lab or '?', g.title_name(to)))
                    for frm, k2, fn, lab in g.func_entries:
                        if frm == tid:
                            L.append('     * Menu: "%s" -> by code, %s' % (lab or '?', fn))
                    if exits.get(tid):
                        L.append('     * EXIT -> %s' % ', '.join(g.title_name(x) for x in sorted(exits[tid])))
                    fr = sorted({(g.title_name(a) if a else 'an untitled view', b) for a, b in into.get(tid, [])})
                    if fr:
                        L += wrap(', '.join('%s ("%s")' % (a, b) if b else a for a, b in fr),
                                  '     * Opened from:', '     *       ')
            else:
                lk = g.links(key)
                if lk[0] != NONE or lk[1] in (None, NONE):
                    continue
                lab = g.label(f, r)
                L.append('    /* ==== VIEW OBJ_%s: %s%s, the top of an object tree that no title shows'
                         % (r['member'], r['cls'], (' "%s"' % lab) if lab else ''))
                L.append('     * directly (a window, page or popup another view or procedure opens) ====')
            L[-1] = L[-1] + ' */'
            hs[r['member']] = '\n'.join(L) + '\n'
        out[f.name] = hs
    return out


def apply_headers(path, hs):
    txt = HEADER_RE.sub('', G.read(path))
    for member, h in hs.items():
        txt = re.sub(r'^(    \.%s = \{\n)' % re.escape(member), lambda m: h + m.group(1), txt, count=1, flags=re.M)
    return txt


# ------------------------------------------------------------------ verify
def bin_rule(tree, cpath):
    """(bin path, link script) of the Makefile rule that compiles cpath."""
    mk = G.read(os.path.join(ROOT, 'Makefile'))
    rel = os.path.relpath(cpath, ROOT).replace(tree + '/', 'v10/', 1)
    m = re.search(r'^(v10/maincpu/includes/generated/\w+\.bin): %s ' % re.escape(rel), mk, re.M)
    if not m:
        return None, None
    b = m.group(1).replace('v10/', tree + '/', 1)
    ld = cpath[:-2] + '_link.ld'
    if not os.path.exists(ld):
        ld = os.path.join(os.path.dirname(cpath), 'naka_ctrl_menu_link.ld')
    return os.path.join(ROOT, b), ld


def compile_c(cpath, ld, text):
    d = tempfile.mkdtemp(prefix='naka_gui_', dir=os.environ.get('TMPDIR'))
    try:
        src = os.path.join(os.path.dirname(cpath), '.naka_gui_tmp_' + os.path.basename(cpath))
        open(src, 'wb').write(text.encode('utf-8', 'surrogateescape'))
        try:
            o, e, b = (os.path.join(d, x) for x in ('x.o', 'x.elf', 'x.bin'))
            r = subprocess.run([os.path.join(LLVM, 'clang'), '-target', 'tlcs900', '-ffreestanding', '-c',
                                '-O2', '-I', os.path.dirname(cpath), '-o', o, src],
                               capture_output=True, text=True)
            if r.returncode:
                raise SystemExit('compile failed for %s:\n%s' % (cpath, r.stderr[-4000:]))
            subprocess.run([os.path.join(LLVM, 'ld.lld'), '-T', ld, '-o', e, o], check=True)
            subprocess.run([os.path.join(LLVM, 'llvm-objcopy'), '-O', 'binary', '-j', '.text', e, b], check=True)
            return open(b, 'rb').read()
        finally:
            os.remove(src)
    finally:
        shutil.rmtree(d)


def sync(trees):
    import glob
    src = os.path.join(ROOT, 'v10', 'maincpu', 'ui_widgets')

    def head(rel):
        r = subprocess.run(['git', 'show', 'HEAD:' + rel], cwd=ROOT, capture_output=True)
        return r.stdout if r.returncode == 0 else None
    for t in trees:
        n = 0
        for p in sorted(glob.glob(os.path.join(src, '*.c')) + glob.glob(os.path.join(src, '*.h'))):
            b = os.path.basename(p)
            dst = os.path.join(ROOT, t, 'maincpu', 'ui_widgets', b)
            if not os.path.exists(dst):
                continue
            base = head('v10/maincpu/ui_widgets/' + b)
            if base is None or head('%s/maincpu/ui_widgets/%s' % (t, b)) != base:
                continue
            new = open(p, 'rb').read()
            if open(dst, 'rb').read() != new:
                open(dst, 'wb').write(new)
                n += 1
        print('%s: %d files copied from v10' % (t, n))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', default='v10')
    ap.add_argument('--apply', action='store_true')
    ap.add_argument('--headers', action='store_true', help='(re)write the SCREEN / VIEW header comments')
    ap.add_argument('--check', action='store_true',
                    help='exit 1 if a rewrite or a header pass would change any file (no compile)')
    ap.add_argument('--sync', metavar='TREES',
                    help='copy each changed v10 GUI file (ui_widgets/*.c, *.h) into these trees where the '
                         'tree\'s committed file equals v10\'s committed file (v7,v6,v5 share v10\'s C)')
    ap.add_argument('files', nargs='*')
    a = ap.parse_args()
    if a.sync:
        sync(a.sync.split(','))
        return
    files = [os.path.abspath(p) for p in a.files] or G.tree_files(a.tree)
    m = O.Map('v10')
    nm = Names(m)
    tabs = Tables(m)
    letters = G.class_letters('v10')
    generated = G.read(os.path.join(ROOT, 'v10', 'maincpu', 'ui_widgets', 'naka_classes.h'))
    allf = [G.CFile(p) for p in G.tree_files(a.tree)]
    glob_index = build_global(allf)
    if a.check:
        heads = screen_headers(G.Graph(a.tree, m))
        stale = []
        for p in files:
            cur = G.read(p)
            new, st = rewrite(p, nm, tabs, glob_index, letters, generated)
            if new is not None and new != cur:
                stale.append('%s (spelling)' % os.path.relpath(p, ROOT))
            elif apply_headers(p, heads.get(os.path.basename(p), {})) != cur:
                stale.append('%s (SCREEN/VIEW headers)' % os.path.relpath(p, ROOT))
        for x in stale:
            print('STALE: ' + x)
        print('naka_gui_symbolize --check %s: %s' % (a.tree, '%d stale' % len(stale) if stale else 'up to date'))
        sys.exit(1 if stale else 0)
    bad = 0
    heads = screen_headers(G.Graph(a.tree, m)) if a.headers else {}
    for p in files:
        if a.headers:
            new, st = apply_headers(p, heads.get(os.path.basename(p), {})), {'headers': len(heads.get(os.path.basename(p), {}))}
        else:
            new, st = rewrite(p, nm, tabs, glob_index, letters, generated)
        if new is None or new == G.read(p):
            continue
        b, ld = bin_rule(a.tree, p)
        if b is None:
            print('%s: no Makefile rule found; skipped' % p)
            bad += 1
            continue
        if a.tree in ('v10', 'v9'):
            got, want = compile_c(p, ld, new), open(b, 'rb').read()
            same = got == want
        else:
            same = compile_c(p, ld, new) == compile_c(p, ld, G.read(p))
        print('%-34s %s %s' % (os.path.basename(p), 'IDENTICAL' if same else 'DIFFERS', st))
        if not same:
            bad += 1
            continue
        if a.apply:
            open(p, 'wb').write(new.encode('utf-8', 'surrogateescape'))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
