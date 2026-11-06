#!/usr/bin/env python3
r"""gen_naka_gui_headers.py -- the NAKA C headers that let a GUI source name its classes and ids.

QUESTION ANSWERED
-----------------
"What may a NAKA widget record in C write instead of a raw class id (0x0160xxxx), a raw title id
(0x01A0xxxx) or a raw function-object id (0x0120xxxx...)?"  Two generated headers, one copy per
main-CPU tree (v10, v9, v7, v6, v5 -- the trees share v10's C, see below):

  <tree>/maincpu/ui_widgets/naka_classes.h
      one `#define NAKA_CLASS_<Name> 0x016SKKKKu` and one packed `naka_cls_<Name>_t` typedef for
      every class of the 9 Class tables the main CPU registers (293 in v10), read from the ROM by
      scripts/analysis/nakarest_objtab_map.py (THE CLASS SYSTEM).  Field names are the class chain's
      own propname strings, in record order, made C-safe exactly as
      scripts/converters/nakarest_type_records.py did (`class` -> `class_`, a repeated name gets
      `_2`), so every record initializer written against the old per-file typedefs still compiles.
      `NAKA_CLASS(TtlScreen)` spells `NAKA_CLASS_TtlScreen`.
  <tree>/maincpu/ui_widgets/naka_ids.h
      every `.equ` of v10/maincpu/shared/event_codes.s (TITLE_*, NAKA_MODE_*, NAKA_FUNC_*,
      NAKA_APFUNC_*, NAKA_MAINFUNC_*, NAKA_VIEW_*, EVT_*) as a C `#define`, except the NAKA_CLASS_*
      constants that naka_classes.h already defines (it checks they agree).

  hdae5000/shared/naka_values.s
      the same property-value names as `.equ`s (and NAKA_NONE / NAKA_NO_OBJECT), for the
      assembler GUI sources: the HD-AE5000 trees' class macros (hdae5000/shared/naka_ui_macros.s)
      spell their records' values with them.  One copy; both HD-AE5000 trees include it.

Both headers are generated from v10 and copied unchanged into v9/v7/v6/v5: those trees compile v10's C
sources (v9 = v10 in all GUI files but one pointer; v7/v6/v5 patch the compiled bins with their
*_c_divergence.json), so the values the C spells must be v10's.

  <tree>/maincpu/ui_widgets/naka_ram_cells.h
      the work-RAM cells the records point at (RAM_<cell>).  v10, v9 and v7 put every cell at one
      address, so they share v10's copy; v6 and v5 place some cells lower (their work-RAM image is
      4 bytes shorter, and the second image is copied to 0xE29E instead of 0xE35E), so their copies
      carry their own addresses (ram_mapper below), and their C compiles to their own pointers
      instead of patching them (since 2026-11-02, lane open6/kn5000-c).  v6/v5 lack one class (IvMPver,
0x01610024); no C record of theirs uses it.  Their Murai_SoundMenuWorkCells are assembly lines, one per
      cell, and lack the MPVersion window cell, so the cells after it are placed by those lines
      (asm_cell_anchors; since 2026-11-06, lane open12/v6v5-port3).

RUN (repository root; needs rebuilt_ROMs/kn5000_v10_program.llvm.elf)
    python3 scripts/generators/gen_naka_gui_headers.py            # write all five trees' copies
    python3 scripts/generators/gen_naka_gui_headers.py --check    # exit 1 if any copy is stale
"""
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
import nakarest_objtab_map as O          # noqa: E402

TREES = ['v10', 'v9', 'v7', 'v6', 'v5']
C_KEYWORDS = {'auto', 'break', 'case', 'char', 'const', 'continue', 'default', 'do', 'double',
              'else', 'enum', 'extern', 'float', 'for', 'goto', 'if', 'int', 'long', 'register',
              'return', 'short', 'signed', 'sizeof', 'static', 'struct', 'switch', 'typedef',
              'union', 'unsigned', 'void', 'volatile', 'while', 'class'}
