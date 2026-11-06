#!/usr/bin/env python3
r"""naka_gui_model.py -- read the NAKA GUI records out of a main-CPU tree's C sources.

QUESTION ANSWERED
-----------------
"Which widget records does <tree>/maincpu/ui_widgets/*.c hold, of which class, in which Viewable
table at which element index, and how are their fields spelled?"  A library for
scripts/converters/naka_gui_symbolize.py (which rewrites the spelling), scripts/generators/
gen_naka_menu_map.py (the menu map) and scripts/analysis/naka_gui_census.py (the readability
census).  It reads the C text only, in either spelling:

  * a record is a struct member `naka_cls_<Class>_t <member>;` whose declaration is preceded by
    the comment `/* element K of Viewable slot 0xS "<resname>": <Class> (...) */` (the
    nakarest lane wrote one per record), and whose initializer is the block
        .<member> = {
            .<field> = <value>,
            ...
        },
  * field letters (the class chain's propdata, which says what a field holds) come from the
    generated naka_classes.h (scripts/generators/gen_naka_gui_headers.py);
  * the object enums the symbolizer writes, `enum <Table>_objects { OBJ_x, ... };` preceded by
    `#define <Table>_SLOT 0x...u`, give each OBJ_ name its element index.

RUN: a library; `python3 scripts/analysis/naka_gui_model.py v10` prints a per-file summary.
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NONE = 0xFFFF

ELEM = re.compile(r'/\* element (\d+) of Viewable slot (0x[0-9A-Fa-f]+)(?: "([^"]*)")?: (\w+) '
                  r'\(class id 0x[0-9A-Fa-f]+\) \*/\n\s+naka_cls_(\w+)_t (\w+);')
BLOCK = re.compile(r'^    \.(\w+) = \{\n((?:        \.\w+ = [^\n]*,\n)+)    \},$', re.M)
FIELD = re.compile(r'^        \.(\w+) = ([^\n]*),$', re.M)
ENUM = re.compile(r'^#define (\w+)_SLOT (0x[0-9A-Fa-f]+)u\n(?:[^\n]*\n)*?enum \1_objects \{\n(.*?)^\};',
                  re.M | re.S)
ENUM_ITEM = re.compile(r'^\s+(OBJ_\w+),', re.M)


def read(p):
    return open(p, 'rb').read().decode('utf-8', 'surrogateescape')


def class_letters(tree='v10'):
    """class name -> [(field, letter)] from the tree's generated naka_classes.h."""
    txt = read(os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', 'naka_classes.h'))
    out = {}
    for m in re.finditer(r'typedef struct __attribute__\(\(packed\)\) \{\n(.*?)\} naka_cls_(\w+)_t;', txt, re.S):
        out[m.group(2)] = re.findall(r'^\s+\w+ (\w+)(?:\[\d+\])?;\s+/\* \+\d+ (\S)', m.group(1), re.M)
    return out


def class_ids(tree='v10'):
    txt = read(os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', 'naka_classes.h'))
    return {n: int(v, 16) for n, v in re.findall(r'^#define NAKA_CLASS_(\w+)\s+(0x[0-9A-F]+)u', txt, re.M)}


class CFile:
    def __init__(self, path):
        self.path = path
        self.name = os.path.basename(path)
        self.text = read(path)
        self.records = []        # dicts: member, cls, slot, elem, resname, fields {name: value text}
        self.by_member = {}
        for m in ELEM.finditer(self.text):
            r = dict(member=m.group(6), cls=m.group(5), slot=int(m.group(2), 16),
                     elem=int(m.group(1)), resname=m.group(3) or '', fields={})
            self.records.append(r)
            self.by_member[r['member']] = r
        for m in BLOCK.finditer(self.text):
            r = self.by_member.get(m.group(1))
            if r is not None:
                r['fields'] = dict(FIELD.findall(m.group(0)))
        self.enums = {}          # table label -> (slot, [OBJ names in index order])
        self.obj_index = {}      # OBJ name -> (slot, index)
        for m in ENUM.finditer(self.text):
            names = ENUM_ITEM.findall(m.group(3))
            self.enums[m.group(1)] = (int(m.group(2), 16), names)
            for i, n in enumerate(names):
                self.obj_index[n] = (int(m.group(2), 16), i)

    def link_value(self, v):
        """element index of a link spelled as a number, NAKA_NONE or OBJ_x (None if unknown)."""
        v = v.strip()
        if v == 'NAKA_NONE':
            return NONE
        if re.match(r'^(0x[0-9A-Fa-f]+|\d+)$', v):
            return int(v, 0)
        if v in self.obj_index:
            return self.obj_index[v][1]
        return None


def tree_files(tree):
    return sorted(glob.glob(os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', '*.c')))


def check_tree(tree):
    """the object enums tell the truth: every record's own OBJ_ constant has its element index,
    the enum's indentation is the record's depth by its super links, and the links agree with
    each other (a child's super is its parent, next/prev are mutual).  Returns problem strings."""
    bad = []
    for p in tree_files(tree):
        f = CFile(p)
        if not f.records:
            continue
        depth_of = {}
        for m in ENUM.finditer(f.text):
            for ln in m.group(3).split('\n'):
                mm = re.match(r'^(\s+)(OBJ_\w+),', ln)
                if mm:
                    depth_of[mm.group(2)] = (len(mm.group(1)) - 4) // 2
        recs = {(r['slot'], r['elem']): r for r in f.records}
        for r in f.records:
            o = 'OBJ_' + r['member']
            got = f.obj_index.get(o)
            if got != (r['slot'], r['elem']):
                bad.append('%s: %s is %s in the enum, element %d of slot 0x%X in the struct'
                           % (f.name, o, got, r['elem'], r['slot']))
                continue
            sup, sub, nxt, prv = (f.link_value(r['fields'].get(x, '')) for x in ('super', 'sub', 'next', 'prev'))
            names = f.enums.get(next((lab for lab, (sl, ns) in f.enums.items() if sl == r['slot']), None), (0, []))[1]
            want = 0 if sup == NONE else (depth_of.get(names[sup]) + 1 if sup is not None and sup < len(names)
                                         and depth_of.get(names[sup]) is not None else None)
            if want is None or depth_of.get(o) != want:
                bad.append('%s: %s is indented at depth %s, its super (%s) says %s'
                           % (f.name, o, depth_of.get(o), sup, want))
            for k, back, what in ((sub, 'super', 'sub'), (nxt, 'prev', 'next'), (prv, 'next', 'prev')):
                c = recs.get((r['slot'], k)) if k not in (None, NONE) else None
                if c is not None and f.link_value(c['fields'].get(back, '')) != (r['elem'] if what != 'sub' else r['elem']):
                    bad.append('%s: %s.%s = %s, whose %s is not %s' % (f.name, o, what, k, back, o))
    return bad


def main():
    if '--check' in sys.argv:
        trees = [a for a in sys.argv[1:] if not a.startswith('--')] or ['v10', 'v9', 'v7', 'v6', 'v5']
        bad = []
        for t in trees:
            b = check_tree(t)
            bad += ['%s/%s' % (t, x) for x in b]
            print('naka_gui_model --check %s: %d problems' % (t, len(b)))
        for x in bad[:40]:
            print('  ' + x)
        sys.exit(1 if bad else 0)
    tree = sys.argv[1] if len(sys.argv) > 1 else 'v10'
    tot = 0
    for p in tree_files(tree):
        f = CFile(p)
        if f.records:
            print('%-34s %5d records in %3d tables, %d object enums'
                  % (f.name, len(f.records), len({r['slot'] for r in f.records}), len(f.enums)))
            tot += len(f.records)
    print('total records:', tot)


if __name__ == '__main__':
    main()


# ====================================================================== the GUI graph
# Boot_InitWorkRAM (boot/system_handlers.s) copies two ROM images into DRAM at reset; a view
# record registered at a DRAM address is initialised from the ROM bytes at the image address.
WORK_RAM_IMAGES = ((0x3D524, 0xEED8C8, 0x219E), (0xE35E, 0xEEFA66, 0x95B))


def rom_image_of(a):
    """the ROM address a DRAM address is initialised from (None if it is not in an image)."""
    for ram, rom, n in WORK_RAM_IMAGES:
        if ram <= a < ram + n:
            return a - ram + rom
    return None

STR_LIT = re.compile(r'"((?:[^"\\]|\\.)*)"')


def c_string_value(v):
    """the text of a C initializer made of string literals / ALIGNED_STRING(...), up to the
    first NUL; None if v is not a string initializer."""
    v = v.strip()
    if v.startswith('ALIGNED_STRING('):
        v = v[len('ALIGNED_STRING('):-1]
    if not v.startswith('"'):
        return '' if re.match(r'^(0x0+|0)$', v) else None
    out = ''
    for lit in STR_LIT.findall(v):
        s = re.sub(r'\\x([0-9A-Fa-f]{2})', lambda m: chr(int(m.group(1), 16)), lit)
        s = s.replace('\\"', '"').replace('\\\\', '\\').replace('\\0', '\0')
        out += s
    return out.split('\0')[0]


def file_strings(f):
    """member -> string, for every top-level initializer of f that is a string."""
    out = {}
    for m in re.finditer(r'^    \.(\w+) = ((?:ALIGNED_STRING\()?".*),$', f.text, re.M):
        s = c_string_value(m.group(2))
        if s is not None:
            out[m.group(1)] = s
    for m in re.finditer(r'^    \.(\w+) = (0x00|0),$', f.text, re.M):
        out.setdefault(m.group(1), '')
    return out


def ids_values(tree='v10'):
    """name -> value of every #define of naka_ids.h and naka_classes.h."""
    out = {}
    for h in ('naka_ids.h', 'naka_classes.h'):
        txt = read(os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', h))
        for n, v in re.findall(r'^#define (\w+)\s+(0x[0-9A-F]+)u', txt, re.M):
            out[n] = int(v, 16)
    return out


def equ_comments():
    """event_codes.s constant -> its comment."""
    out = {}
    for ln in read(os.path.join(ROOT, 'v10', 'maincpu', 'shared', 'event_codes.s')).split('\n'):
        m = re.match(r'^\.equ\s+(\w+)\s*,\s*\S+?\s*;\s*(.*)$', ln)
        if m:
            out[m.group(1)] = m.group(2).strip()
    return out


def registrations(m):
    """titles {id: dict(name, index, func, view, module)} and modes {id: dict(name, home)}
    from the RegTitle / RegMode calls of the v10 source, resolved through the Map m
    (scripts/analysis/nakarest_objtab_map.py)."""
    rx = re.compile(r'^\s*(RegTitle|RegTitleHama|RegMode)\s+([^;]*?)\s*(?:;\s*(.*))?$')
    titles, modes = {}, {}
    for p in sorted(glob.glob(os.path.join(ROOT, 'v10', 'maincpu', '**', '*.s'), recursive=True)):
        for ln in read(p).split('\n'):
            mm = rx.match(ln)
            if not mm:
                continue
            ops = [x.strip() for x in mm.group(2).split(',')]
            if len(ops) != 5:
                continue
            vals = [m._val(x) for x in ops]
            name = None
            cm = re.search(r'"((?:TT|MD)_\w+)"', mm.group(3) or '')
            if cm:
                name = cm.group(1)
            elif vals[1] is not None and m.inrom(vals[1]):
                name = m.string_at(vals[1])
            else:
                lm = re.search(r'_Str_((?:TT|MD)_\w+)$', ops[1])
                name = lm.group(1) if lm else ops[1]
            mod = vals[0]
            if mm.group(1) == 'RegMode':
                modes[0x01800000 + vals[2]] = dict(name=name, index=vals[2], func=vals[3], home=vals[4],
                                                   module=mod, file=os.path.relpath(p, ROOT))
            else:
                titles[0x01A00000 + vals[2]] = dict(name=name, index=vals[2], func=vals[3], view=vals[4],
                                                    module=mod, file=os.path.relpath(p, ROOT))
    return titles, modes


class Graph:
    """Screens, titles, modes and the transitions between them, over all C files of a tree."""

    def __init__(self, tree='v10', m=None):
        if m is None:
            sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
            import nakarest_objtab_map as O
            m = O.Map('v10')
        self.m = m
        self.tree = tree
        self.files = [CFile(p) for p in tree_files(tree)]
        self.files = [f for f in self.files if f.records]
        self.ids = ids_values(tree)
        self.name_by_value = {}
        for n, v in sorted(self.ids.items()):
            if n.startswith(('TITLE_', 'NAKA_MODE_', 'NAKA_APFUNC_', 'NAKA_FUNC_', 'NAKA_MAINFUNC_')):
                self.name_by_value.setdefault(v, n)
        self.comments = equ_comments()
        self.titles, self.modes = registrations(m)
        self.letters = class_letters(tree)
        self.rec = {}                       # (slot, elem) -> (file, record)
        self.strings = {}
        for f in self.files:
            self.strings[f.name] = file_strings(f)
            for r in f.records:
                self.rec[(r['slot'], r['elem'])] = (f, r)
        self.view_titles = {}
        for tid, t in self.titles.items():
            if t['view'] is not None:
                self.view_titles.setdefault((t['view'] >> 16, t['view'] & 0xFFFF), []).append(tid)
        # the ROM's own view of every registered Viewable table, for elements whose record is
        # not in the C sources (they are in the .s files): (slot, k) -> (address, links)
        self.rom = {}
        for reg in m.regs:
            if reg['cls'] != 0x1600010 or not m.inrom(reg['table']):
                continue
            for k, a in enumerate(m.entries(reg)):
                if not m.inrom(a):
                    a = rom_image_of(a)
                if a is not None:
                    self.rom[(reg['slot'], k)] = (a, tuple(m.u16(a + o) for o in (4, 6, 8, 10)))
        self.edges = []                     # (from title or None, from record key, to title, kind, label)
        self.func_entries = []              # (from title or None, record key, function name, label)
        self._edges()
        self._rom_edges()

    def rom_fields(self, key):
        """{field: (letter, value)} of an element read from the ROM bytes (records outside the C)."""
        a = self.rom.get(key, (None,))[0]
        c = self.m.record_class(a) if a is not None else None
        if not c:
            return {}
        out = {}
        sizes = {1: self.m.u8, 2: self.m.u16, 4: self.m.u32}
        import nakarest_objtab_map as O
        for off, name, ch in self.m.class_fields(c):
            n = O.SIG_SIZE.get(ch, 0)
            if n in sizes:
                out[name] = (ch, sizes[n](a + off))
        return out

    def rom_label(self, key):
        for fld in ('str', 'title', 'caption', 'stron', 'text', 'str1'):
            ch, v = self.rom_fields(key).get(fld, (None, None))
            if ch == 'X' and self.m.inrom(v):
                s = self.m.string_at(v)
                if s:
                    return s
        return ''

    def _rom_edges(self):
        for key in self.rom:
            if key in self.rec:
                continue
            for fld, (ch, v) in self.rom_fields(key).items():
                if ch == 'a' and (v >> 16) == 0x1A0 and v != 0xFFFFFFFF:
                    kind = 'exit' if fld == 'exit' else 'menu'
                    for frm in self.screen_titles(key) or [None]:
                        self.edges.append((frm, key, v, kind, self.rom_label(key)))

    def rom_name(self, key):
        """(class name, asm label or address) of an element from the ROM."""
        a = self.rom.get(key, (None,))[0]
        if a is None:
            return None, None
        c = self.m.record_class(a)
        lab = self.m.name_of(a)
        return (c['name'] if c else '?'), (lab[1] if lab[0] == a else '0x%06X' % a)

    # ------------------------------------------------------------ values
    def value(self, f, v):
        v = (v or '').strip()
        if re.match(r'^-?(0x[0-9A-Fa-f]+|\d+)$', v):
            return int(v, 0)
        if v in self.ids:
            return self.ids[v]
        if v in f.obj_index:
            return f.obj_index[v][1]
        return None

    def text_of(self, f, r, field):
        v = r['fields'].get(field, '')
        mm = re.match(r'^SELF\((\w+)\)$', v.strip())
        return self.strings[f.name].get(mm.group(1)) if mm else None

    def label(self, f, r):
        lt = dict(self.letters.get(r['cls'], []))
        for fld in ('str', 'title', 'caption', 'stron', 'text', 'str1'):
            if lt.get(fld) == 'X':
                s = self.text_of(f, r, fld)
                if s:
                    return s
        return ''

    def title_name(self, tid):
        n = self.name_by_value.get(tid)
        return n or '0x%08X' % tid

    # ------------------------------------------------------------ tree
    def links(self, key):
        """(super, sub, next, prev) of an element: from its C record, else from the ROM."""
        fr = self.rec.get(key)
        if fr:
            f, r = fr
            return tuple(f.link_value(r['fields'].get(x, '')) for x in ('super', 'sub', 'next', 'prev'))
        return self.rom.get(key, (None, (None,) * 4))[1]

    def parent(self, key):
        p = self.links(key)[0]
        return None if p in (None, NONE) else (key[0], p)

    def view_refs(self):
        """(slot, k) of a view -> the records whose WindowID / ScreenID field (letters t, N) names
        it: a window page shows its window object, so the window's widgets belong to the page's
        screen."""
        if hasattr(self, '_view_refs'):
            return self._view_refs
        refs = {}
        for f in self.files:
            for r in f.records:
                lt = dict(self.letters.get(r['cls'], []))
                for fld, letter in lt.items():
                    if letter in 'tN' and fld in r['fields']:
                        v = r['fields'][fld].strip()
                        mm = re.match(r'^NAKA_VIEW_ID\(\w+, (OBJ_\w+)\)$', v)
                        tgt = f.obj_index.get(mm.group(1)) if mm else None
                        if tgt is None and re.match(r'^0x[0-9A-Fa-f]+$', v):
                            x = int(v, 16)
                            tgt = (x >> 16, x & 0xFFFF)
                        if tgt:
                            refs.setdefault(tgt, []).append((r['slot'], r['elem']))
        for key in self.rom:
            if key in self.rec:
                continue
            for fld, (ch, v) in self.rom_fields(key).items():
                if ch in 'tN' and v not in (0, 0xFFFFFFFF):
                    refs.setdefault((v >> 16, v & 0xFFFF), []).append(key)
        self._view_refs = refs
        return refs

    def screen_titles(self, key, depth=0):
        """the titles that show the record at key: those whose view is it or an ancestor, or
        (through window pages) a view that names its top-level ancestor as its window."""
        seen = set()
        top = key
        while key and key not in seen:
            seen.add(key)
            if key in self.view_titles:
                return self.view_titles[key]
            top = key
            key = self.parent(key)
        if depth < 3:
            out = []
            for ref in self.view_refs().get(top, []):
                for t in self.screen_titles(ref, depth + 1):
                    if t not in out:
                        out.append(t)
            return out
        return []

    def children(self, key):
        out, k, seen = [], self.links(key)[1], set()
        while k not in (None, NONE) and k not in seen:
            seen.add(k)
            out.append((key[0], k))
            k = self.links((key[0], k))[2]
        return out

    def is_menu_class(self, cname):
        """a class derived from PsMenuBox or VwMenuBox (a menu entry box)."""
        ids = {c['name']: cid for cid, c in self.m.classes.items()}
        c = self.m.klass(ids.get(cname, -1))
        while c:
            if c['name'] in ('PsMenuBox', 'VwMenuBox'):
                return True
            c = self.m.klass(c['parent']) if c['parent'] not in (0xFFFFFFFF, 0x01600000) else None
        return False

    def menu_function(self, f, r):
        """the function object a menu-entry box calls when it opens a title by code."""
        if not self.is_menu_class(r['cls']):
            return None
        lt = dict(self.letters.get(r['cls'], []))
        for fld, letter in lt.items():
            if letter in 'jk' and fld in r['fields']:
                v = r['fields'][fld].strip()
                if v.startswith('NAKA_') and 'DefaultFunction' not in v:
                    return v
        return None

    def _edges(self):
        for f in self.files:
            for r in f.records:
                lt = dict(self.letters.get(r['cls'], []))
                key = (r['slot'], r['elem'])
                fn = self.menu_function(f, r)
                if fn:
                    for frm in self.screen_titles(key) or [None]:
                        self.func_entries.append((frm, key, fn, self.label(f, r)))
                for fld, letter in lt.items():
                    if letter != 'a' or fld not in r['fields']:
                        continue
                    to = self.value(f, r['fields'][fld])
                    if to is None or to == 0xFFFFFFFF or (to >> 16) != 0x1A0:
                        continue
                    kind = 'exit' if fld == 'exit' else 'menu'
                    for frm in self.screen_titles(key) or [None]:
                        self.edges.append((frm, key, to, kind, self.label(f, r)))

    def menu_paths(self):
        """title -> shortest [(mode or title, label)] path from a mode's home title, over menu
        entries (data links first) and, when add_code_edges() ran, the code that opens a title
        (a title procedure, or a menu box's function): a step's label is then
        '"ENTRY" (by Func)' or '(by Func)'."""
        import collections
        adj = collections.defaultdict(list)
        for frm, key, to, kind, lab in self.edges:
            if kind == 'menu' and frm is not None and frm != to:
                adj[frm].append((0, to, lab))
        for frm, to, routine, lab in getattr(self, 'code_edges', []):
            if frm != to:
                adj[frm].append((1, to, ('"%s" (by %s)' % (lab, routine)) if lab else '(by %s)' % routine))
        path = {}
        q = collections.deque()
        for mid, md in sorted(self.modes.items()):
            if md['home'] in self.titles and md['home'] not in path:
                path[md['home']] = [('mode', md['name'])]
                q.append(md['home'])

        def bfs():
            while q:
                t = q.popleft()
                for pri, to, lab in sorted(adj[t], key=lambda x: x[0]):
                    if to not in path:
                        path[to] = path[t] + [(t, lab)]
                        q.append(to)
        bfs()
        # second, the panel-switch handlers (lane kn5000-naka2, 2026-11-06; add_code_edges' main_edges): a
        # title no mode reaches but such a handler opens gets the path 'panel switch handler F > (by R)';
        # mode paths keep precedence
        for fname, to, routine in sorted(getattr(self, 'main_edges', [])):
            if to not in path and to in self.titles:
                path[to] = [('main', fname), ('main', '(by %s)' % routine)]
                q.append(to)
                bfs()
        return path


# ---------------------------------------------------------------- shared renderings
def title_description(g, tid):
    """what event_codes.s says a title is, without the parts every comment repeats."""
    n = g.title_name(tid)
    c = g.comments.get(n, '')
    c = re.sub(r'^Title id (0x)?[0-9a-fA-F]+, "TT_\w+":\s*', '', c)
    c = re.sub(r'\s*Derived by scripts/analysis/naka_object_id_names\.py\.?', '', c)
    return '' if c.startswith('registered by RegTitle in') else c


def title_screen_text(g, tid):
    """the title string the title's screen shows (its TtlScreen's `title`)."""
    t = g.titles.get(tid)
    if not t or t['view'] is None:
        return ''
    key = (t['view'] >> 16, t['view'] & 0xFFFF)
    for k in (key, (key[0], 0)):
        fr = g.rec.get(k)
        if fr:
            s = g.label(*fr)
            if s:
                return s
    return ''


def title_path(g, tid, paths=None):
    """'mode MD_X > "ENTRY" > "ENTRY"', or None when no menu entry leads to the title."""
    paths = g.menu_paths() if paths is None else paths
    if tid not in paths:
        return None
    parts = []
    for i, (x, lab) in enumerate(paths[tid]):
        if x == 'mode':
            b = getattr(g, 'mode_button', {}).get(lab)
            parts.append('%s button (mode %s)' % (' / '.join(b), lab) if b else 'mode %s' % lab)
        elif x == 'main' and i == 0:
            parts.append('panel switch handler %s' % lab)
        elif lab and (lab.startswith('"') or lab.startswith('(')):
            parts.append(lab)
        else:
            parts.append('"%s"' % lab if lab else '(unlabelled entry)')
    return ' > '.join(parts)


def title_links(g):
    """per title: menu entries [(label, to)], exits {to}, opened-from [(from, label)]."""
    import collections
    menu, exits, into = collections.defaultdict(list), collections.defaultdict(set), collections.defaultdict(list)
    for frm, key, to, kind, lab in g.edges:
        if kind == 'exit':
            if frm is not None:
                exits[frm].add(to)
            continue
        into[to].append((frm, lab))
        if frm is not None:
            menu[frm].append((lab, to))
    return menu, exits, into


# ---------------------------------------------------------------- code-driven transitions
FUNC_CLASSES = (0x1600001, 0x1600002, 0x1600003)      # Function, ApFunction, MainFunction tables


def func_label(m, fid):
    """the code label of function object id 0x01SS_KKKK (entry KKKK of the Function-class table
    registered at slot SS), or None."""
    if fid is None:
        return None
    r = m.by_slot.get((fid >> 16) & 0xFFF)
    if not r or r['cls'] not in FUNC_CLASSES:
        return None
    el = m.entries(r)
    k = fid & 0xFFFF
    if k >= len(el):
        return None
    lab = m.name_of(el[k])
    return lab[1] if lab[0] == el[k] else None


def mode_buttons(tree='v10'):
    """mode name (MD_X) -> [button names] from the mode-key maps of naka_extension_device.c
    (`MD_X, /* CPx_SEGn 0xNN: BUTTON ... */` rows; PanelButton_ModeKey reads those maps)."""
    out = {}
    txt = read(os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', 'naka_extension_device.c'))
    for md, seg, bit, name in re.findall(r'^\s+(MD_\w+),\s+/\* (CP[LR]_SEG\d+) (0x[0-9A-F]+): ([^(*]+?)\s*(?:\(|\*/)', txt, re.M):
        out.setdefault(md, []).append(name.strip())
    return out


def dirmd_page_handlers(tree):
    """title function -> set of routine labels that run as part of its page, for the pages driven by
    DirmdEmulator (lane kn5000-notes, 2026-11-06).  Read from the code's own structure, e.g.
    audio/sound_editor_routines.s and display/scoop_editor_data.s:

        SeAmpAmp1TitleFunc:   ld xiy, SeAmpAmp1TitleFunc_Methods ... call DirmdEmulator
        SeAmpAmp1TitleFunc_Methods:  .long _OnDraw, _OnHide, _OnSwitchIn, _Nop
        SeAmpAmp1TitleFunc_OnSwitchIn:  ... jp SeAmpAmp1TitleFunc_DispatchSwitch
        SeAmpAmp1TitleFunc_DispatchSwitch:  lda xde, (SeAmpAmp1TitleFunc_SwitchHandlers:24) ... call (xhl)
        SeAmpAmp1TitleFunc_SwitchHandlers:  .long <one handler per switch>

    The set is the methods, the routines they jump to, and the switch handlers."""
    import glob
    lines, at, longs = [], {}, {}
    for p in sorted(glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'), recursive=True)):
        L = [x.split(';')[0].strip() for x in open(p, 'rb').read().decode('latin-1').split('\n')]
        base = len(lines)
        lines += L
        cur = None
        for i, x in enumerate(L):
            m = re.match(r'^([A-Za-z_]\w*):\s*(.*)$', x)
            if m:
                at[m.group(1)] = base + i
                cur = m.group(1)
                longs.setdefault(cur, [])
                x = m.group(2)
            r = re.match(r'^\.long\s+([A-Za-z_]\w*)$', x)
            if r and cur:
                longs[cur].append(r.group(1))
    def body(lab, n=60):
        i = at.get(lab)
        out = []
        if i is None:
            return out
        for x in lines[i + 1:i + 1 + n]:
            out.append(x)
            if re.match(r'^(ret|retd|reti)\b', x):
                break
        return out
    res = {}
    for lab in at:
        if not lab.endswith('TitleFunc'):
            continue
        mt = [re.match(r'^ld\s+xiy,\s*(\w+_Methods)$', x) for x in body(lab, 12)]
        mt = [x.group(1) for x in mt if x]
        if not mt or 'call DirmdEmulator' not in [re.sub(r'\s+', ' ', x) for x in body(lab, 12)]:
            continue
        hs = set()
        for meth in longs.get(mt[0], []):
            hs.add(meth)
            for x in body(meth, 6):
                j = re.match(r'^jp\s+(\w+)$', x)
                if j:
                    hs.add(j.group(1))
                    for y in body(j.group(1)):
                        k = re.match(r'^lda\s+xde,\s*\((\w+_SwitchHandlers)(?::24)?\)$', y)
                        if k:
                            hs.update(longs.get(k.group(1), []))
        res[lab] = hs
    return res


# The trees the two path rules of lane kn5000-naka2 (2026-11-06) apply to: a title procedure's direct callees,
# and the panel-switch handlers as roots (add_code_edges, menu_paths).  The paths feed the SCREEN headers
# naka_gui_symbolize.py writes into each tree's C; v6 / v5's C belongs to the lane that ports them, so they join
# when it regenerates their headers (`python3 scripts/converters/naka_gui_symbolize.py --tree v6 --headers`, then
# add the tree here).
CALLEE_RULE_TREES = ('v10', 'v9', 'v7')


def add_code_edges(g):
    """g.code_edges: (from title, to title, routine) for every title procedure and menu box
    function that passes a TT_* index; g.mode_button: MD_X -> buttons."""
    sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
    import name_title_index_operands as N
    extra = set()
    for r in g.m.regs:
        if r['cls'] in FUNC_CLASSES and g.m.inrom(r['table']):
            for a in g.m.entries(r):
                lab = g.m.name_of(a)
                if lab[0] == a:
                    extra.add(lab[1])
    dirmd = dirmd_page_handlers(g.tree)
    for hs in dirmd.values():
        extra |= hs
    opens = N.opens_by_routine(g.tree, 'title', extra)
    tt = {n: v for n, v in g.ids.items() if n.startswith('TT_')}
    g.routine_opens = opens
    g.code_edges = []
    calls = N.callees(g.tree, extra)
    wide = g.tree in CALLEE_RULE_TREES
    for tid, t in g.titles.items():
        lab = func_label(g.m, t['func'])
        for n in sorted(opens.get(lab, ())):
            if n in tt:
                g.code_edges.append((tid, 0x01A00000 + tt[n], lab, ''))
        # its direct callees' titles too, the rule menu-box functions follow below (lane kn5000-naka2,
        # 2026-11-06: StylCnvModlTtlFunc -> FloppyState_Dispatch opens the Style Convert pages)
        for c in sorted(calls.get(lab, ())) if lab and wide else ():
            for n in sorted(set(opens.get(c, ())) - set(opens.get(lab, ()))):
                if n in tt:
                    g.code_edges.append((tid, 0x01A00000 + tt[n], c, ''))
    # panel-switch handlers are roots of their own (lane kn5000-naka2, 2026-11-06): a Function-table entry
    # (extra) that is no title's procedure and whose own body names a panel-switch event (EVT_SW_IN*) is
    # where a press arrives without any menu entry; the titles it or its direct callees open get the path
    # 'panel switch handler F > (by R)' (g.main_edges: (handler, title, routine)), used by menu_paths()
    g.main_edges = []
    if wide:
        procs = {func_label(g.m, t['func']) for t in g.titles.values()}
        for h in sorted(N.routines_naming(g.tree, re.compile(r'\bEVT_SW_IN\w*\b'), extra) & extra - procs):
            for r in [h] + sorted(calls.get(h, ())):
                for n in sorted(opens.get(r, ())):
                    if n in tt:
                        g.main_edges.append((h, 0x01A00000 + tt[n], r))
    # a DirmdEmulator page (the sound editor's TITLE_SE* screens): its title function's methods and
    # the switch handlers its OnSwitchIn dispatches to open the titles (SeMenu_SendEvent, ...)
    for tid, t in g.titles.items():
        lab = func_label(g.m, t['func'])
        for h in sorted(dirmd.get(lab, ())):
            for n in sorted(opens.get(h, ())):
                if n in tt:
                    g.code_edges.append((tid, 0x01A00000 + tt[n], h, ''))
    # a menu box's function often only calls the routine that opens the title
    # (DirectPlayTtlJgFunc -> FileIO_DetectFileTypeAndPost): count its direct callees' titles too
    for frm, key, fn, label in g.func_entries:
        lab = func_label(g.m, g.ids.get(fn))
        if lab and lab in calls:
            for c in calls[lab]:
                opens[lab] = opens.get(lab, set()) | opens.get(c, set())
        for n in sorted(opens.get(lab, ())):
            if n in tt and frm is not None:
                g.code_edges.append((frm, 0x01A00000 + tt[n], lab, label))
    md = mode_buttons(g.tree)
    g.mode_button = {}
    for mid, m_ in g.modes.items():
        g.mode_button[m_['name']] = md.get(m_['name'], [])
