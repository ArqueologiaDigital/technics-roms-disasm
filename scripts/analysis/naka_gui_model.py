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


def main():
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
                if m.inrom(a):
                    self.rom[(reg['slot'], k)] = (a, tuple(m.u16(a + o) for o in (4, 6, 8, 10)))
        self.edges = []                     # (from title or None, from record key, to title, kind, label)
        self._edges()

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

    def screen_titles(self, key):
        """the titles that show the record at key: those whose view is it or an ancestor."""
        seen = set()
        while key and key not in seen:
            seen.add(key)
            if key in self.view_titles:
                return self.view_titles[key]
            key = self.parent(key)
        return []

    def children(self, key):
        out, k, seen = [], self.links(key)[1], set()
        while k not in (None, NONE) and k not in seen:
            seen.add(k)
            out.append((key[0], k))
            k = self.links((key[0], k))[2]
        return out

    def _edges(self):
        for f in self.files:
            for r in f.records:
                lt = dict(self.letters.get(r['cls'], []))
                key = (r['slot'], r['elem'])
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
        """title -> shortest [(mode or title, label)] path from a mode's home title over menu
        (non-EXIT) edges."""
        import collections
        adj = collections.defaultdict(list)
        for frm, key, to, kind, lab in self.edges:
            if kind == 'menu' and frm is not None and frm != to:
                adj[frm].append((to, lab))
        path = {}
        q = collections.deque()
        for mid, md in sorted(self.modes.items()):
            if md['home'] in self.titles and md['home'] not in path:
                path[md['home']] = [('mode', md['name'])]
                q.append(md['home'])
        while q:
            t = q.popleft()
            for to, lab in adj[t]:
                if to not in path:
                    path[to] = path[t] + [(t, lab)]
                    q.append(to)
        return path