# What a propdata letter is, as far as the C needs to know (ui-framework.md "Type letters"; the
# letters whose meaning the property-type procs establish are named, the rest keep the letter).
LETTER = {'M': 'class id', '[': 'object index in this table', ']': 'view flags', 'P': 'rectangle',
          '^': 'colour id', '_': 'border id', 'd': 'alignment id', 'c': 'font id', 'b': 'icon id',
          'a': 'title id', 'X': 'string pointer', 'j': 'ApFunction object id',
          'k': 'MainFunction object id', 'm': 'RAM cell (live value)', 'n': 'RAM cell (live value)',
          'r': 'RAM cell (live value)', 't': 'view object id', 'e': 'edit-switch id',
          'g': 'line mode id', 'h': 'frame id', 'u': 'part id', 'v': 'track id'}


def cname(f):
    f = re.sub(r'[^A-Za-z0-9_]', '_', f)
    return f + '_' if f in C_KEYWORDS else f


def class_layout(m, c):
    fl = [(o, cname(f), O.SIG_SIZE[ch], ch) for o, f, ch in m.class_fields(c)]
    names = set()
    for i, (o, f, n, ch) in enumerate(fl):
        base, j = f, 2
        while f in names:
            f = '%s_%d' % (base, j)
            j += 1
        names.add(f)
        fl[i] = (o, f, n, ch)
    return fl, c['allsize']


def module_of(c):
    return (c['reg'].get('init') or 'Initialize?').replace('Initialize', '')


def classes_h(m):
    out = ['/* naka_classes.h -- GENERATED by scripts/generators/gen_naka_gui_headers.py; do not edit.',
           ' *',
           ' * Every NAKA class of the main CPU, read from the 9 Class tables the firmware registers',
           ' * (`RegObjTable NAKA_CLASS_Class, ClassProc, ...`; scripts/analysis/nakarest_objtab_map.py,',
           ' * THE CLASS SYSTEM).  A class id is 0x016S_KKKK: entry KKKK of the Class table in registry',
           ' * slot 0x16S (ClassProc, ui/ui_widget_defs.s: `srl 16; and 0xFFF`, then x 24 bytes).',
           ' * Every widget record starts with its class id; its fields are its class chain\'s fields,',
           ' * named by each class\'s own propname strings, in record order.',
           ' *',
           ' * The rectangle (`rect`, propdata letter P) is x1, y1, x2, y2, inclusive: RectX2Proc and',
           ' * RectY2Proc (ui/ui_widget_defs.s) edit x2 / y2 as "width" / "height" -- GET answers',
           ' * x2 - x1 + 1, SET stores x1 + width - 1 -- so a record writes it NAKA_XYWH(x, y, w, h)',
           ' * (naka_types.h).',
           ' */',
           '',
           '#ifndef NAKA_CLASSES_H',
           '#define NAKA_CLASSES_H',
           '',
           '#include <stdint.h>',
           '',
           '#define NAKA_CLASS(name)  NAKA_CLASS_##name',
           '']
    width = max(len(c['name']) for c in m.classes.values())
    last = None
    for cid in sorted(m.classes):
        c = m.classes[cid]
        if module_of(c) != last:
            last = module_of(c)
            out.append('/* %s module: Class table slot 0x%X */' % (last, c['slot']))
        p = m.klass(c['parent']) if c['parent'] != 0xFFFFFFFF else None
        out.append('#define NAKA_CLASS_%-*s 0x%08Xu  /* parent %s, %d bytes */'
                   % (width, c['name'], cid, p['name'] if p else '-', c['allsize']))
    out.append('')
    out.extend(prop_value_names(m))
    out.append('')
    out.append('/* One packed struct per class: the record a widget of that class occupies. */')
    out.append('')
    for cid in sorted(m.classes):
        c = m.classes[cid]
        fl, size = class_layout(m, c)
        p = m.klass(c['parent']) if c['parent'] != 0xFFFFFFFF else None
        proc = m.name_of(c['proc'])
        procname = proc[1] if proc[0] == c['proc'] else '0x%06X' % c['proc']
        out.append('/* %s (0x%08X, %s module): parent %s, %d bytes, class procedure %s */'
                   % (c['name'], cid, module_of(c), p['name'] if p else '-', size, procname))
        out.append('typedef struct __attribute__((packed)) {')
        off = 0
        if not fl and size:
            out.append('    uint8_t _pad_0[%d];' % size)
            off = size
        for o, f, n, ch in fl:
            if o > off:
                out.append('    uint8_t _pad_%d[%d];' % (off, o - off))
                off = o
            what = LETTER.get(ch, '')
            note = '/* +%d %s%s */' % (o, ch, (' ' + what) if what else '')
            if n == 8:
                decl = 'int16_t %s[4];' % f
            else:
                decl = '%s %s;' % ({1: 'uint8_t', 2: 'uint16_t', 4: 'uint32_t'}[n], f)
            out.append('    %-30s%s' % (decl, note))
            off = o + n
        if off < size:
            out.append('    uint8_t _pad_%d[%d];' % (off, size - off))
        out.append('} naka_cls_%s_t;' % c['name'])
        out.append('_Static_assert(sizeof(naka_cls_%s_t) == %d, "class %s is %d bytes");'
                   % (c['name'], size, c['name'], size))
        out.append('')
    out.append('#endif /* NAKA_CLASSES_H */')
    return '\n'.join(out) + '\n'


# The property types whose values the firmware names (SupportClass_PropTypeRecords entry
# letter - 'A': {proc, count, size, -> {name, value} x count}), and the index types whose names
# live in a table of their own.  The C spells a field of such a letter by these names.
ENUM_LETTERS = '^_]defghluvwZ'
INDEX_TYPES = (('c', 'FontIDProc_FontNameTable', 'FontIDProc_EntryCount', 'FontIDProc_DumpPrefix'),
               ('i', 'BitmapIDProc_PtrTable', 'BitmapIDProc_EntryCount', 'BitmapIDProc_DumpPrefix'),
               ('b', 'IconIDProc_NameTable', 'IconIDProc_EntryCount', 'IconIDProc_DumpPrefix'))


def prop_types(m):
    """letter -> (proc name, [(value name, value)]) for every enumerated property type, and
    for the three index types (font, bitmap, icon) the dump name of each index: the type's
    EVT_MAKE_DUMP prefix + the table's string ("id" + "CHARA1", "idICON_" + "i12")."""
    t = m.sym['SupportClass_PropTypeRecords']
    out = {}
    for k in range(0x37):
        a = t + 12 * k
        ch = chr(0x41 + k)
        proc = m.name_of(m.u32(a))[1]
        cnt, vt = m.u16(a + 4), m.u32(a + 8)
        if ch in ENUM_LETTERS:
            out[ch] = (proc, [(m.string_at(m.u32(vt + 8 * i)), m.u32(vt + 8 * i + 4))
                              for i in range(cnt)], 'SupportClass_PropTypeRecords[\'%s\']' % ch)
    for ch, tab, cnt, pre in INDEX_TYPES:
        a = m.sym[tab]
        if not m.inrom(a):
            a = a - 0x3D524 + 0xEED8C8   # a RAM table: its work-RAM image (Boot_InitWorkRAM)
        n = m.u16(m.sym[cnt])
        prefix = m.string_at(m.sym[pre])
        out[ch] = (m.name_of(m.u32(t + 12 * (ord(ch) - 0x41)))[1],
                   [(prefix + m.string_at(m.u32(a + 4 * i)), i) for i in range(n)], tab)
    return out


def value_names(m):
    """[(letter, proc, source, [(name, value)])]: the named property values, valid C / assembler
    names only, each name once (the first value it is given)."""
    out, seen = [], set()
    for ch, (proc, vals, src) in sorted(prop_types(m).items()):
        keep = []
        for name, v in vals:
            if not re.match(r'^[A-Za-z_]\w*$', name) or name in seen:
                continue
            seen.add(name)
            keep.append((name, v & 0xFFFFFFFF))
        out.append((ch, proc, src, keep))
    return out


# An object-id field (propdata N / t / a / r ...) that names no object holds 0xFFFFFFFF; the
# firmware's own lists have no name for it (UserIDProc's iduNone is the same value for letter l).
NO_OBJECT = ('NAKA_NO_OBJECT', 0xFFFFFFFF, 'an object-id field that names no object')


# What each used icon shows (open items N-b0077010 / N-94c35266): the firmware names them only iNN.
ICON_SHOWS = {k: v for k, v in json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
              'naka_icon_descriptions.json'))).items() if not k.startswith('_')}


def icon_shows(name):
    return ICON_SHOWS.get(name[len('idICON_'):]) if name.startswith('idICON_') else None


def prop_value_names(m):
    out = ['/* Property values by the firmware\'s own names.  A class field\'s propdata letter L selects',
           ' * entry L - \'A\' of SupportClass_PropTypeRecords (registered by InitializeObjectTable as',
           ' * registry slot 0x260, 0x37 entries, one per letter \'A\'..\'w\'): {property-type proc, number',
           ' * of named values, value size, -> {name, value} pairs}.  The names are those pairs (CL_White,',
           ' * BD_None, ...); fonts, bitmaps and icons are indices into a name table, spelled as the',
           ' * type\'s EVT_MAKE_DUMP writes them (the DumpPrefix string + the table\'s name).',
           ' * The assembler twin of this list is hdae5000/shared/naka_values.s (same generator). */',
           '#define %-24s 0x%08Xu  /* %s */' % NO_OBJECT]
    for ch, proc, src, vals in value_names(m):
        out.append('/* letter %s, %s (%s) */' % (ch, proc, src))
        for name, v in vals:
            shows = icon_shows(name)
            out.append('#define %-24s 0x%04Xu' % (name, v) + ('  /* shows: %s */' % shows if shows else ''))
    return out


def values_s(m):
    """The assembler twin of prop_value_names, for the assembler GUI sources (the HD-AE5000's
    hdae5000/shared/naka_ui_macros.s): the same names, the same values."""
    out = ['; naka_values.s -- GENERATED by scripts/generators/gen_naka_gui_headers.py; do not edit.',
           ';',
           '; NAKA property values by the firmware\'s own names, the `.equ` twins of the #defines in',
           '; v10/maincpu/ui_widgets/naka_classes.h ("Property values by the firmware\'s own names"):',
           '; entry L - \'A\' of the main CPU\'s SupportClass_PropTypeRecords for propdata letter L,',
           '; and fonts / bitmaps / icons by their EVT_MAKE_DUMP names.  Read from the v10 build, so the',
           '; C and the assembler sources cannot drift apart.',
           '',
           '\t.equ\tNAKA_NONE, 0xffff\t\t; a Viewable link (super / sub / next / prev) to no object',
           '\t.equ\t%s, 0x%08x\t; %s' % (NO_OBJECT[0], NO_OBJECT[1], NO_OBJECT[2])]
    for ch, proc, src, vals in value_names(m):
        out.append('')
        out.append('; letter %s, %s (%s)' % (ch, proc, src))
        for name, v in vals:
            shows = icon_shows(name)
            out.append('\t.equ\t%s, 0x%x' % (name, v) + ('\t; shows: %s' % shows if shows else ''))
    return '\n'.join(out) + '\n'


def ids_h(m):
    src = os.path.join(ROOT, 'v10', 'maincpu', 'shared', 'event_codes.s')
    names = {c['name']: cid for cid, c in m.classes.items()}
    out = ['/* naka_ids.h -- GENERATED by scripts/generators/gen_naka_gui_headers.py; do not edit.',
           ' *',
           ' * The constants of v10/maincpu/shared/event_codes.s, for the C sources: title ids',
           ' * (TITLE_*, 0x01A0xxxx), mode ids (NAKA_MODE_*), function-object ids (NAKA_FUNC_* /',
           ' * NAKA_APFUNC_* / NAKA_MAINFUNC_*), view ids (NAKA_VIEW_*) and event codes (EVT_*).',
           ' * The meaning of each one is the comment on its .equ there.  The NAKA_CLASS_* constants',
           ' * of the main CPU\'s classes come from naka_classes.h instead.',
           ' */',
           '',
           '#ifndef NAKA_IDS_H',
           '#define NAKA_IDS_H',
           '']
    rx = re.compile(r'^\.equ\s+([A-Za-z_]\w*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*(?:;.*)?$')
    for ln in open(src, encoding='latin-1'):
        mm = rx.match(ln.rstrip('\n'))
        if not mm:
            continue
        n, v = mm.group(1), int(mm.group(2), 0)
        if n.startswith('NAKA_CLASS_') and n[11:] in names:
            if names[n[11:]] != v:
                sys.exit('gen_naka_gui_headers: %s = 0x%X in event_codes.s, class table says 0x%X'
                         % (n, v, names[n[11:]]))
            continue
        out.append('#define %-40s 0x%08Xu' % (n, v))
    out.append('')
    out.append('#endif /* NAKA_IDS_H */')
    return '\n'.join(out) + '\n'


def ram_cells(path):
    """[(name, RAM address)] of every named scalar cell of the work-RAM image part that
    naka_sequencer_channels.c spells (ROM BASE .. BASE + size, copied by Boot_InitWorkRAM from
    ROM 0xEED8C8 to RAM 0x3D524): top-level scalar members by their own name, and the scalar
    fields of its local packed struct members by the field's name (the cell names of
    scripts/converters/name_widget_value_cells.py).  Offset-only names (field_XXXX) and the
    view-record fields of RAM-resident widgets (class_, super, ...) are skipped."""
    sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
    import nakarest_c_model as CM
    txt = open(path, encoding='latin-1').read()
    base = int(re.search(r'^#define BASE\s+0x([0-9A-Fa-f]+)u', txt, re.M).group(1), 16)
    ram0 = base - 0xEED8C8 + 0x3D524
    local = {}
    # the class records typed in the image (naka_cls_<Class>_t, naka_classes.h) count as local
    # structs too: their live-value fields are cells like any other
    hdr = open(os.path.join(os.path.dirname(path), 'naka_classes.h'), encoding='latin-1').read()
    CM.register_local_types(hdr)
    for mm in re.finditer(r'typedef struct __attribute__\(\(packed\)\) \{([^{}]*)\} (\w+);', hdr + '\n' + txt):
        fl, off = [], 0
        for ln in mm.group(1).split('\n'):
            f = re.match(r'\s*(u?int(?:8|16|32)_t|char)\s+(\w+)((?:\[\d+\])*)\s*;', ln)
            if not f:
                continue
            n = CM._SCALAR[f.group(1)]
            for d in re.findall(r'\[(\d+)\]', f.group(3)):
                n *= int(d)
            fl.append((off, f.group(2), bool(f.group(3))))
            off += n
        local[mm.group(2)] = fl
    b = CM.CBlob(path)
    out, skip = [], re.compile(r'^(field|bytes|ptr|pad)_[0-9a-fA-F]+$|^(class_|super|sub|next|prev|flag|rect|_pad_\d+)$')
    for mb in b.members:
        if mb.ctype in local and not mb.dims:
            for off, name, isarr in local[mb.ctype]:
                if not skip.match(name) and not isarr:
                    # a cell name says whose cell it is (TrAsGrid_SelCol); a bare field name
                    # (Total, exit) is qualified by its member
                    out.append((name if '_' in name else '%s_%s' % (mb.name, name), ram0 + mb.offset + off))
        elif mb.ctype in CM._SCALAR and not skip.match(mb.name):
            out.append((mb.name, ram0 + mb.offset))
    seen, uniq = {}, []
    for n, a in out:
        seen.setdefault(n, []).append(a)
    return [(n, a) for n, a in out if len(seen[n]) == 1]


def tree_syms(tree):
    syms = {}
    for ln in open(os.path.join(ROOT, 'symbols', 'maincpu_%s_symbols_reference.txt' % tree)):
        p = ln.split()
        if len(p) == 2 and not ln.startswith('#'):
            syms[p[0]] = int(p[1], 16)
    return syms


def work_ram_images(tree, syms):
    """[(RAM dest, ROM source, size)] of the two copies Boot_InitWorkRAM (boot/system_handlers.s)
    makes in TREE: `ld xde, DEST / ld xhl, WorkRamInit_Image[2] / ld xbc, SIZE`."""
    txt = open(os.path.join(ROOT, tree, 'maincpu', 'boot', 'system_handlers.s'), 'rb').read().decode('latin-1')
    out = [(int(m.group(1), 16), syms[m.group(2)], int(m.group(3), 16)) for m in re.finditer(
        r'ld\s+xde,\s*0x([0-9a-f]+)\s*\n\s*ld\s+xhl,\s*(WorkRamInit_Image2?)\s*\n\s*ld\s+xbc,\s*0x([0-9a-f]+)', txt)]
    if len(out) != 2:
        raise SystemExit('%s: Boot_InitWorkRAM\'s two image copies not found' % tree)
    return out


WORK_CELL = re.compile(r'^\t\.(long|short|byte)\t\S+\t; work cell: (\S+) (\S+) \(\w+\)$')


def _cell_matches(v10_name, rec):
    """does the asm cell line's record name (NakaWidget_Softver) name the v10 C cell (Softver_Window)?"""
    stem = re.sub(r'^Naka(?:Widget|MenuItem|Container)_', '', rec).lower()
    return v10_name.split('_')[0].lower() in stem or stem.split('_')[0] in v10_name.lower()


def asm_cell_anchors(tree, s10, st):
    """[(v10 ROM address, TREE ROM address or None)] for the work cells TREE spells as assembly lines
    (`.long|.short <value>\t; work cell: <record> <field> (<Class>)` after a label, the port's spelling
    of a cell block that v10 holds as a local struct of naka_sequencer_channels.c, <label>_t).  The
    tree's lines and v10's struct fields are aligned in order by size and record name (a dynamic
    programme; a field TREE's lines lack is None: v6 / v5 have no MPVersion window cell, so their
    Murai_SoundMenuWorkCells is 4 bytes shorter and the cells after it sit 4 bytes lower).  v10, v9
    and v7 hold these blocks as .incbin slices and get no anchors here."""
    src = open(os.path.join(ROOT, 'v10', 'maincpu', 'ui_widgets', 'naka_sequencer_channels.c'),
               encoding='latin-1').read()
    size = {'uint8_t': 1, 'char': 1, 'uint16_t': 2, 'uint32_t': 4, 'int16_t': 2, 'int32_t': 4,
            'long': 4, 'short': 2, 'byte': 1}
    out = []
    for p in sorted(glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'), recursive=True)):
        lines = open(p, 'rb').read().decode('latin-1').split('\n')
        for i, ln in enumerate(lines):
            m = re.match(r'^(\w+):\s*$', ln)
            if not m or m.group(1) not in st or m.group(1) not in s10:
                continue
            cells, off = [], 0
            for ln2 in lines[i + 1:]:
                if ln2.startswith(';'):
                    continue
                c = WORK_CELL.match(ln2)
                if not c:
                    break
                cells.append((size[c.group(1)], c.group(2), off))
                off += size[c.group(1)]
            if not cells:
                continue
            td = re.search(r'typedef struct __attribute__\(\(packed\)\) \{([^{}]*)\} %s_t;' % m.group(1), src)
            if not td:
                raise SystemExit('%s: %s has work-cell lines but v10 has no %s_t' % (tree, m.group(1), m.group(1)))
            fl, o = [], 0
            for ty, nm in re.findall(r'^\s*(u?int(?:8|16|32)_t|char)\s+(\w+);', td.group(1), re.M):
                fl.append((size[ty], nm, o))
                o += size[ty]
            # align: a pair costs 0 (same size, names agree) or 1 (same size); a gap 2
            n, k, INF = len(fl), len(cells), 1 << 30
            D = [[INF] * (k + 1) for _ in range(n + 1)]
            D[0][0] = 0
            for x in range(n + 1):
                for y in range(k + 1):
                    d = D[x][y]
                    if d >= INF:
                        continue
                    if x < n:
                        D[x + 1][y] = min(D[x + 1][y], d + 2)
                    if y < k:
                        D[x][y + 1] = min(D[x][y + 1], d + 2)
                    if x < n and y < k and fl[x][0] == cells[y][0]:
                        c1 = 0 if _cell_matches(fl[x][1], cells[y][1]) else 1
                        D[x + 1][y + 1] = min(D[x + 1][y + 1], d + c1)
            x, y, pairs = n, k, []
            while x or y:
                if x and y and fl[x - 1][0] == cells[y - 1][0] and \
                        D[x][y] == D[x - 1][y - 1] + (0 if _cell_matches(fl[x - 1][1], cells[y - 1][1]) else 1):
                    pairs.append((fl[x - 1][2], cells[y - 1][2]))
                    x, y = x - 1, y - 1
                elif x and D[x][y] == D[x - 1][y] + 2:
                    pairs.append((fl[x - 1][2], None))
                    x -= 1
                else:
                    raise SystemExit('%s: %s line %d has no v10 field' % (tree, m.group(1), y))
            b10, bt = s10[m.group(1)], st[m.group(1)]
            out += [(b10 + o10, None if ot is None else bt + ot) for o10, ot in reversed(pairs)]
    return out


def ram_mapper(tree):
    """v10 work-RAM address -> TREE's address of the same cell.  A cell of an image is placed by the
    nearest label at or before its ROM image byte that both trees define inside that image (the
    image's own label at worst), or by the tree's own work-cell line for it (asm_cell_anchors):
    TREE's ROM address of the byte, then TREE's copy destination.  An address outside both images is
    returned as it is.  f.absent is the set of v10 addresses of cells TREE's image does not have."""
    if tree in ('v10', 'v9'):
        f = (lambda a: a)
        f.absent = set()
        return f
    s10, st = tree_syms('v10'), tree_syms(tree)
    i10, it = work_ram_images('v10', s10), work_ram_images(tree, st)
    cell = asm_cell_anchors(tree, s10, st)
    anchors, absent = [], set()
    for (d10, r10, n10), (dt, rt, nt) in zip(i10, it):
        labs = {v: st[k] for k, v in s10.items() if r10 <= v < r10 + n10 and k in st
                and rt <= st[k] < rt + nt}
        for v, t in cell:
            if r10 <= v < r10 + n10:
                if t is None:
                    absent.add(v - r10 + d10)
                else:
                    labs[v] = t
        labs = sorted(labs.items())
        anchors.append(([v for v, _ in labs], [t for _, t in labs]))

    def f(a):
        for (d10, r10, n10), (dt, rt, nt), (av, at) in zip(i10, it, anchors):
            if d10 <= a < d10 + n10:
                rom = a - d10 + r10
                import bisect
                k = bisect.bisect_right(av, rom) - 1
                return (at[k] + rom - av[k] if k >= 0 else rom - r10 + rt) - rt + dt
        return a
    f.absent = absent
    return f


def ram_cells_h(tree='v10'):
    src = os.path.join(ROOT, 'v10', 'maincpu', 'ui_widgets', 'naka_sequencer_channels.c')
    cells = ram_cells(src)
    head = head_cells(set(a for n, a in cells), set(n for n, a in cells))
    f = ram_mapper(tree)
    moved = any(f(a) != a for n, a in cells + head)
    out = ['/* naka_ram_cells.h -- GENERATED by scripts/generators/gen_naka_gui_headers.py; do not edit.',
           ' *',
           ' * The RAM address of every named cell of the work-RAM image that',
           ' * v10/maincpu/ui_widgets/naka_sequencer_channels.c spells: Boot_InitWorkRAM',
           ' * (boot/system_handlers.s) copies ROM 0xEED8C8.. to RAM 0x3D524.. at reset, and the widget',
           ' * records keep their live values (selected, onoff, page, window, data, ...: propdata letters',
           ' * m n o p q r s, the pBool .. pUlong property types) in these cells.  RAM_<cell> is the',
           ' * address a record\'s field holds; the cell\'s initial value is the C member of that name.']
    if not moved:
        out.append(' * v10 addresses; v7/v6/v5 compile v10\'s C and patch the bins (their *_c_divergence.json).')
    else:
        out += [' * %s addresses: the cell names are v10\'s, and each address is where %s\'s own' % (tree, tree),
                ' * Boot_InitWorkRAM puts that cell (gen_naka_gui_headers.py ram_mapper: the nearest label both',
                ' * trees define inside the image, symbols/maincpu_%s_symbols_reference.txt, or the tree\'s own' % tree,
                ' * `; work cell:` line for the cell, asm_cell_anchors).']
    out += [' */',
            '',
            '#ifndef NAKA_RAM_CELLS_H',
            '#define NAKA_RAM_CELLS_H',
            '']
    for n, a in cells:
        out.append('#define RAM_%-48s 0x%08Xu' % (n, f(a)) + (
            '  /* not in this tree\'s work-RAM image: no work-cell line of the tree is this cell */'
            if a in f.absent else ''))
    out += ['',
            '/* Cells of the image part the C does not spell (the asm\'s WorkRamInit_Image, RAM 0x3D524..0x3DCD3,',
            ' * and the second image, ROM 0xEEFA66 -> RAM 0xE35E): named after the widget field that keeps its',
            ' * live value there -- <record>_<Field>, the convention of the cells above',
            ' * (scripts/converters/name_widget_value_cells.py).  The evidence is that field: its class\'s',
            ' * propdata letter is a pointer type (m n o p q r s: pBool .. pUlong) and its value is the cell. */']
    for n, a in head:
        out.append('#define RAM_%-48s 0x%08Xu' % (n, f(a)))
    used = ram_vars_used(tree)
    if used:
        out += ['',
                '/* Main-CPU RAM variables that this tree\'s NAKA C names (sequencer edit parameters in the RAM',
                ' * address tables of naka_widget_descriptors.c, ...): the .equ of %s/maincpu/shared/' % tree,
                ' * ram_variables_by_use.s / ram_variables.s with that tree\'s value; their comments there say',
                ' * what the code shows each one is. */']
        for n, v in used:
            out.append('#define %-52s 0x%08Xu' % (n, v))
    out += ['', '#endif /* NAKA_RAM_CELLS_H */']
    return '\n'.join(out) + '\n'


def ram_vars_used(tree):
    """[(name, value)] of the tree's RAM .equ names (shared/ram_variables_by_use.s, ram_variables.s) that a
    word of its ui_widgets/*.c spells, sorted by value."""
    d = os.path.join(ROOT, tree, 'maincpu')
    equ = {}
    for f in ('ram_variables_by_use.s', 'ram_variables.s'):
        p = os.path.join(d, 'shared', f)
        if os.path.exists(p):
            for m in re.finditer(r'^\s*\.equ\s+(\w+),\s*0x([0-9A-Fa-f]+)', open(p, 'rb').read().decode('latin-1'), re.M):
                equ.setdefault(m.group(1), int(m.group(2), 16))
    words = set()
    for c in sorted(os.listdir(os.path.join(d, 'ui_widgets'))):
        if c.endswith('.c'):
            t = open(os.path.join(d, 'ui_widgets', c), 'rb').read().decode('latin-1')
            t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
            words |= set(re.findall(r'\b[A-Z][A-Z0-9_]+\b', t))
    return sorted(((n, v) for n, v in equ.items() if n in words), key=lambda x: (x[1], x[0]))


def head_cells(known_addr, known_names):
    """[(name, RAM address)] for the work-RAM cells outside naka_sequencer_channels.c that a widget
    record's pointer field names, from the v10 ROM records and the C member names."""
    import naka_gui_model as G
    m = O.Map('v10')
    members = {}
    for p in G.tree_files('v10'):
        f = G.CFile(p)
        for r in f.records:
            members[(r['slot'], r['elem'])] = r['member']
    first = {}
    for reg in m.regs:
        if reg['cls'] != 0x1600010 or not m.inrom(reg['table']):
            continue
        for k, ea in enumerate(m.entries(reg)):
            a = ea if m.inrom(ea) else G.rom_image_of(ea)
            c = m.record_class(a) if a is not None else None
            if not c:
                continue
            mem = members.get((reg['slot'], k))
            if not mem:
                lab = m.name_of(a)
                mem = lab[1] if lab[0] == a else None
            if not mem:
                continue
            for off, fname, ch in m.class_fields(c):
                if ch not in 'mnopqrs':
                    continue
                v = m.u32(a + off)
                if v in known_addr or G.rom_image_of(v) is None:
                    continue
                name = '%s_%s' % (mem, fname[:1].upper() + fname[1:])
                first.setdefault(v, name)
    out, used = [], set(known_names)
    for v in sorted(first):
        n = re.sub(r'[^A-Za-z0-9_]', '_', first[v])
        while n in used:
            n += '_'
        used.add(n)
        out.append((n, v))
    return out


def main():
    check = '--check' in sys.argv
    m = O.Map('v10')
    files = {'naka_classes.h': classes_h(m), 'naka_ids.h': ids_h(m)}
    cells = {t: ram_cells_h(t) for t in TREES}
    stale = 0
    asm = os.path.join(ROOT, 'hdae5000', 'shared', 'naka_values.s')
    text = values_s(m)
    cur = open(asm, encoding='latin-1').read() if os.path.exists(asm) else None
    if cur != text:
        if check:
            print('STALE: %s' % os.path.relpath(asm, ROOT))
            stale += 1
        else:
            open(asm, 'w', encoding='latin-1').write(text)
            print('wrote %s' % os.path.relpath(asm, ROOT))
    for t in TREES:
        for name, text in list(files.items()) + [('naka_ram_cells.h', cells[t])]:
            p = os.path.join(ROOT, t, 'maincpu', 'ui_widgets', name)
            cur = open(p, encoding='latin-1').read() if os.path.exists(p) else None
            if cur == text:
                continue
            if check:
                print('STALE: %s' % os.path.relpath(p, ROOT))
                stale += 1
            else:
                open(p, 'w', encoding='latin-1').write(text)
                print('wrote %s' % os.path.relpath(p, ROOT))
    if check:
        print('gen_naka_gui_headers: %s' % ('%d stale' % stale if stale else 'all copies up to date'))
        sys.exit(1 if stale else 0)


if __name__ == '__main__':
    main()
