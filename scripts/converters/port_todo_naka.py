#!/usr/bin/env python3
r"""Type the NAKA GUI objects inside a ported KN5000 tree's `; TODO(port)` byte rows.

QUESTION THIS ANSWERS
    scripts/converters/port_maincpu_version.py writes the bytes of a ported tree (v6, v5) that no line
    of the newer tree maps to as `.byte` rows under `; TODO(port): ...`; disassemble_port_todo.py and
    port_todo_typed.py then decode the code and spell the pointers to existing labels and the long
    strings.  Most of what is left (2026-11-06: about 2,000 of v6's 3,403 B and 2,500 of v5's 4,284 B)
    lies in the NAKA GUI objects the firmware registers itself: Viewable / ResName / Function name
    tables, widget records, class definitions, class property-name blocks and their strings.  Which of
    those row bytes are such objects, and does the image stay byte-identical when they are written as
    what they are?

THE EVIDENCE
    scripts/analysis/nakarest_objtab_map.py (Map) reads every `RegObjTabl` registration of the tree
    and, from the tree's own ROM, the tables they register, the widget records the Viewable tables
    point at (class = the record's first word), the strings the ResName / function-name tables point
    at, the Class tables' 24-byte class definitions and their name / propdata / propname blocks, and
    the strings the records' X fields point at.  An object is typed only where Map places one.

WHAT IT WRITES (in each run of rows; the labels, comments and blank lines inside a block stay put)
    * a whole widget record           -> `NAKA_REC_<Class> field=..., ...` (shared/naka_gui.s macros);
    * a field of a record or a class definition that the run holds but not the whole object (the
      other fields are lines of the newer tree) -> one `.long` / `.short` / `.byte` per field, the
      field's name in the comment; class definitions name their parent `NAKA_CLASS_<Class>`;
    * a registered table's entry, a pointer field of a record or class definition, a propname
      pointer -> `.long <target>`;
    * a string Map places (resource name, class name, propdata, propname, record text), or one any
      typed pointer points at -> `aligned_string "..."` / `.asciz "..."`;
    * any other 4 bytes whose value is the address of a label of the tree, of a Map object or of a
      string -> `.long <target>` (the same rule as port_todo_typed.py, with new labels).
    A pointer's target is its label; where it has none, a new label is placed (named from Map:
    NakaWidget_<screen>_<k>_<Class>, ResName_<screen>_<k>_<Class>, ClassName_<Class>,
    ClassPropdata_<Class>, ClassProps_<Class>, NakaClass_<Class>_PropName_<field>, ...); a target
    inside an `.incbin` slice, where no label can stand, is `<slice label> + <offset>`.  A new name
    never reuses a label of the source tree (v7 for v6, v6 for v5) or one the port dropped
    (port_dropped_labels.txt), so scripts/analysis/check_ported_labels.py reads it as new.
    Bytes nothing explains stay rows under the block's `; TODO(port)` line, still counted as debt.
    The tree is rebuilt; if the image is not byte-identical every file is restored.

RUN (repository root; the tree built: rebuilt_ROMs/kn5000_TREE_program.llvm.elf matches its dump)
    python3 scripts/converters/port_todo_naka.py --tree v6 [--dry-run] [--list]
    then python3 scripts/converters/naka_asm_records.py --tree v6 --gen  (IDX_ names of new labels)
    Idempotent: typed rows are not rows any more.
"""
import argparse
import bisect
import collections
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
for d in ("converters", "tools", "analysis", "generators"):
    sys.path.insert(0, os.path.join(ROOT, "scripts", d))
import port_maincpu_version as P        # noqa: E402
import port_symbolize_pointers as S     # noqa: E402
import nakarest_objtab_map as O         # noqa: E402
import naka_asm_records as R            # noqa: E402
import gen_naka_gui_headers as H        # noqa: E402

BASE, END = 0xE00000, 0x1000000
TODO = re.compile(r"^;\s*TODO\(port\)")
ROW = re.compile(r"^\t\.byte\t(0x[0-9a-f]{2}(?:, 0x[0-9a-f]{2}){0,7})\s*$")
KEEP = re.compile(r"^\s*$|^\s*;|^\s*(?:[A-Za-z_.$][\w.$]*\s*:\s*)+$")
LABEL_LINE = re.compile(r"^\s*((?:[A-Za-z_.$][\w.$]*\s*:\s*)+)$")
SRC = {"v6": "v7", "v5": "v6"}
STRING_KINDS = ("name", "classname", "classsig", "text", "msgstr", "sbgname", "sbsname", "sbtitle")
IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def text_of(bs):
    """bytes (no NUL) -> an .ascii operand"""
    out = []
    for b in bs:
        if b == 0x22:
            out.append('\\"')
        elif b == 0x5c:
            out.append("\\\\")
        elif 0x20 <= b < 0x7f:
            out.append(chr(b))
        else:
            out.append("\\%03o" % b)
    return '"' + "".join(out) + '"'


class Tree:
    def __init__(self, tree):
        self.tree = tree
        self.rom = open(os.path.join(ROOT, "original_ROMs", "kn5000_%s_program.rom" % tree), "rb").read()
        self.order, _, _ = P.tree_map(tree)
        self.size = P.fill_sizes([list(e) for e in self.order])
        self.addr = {(e[1], e[2]): e[0] for e in self.order if e[0] is not None}
        by_name, by_addr = S.elf_syms(tree)
        self.label_at = {a: n for a, n in by_addr.items() if BASE <= a < END}
        self.sorted_labels = sorted(self.label_at)
        self.used = set(by_name)
        src = SRC[tree]
        src_name, _ = S.elf_syms(src)
        self.src_name = {n: a for n, a in src_name.items() if BASE <= a < END}
        self.used |= set(src_name)
        # the source tree's address of a thing of this tree: by the nearest label both define
        self.pairs = sorted((by_name[n], a) for n, a in self.src_name.items() if n in by_name and BASE <= by_name[n] < END)
        self.pair_keys = [d for d, s_ in self.pairs]
        dl = os.path.join(ROOT, tree, "maincpu", "port_dropped_labels.txt")
        if os.path.exists(dl):
            self.used |= {ln.split("\t")[0].split()[0] for ln in open(dl, encoding="latin-1")
                          if ln.strip() and not ln.startswith("#")}
        # byte-emitting lines outside the TODO rows: address -> (rel, lineno) of the first one there
        self.line_start = {}
        for i, e in enumerate(self.order):
            if e[0] is not None and self.size[i] > 0 and not ROW.match(e[3]):
                self.line_start.setdefault(e[0], (e[1], e[2]))
        self.M = O.Map(tree)
        self.names = R.Names(tree, self.M)
        self.images = H.work_ram_images(tree, by_name)     # [(RAM dest, ROM source, size)]
        self._index_map()
        self._index_cells()
        self.new = {}                    # address -> new label
        self.taken = set(by_name)        # names this tree defines (or this run gave out)
        self.ext_labels = collections.defaultdict(list)   # (rel, lineno) -> labels to insert before

    # ------------------------------------------------------------------ Map
    def _index_map(self):
        M = self.M
        self.obj = collections.defaultdict(list)     # address -> [(kind, reg, k)]
        for a, lst in M.addr.items():
            if M.inrom(a):
                self.obj[a].extend(lst)
        self.containers = []                         # (start, end, kind, info)
        self.slot_ptr = {}                           # address of a pointer slot -> description
        self.strings = {}                            # address of a Map string -> kind
        self.ends = {}                               # empty string ending a name table -> its reg
        for a, lst in list(self.obj.items()):
            for kind, r, k in lst:
                if kind == "record":
                    c = M.record_class(a)
                    if c:
                        self.containers.append((a, a + c["allsize"], "record", (r, k, c)))
                elif kind == "classdef":
                    c = M.classes.get(((r["slot"] & 0xFFF) << 16) | k)
                    if c:
                        self.containers.append((a, a + 24, "classdef", c))
                elif kind == "table" and r["cls"] != 0x1600004:
                    n = r["count"]
                    for i in range(n):
                        self.slot_ptr[a + 4 * i] = ("table", r, i)
                    # name tables end with one more pointer, to an empty string
                    if r["cls"] == 0x160000F or r["slot"] >= 0x400:
                        e = M.u32(a + 4 * n)
                        if M.inrom(e) and M.u8(e) == 0:
                            self.slot_ptr.setdefault(a + 4 * n, ("end", r, n))
                            self.ends[e] = r
                elif kind == "propnames":
                    c = M.classes.get(((r["slot"] & 0xFFF) << 16) | k)
                    if c:
                        for i in range(c["pn_count"]):
                            p = a + 4 * i
                            self.slot_ptr[p] = ("propname", c, i)
                            t = M.u32(p)
                            if M.inrom(t):
                                self.strings.setdefault(t, ("propname", c, i))
                elif kind in STRING_KINDS:
                    self.strings.setdefault(a, (kind, r, k))
        self.containers.sort()
        self.cstarts = [c[0] for c in self.containers]

    def image_of(self, a):
        """the ROM byte a work-RAM address is initialised from, or None"""
        for d, r, n in self.images:
            if d <= a < d + n:
                return a - d + r
        return None

    def _index_cells(self):
        """the work-RAM cells this tree's own records point at: ROM image address -> (size, owner).
        A record field whose propdata letter is a RAM pointer (m n o p q r s) holds the RAM address of
        the cell with its live value; Boot_InitWorkRAM fills the cell from the image.  Size: a view id
        (letter r: window / parent / child) and an AcRamBox / AcRamEditBox value are 32-bit, the rest
        16-bit, as in the newer trees' C (naka_sequencer_channels.c work-cell structs)."""
        M = self.M
        self.cells = {}
        for a, lst in list(M.addr.items()):
            for kind, r, k in lst:
                if kind != "record":
                    continue
                ra = a if M.inrom(a) else self.image_of(a)
                if ra is None:
                    continue
                c = M.record_class(ra)
                if not c:
                    continue
                if not M.inrom(a):
                    self.containers.append((ra, ra + c["allsize"], "record", (r, k, c)))
                    self.obj[ra].append(("record", r, k))
                lab = self.label_at.get(ra) or "%s element %d" % (self.screen_name(r["slot"]), k)
                for off, fname, ch in M.class_fields(c):
                    if ch not in "mnopqrs":
                        continue
                    v = M.u32(ra + off)
                    img = self.image_of(v)
                    if img is None:
                        continue
                    big = ch == "r" or (c["name"] in ("AcRamBox", "AcRamEditBox") and fname == "data")
                    self.cells.setdefault(img, (4 if big else 2, "%s %s (%s)" % (lab, fname, c["name"])))
        self.containers.sort()
        self.cstarts = [c[0] for c in self.containers]

    def in_image(self, p):
        return any(r <= p < r + n for d, r, n in self.images)

    def container_at(self, a):
        i = bisect.bisect_right(self.cstarts, a) - 1
        while i >= 0:
            s, e, kind, info = self.containers[i]
            if s <= a < e:
                return self.containers[i]
            if e <= a and s < a - 0x400:
                break
            i -= 1
        return None

    def screen_name(self, slot):
        rn = self.M.by_slot.get(slot + 0x300)
        if rn:
            ents = self.M.entries(rn)
            if ents and self.M.inrom(ents[0]):
                s = self.M.string_at(ents[0])
                if IDENT.match(s or ""):
                    return s
        return "Slot%02X" % slot

    def element_name(self, slot, k):
        rn = self.M.by_slot.get(slot + 0x300)
        if rn:
            ents = self.M.entries(rn)
            if k < len(ents) and self.M.inrom(ents[k]):
                s = self.M.string_at(ents[k])
                if IDENT.match(s or ""):
                    return s
        return None

    def element_class(self, slot, k):
        r = self.M.by_slot.get(slot)
        if r:
            ents = self.M.entries(r)
            if k < len(ents):
                a = ents[k]
                c = self.M.record_class(a) if self.M.inrom(a) else None
                if c:
                    return c["name"]
        return "Obj"

    # --------------------------------------------------------------- names
    def src_addr(self, t):
        j = bisect.bisect_right(self.pair_keys, t) - 1
        return t - self.pairs[j][0] + self.pairs[j][1] if j >= 0 else None

    def unique(self, name, t=None):
        n, k = name, 2
        while n in self.used:
            # the source tree's name for the same thing (v6's new label, in v5) is the name
            if t is not None and n in self.src_name and n not in self.taken and self.src_addr(t) == self.src_name[n]:
                break
            n, k = "%s_%d" % (name, k), k + 1
        self.used.add(n)
        self.taken.add(n)
        return n

    def pointer_hint(self, p, t):
        """a name for the target t of a pointer at p that Map does not explain: entry k of the table
        the nearest label before p starts"""
        i = bisect.bisect_right(self.sorted_labels, p) - 1
        if i < 0:
            return None
        la = self.sorted_labels[i]
        txt = self.string_len(t, t + 256, False) > 0 or self.rom[t - BASE:t - BASE + 2] == b"\x00\xff"
        return "%s_%s%d" % (self.label_at[la], "Str" if txt else "Item", (p - la) // 4)

    def name_for(self, t, hint=None):
        """a new label for address t, from what Map says is there (or what points at it)"""
        M = self.M
        for kind, r, k in self.obj.get(t, []):
            if kind == "record":
                c = M.record_class(t)
                own = self.element_name(r["slot"], k)
                if own:
                    return "NakaWidget_" + own
                return "NakaWidget_%s_%d_%s" % (self.screen_name(r["slot"]), k, c["name"] if c else "Obj")
            if kind == "name":
                if r["cls"] == 0x160000F and r["slot"] >= 0x300:
                    vs = r["slot"] - 0x300
                    s = M.string_at(t)
                    if IDENT.match(s or ""):
                        return "ResName_%s" % s
                    return "ResName_%s_%d_%s" % (self.screen_name(vs), k, self.element_class(vs, k))
                s = M.string_at(t)
                if IDENT.match(s or ""):
                    return "FuncNameStr_%s" % s
                return "FuncName_%03X_%d" % (r["slot"], k)
            if kind in ("classname", "classsig", "propnames"):
                c = M.classes.get(((r["slot"] & 0xFFF) << 16) | k)
                pre = {"classname": "ClassName_", "classsig": "ClassPropdata_", "propnames": "ClassProps_"}[kind]
                return pre + (c["name"] if c else "%03X_%d" % (r["slot"], k))
            if kind == "text":
                cn, fn, kk = M.text_field.get(t, [("Obj", "str", k)])[0]
                return "NakaText_%s_%d_%s" % (self.screen_name(r["slot"]), k, fn)
        if t in self.ends:
            r = self.ends[t]
            tl = self.label_at.get(r["table"])
            return (tl or "NameTable_%03X" % r["slot"]) + "_EndStr"
        st = self.strings.get(t)
        if st and st[0] == "propname":
            c, i = st[1], st[2]
            f = c["fields"][i] if i < len(c["fields"]) and c["fields"][i] else "End"
            return "NakaClass_%s_PropName_%s" % (c["name"], re.sub(r"\W", "_", f) or "End")
        if hint:
            return hint
        return None

    def spell_target(self, t, allow_offset, hint=None):
        """a symbolic spelling of ROM address t, placing a new label if needed; None if none"""
        if t in self.label_at:
            return self.label_at[t]
        if t in self.new:
            return self.new[t]
        in_run = self.run_at(t)
        if in_run or t in self.line_start:
            nm = self.name_for(t, hint)
            if nm is None:
                nm = "%s_Target" % self.enclosing(t)
            nm = self.unique(nm, t)
            self.new[t] = nm
            if not in_run:
                self.ext_labels[self.line_start[t]].append(nm)
            return nm
        if allow_offset:
            i = bisect.bisect_right(self.sorted_labels, t) - 1
            if i >= 0 and t - self.sorted_labels[i] < 0x1000:
                b = self.sorted_labels[i]
                return "%s + %d" % (self.label_at[b], t - b)
        return None

    def enclosing(self, a):
        i = bisect.bisect_right(self.sorted_labels, a) - 1
        return P.label_stem(self.label_at[self.sorted_labels[i]]) if i >= 0 else "Rom"

    # ------------------------------------------------------------- runs
    def run_at(self, t):
        i = bisect.bisect_right(self.run_starts, t) - 1
        return i >= 0 and self.runs[i][0] <= t < self.runs[i][0] + len(self.runs[i][1])

    def plausible(self, t):
        """a generic pointer's target: a label, a Map object or string, or text a run or a line holds"""
        if t in self.label_at or t in self.obj or t in self.strings:
            return True
        if not (BASE <= t < END):
            return False
        o = t - BASE
        if not (self.run_at(t) or t in self.line_start):
            # inside an .incbin slice: only the start of a string (after a NUL or its 0xff pad)
            return self.rom[o - 1] in (0, 0xff) and self.string_len(t, t + 256, False) > 0
        if t % 2 == 0 and self.rom[o:o + 2] == b"\x00\xff":
            return True
        j = o
        while j < len(self.rom) and 0x20 <= self.rom[j] < 0x7f:
            j += 1
        return j > o and self.rom[j] == 0

    def string_len(self, t, end, any_byte):
        """byte length of the NUL-terminated string at t (+ the 0xff pad when the NUL ends on an
        odd address and 0xff follows), if it ends before end; 0 if not text.  any_byte: Map says
        a string is there (LCD glyph codes are text); else printable ASCII only."""
        o = j = t - BASE
        while j < end - BASE and self.rom[j] != 0:
            if not any_byte and not 0x20 <= self.rom[j] < 0x7f:
                return 0
            j += 1
        if j >= end - BASE:
            return 0
        n = j + 1 - o
        if (t + n) & 1 and t + n < end and self.rom[t + n - BASE] == 0xff:
            n += 1
        return n

    def collect_runs(self):
        """every block's runs of rows: [(start, bytes, rel, [line numbers])]"""
        self.blocks = []
        self.runs = []
        for path in S.tree_files(self.tree):
            rel = os.path.relpath(path, os.path.join(ROOT, self.tree, "maincpu"))
            L = S.rd(path).split("\n")
            i = 0
            while i < len(L):
                if not TODO.match(L[i]):
                    i += 1
                    continue
                j = i + 1
                items = []
                while j < len(L) and (ROW.match(L[j]) or KEEP.match(L[j]) and not TODO.match(L[j])):
                    m = ROW.match(L[j])
                    if m:
                        items.append(("row", self.addr.get((rel, j + 1)),
                                      bytes(int(x, 16) for x in m.group(1).split(", ")), j))
                    else:
                        items.append(("line", None, L[j], j))
                    j += 1
                self.blocks.append((path, rel, i, j, items))
                for kind, a, bs, ln in items:
                    if kind == "row" and a is not None:
                        if self.runs and self.runs[-1][0] + len(self.runs[-1][1]) == a:
                            self.runs[-1] = (self.runs[-1][0], self.runs[-1][1] + bs)
                        else:
                            self.runs.append((a, bs))
                i = j
        self.runs.sort()
        self.run_starts = [r[0] for r in self.runs]

    # ----------------------------------------------------------- spelling
    def field_value(self, slot, ch, v, n, allow_offset=True):
        if n == 4 and BASE <= v < END:
            sp = self.spell_target(v, allow_offset)
            if sp:
                return sp
        return R.value(self.names, slot, ch, v, n)

    def record_call(self, a, r, k, c):
        """R.record_call with this tool's pointer spelling (new labels, `Label + off`)"""
        M = self.M
        fl, size = H.class_layout(M, c)
        args, off = [], 0
        for o, f, n, ch in fl:
            if o > off:
                if M.u8(a + off):
                    args.append("pad_%d=0x%x" % (off, M.u8(a + off)))
                if any(M.u8(a + x) for x in range(off + 1, o)):
                    return None
                off = o
            if ch == "M":
                pass
            elif ch == "P":
                x1, y1, x2, y2 = (int.from_bytes(self.rom[a + o + 2 * i - BASE:a + o + 2 * i + 2 - BASE], "little",
                                                 signed=True) for i in range(4))
                args += ["x=%d" % x1, "y=%d" % y1, "w=%d" % (x2 - x1 + 1), "h=%d" % (y2 - y1 + 1)]
            else:
                v = {1: M.u8, 2: M.u16, 4: M.u32}[n](a + o)
                args.append("%s=%s" % (f, self.field_value(r["slot"], ch, v, n)))
            off = o + n
        if off < size:
            if M.u8(a + off):
                args.append("pad_%d=0x%x" % (off, M.u8(a + off)))
            if any(M.u8(a + x) for x in range(off + 1, size)):
                return None
        return "\tNAKA_REC_%s %s" % (c["name"], ", ".join(args))

    def fields(self, cont):
        """[(offset, size, name, spell(v))] of a container"""
        s, e, kind, info = cont
        if kind == "record":
            r, k, c = info
            fl, size = H.class_layout(self.M, c)
            out = []
            for o, f, n, ch in fl:
                if ch == "M":
                    out.append((o, 4, "class", lambda v, c=c: "NAKA_CLASS_%s" % c["name"]))
                elif ch == "P":
                    out.append((o, 8, "rect (x1, y1, x2, y2)", None))
                else:
                    out.append((o, n, f, lambda v, ch=ch, n=n, r=r: self.field_value(r["slot"], ch, v, n)))
            return out
        c = info

        def parent(v):
            pc = self.M.klass(v) if v not in (0xFFFFFFFF,) else None
            return "NAKA_CLASS_%s" % pc["name"] if pc else "0x%x" % v
        ptr = lambda v: self.field_value(0, "X", v, 4)              # noqa: E731
        return [(0, 4, "proc", ptr), (4, 4, "parent", parent), (8, 2, "allsize", str), (10, 2, "selfsize", str),
                (12, 4, "name", ptr), (16, 4, "propdata", ptr), (20, 4, "propname", ptr)]

    def type_run(self, a, bs, cuts):
        """-> [(address, length, line or None)] covering a..a+len(bs); None = stays a row.
        cuts: sorted addresses no item may straddle (a label must stand there)."""
        end = a + len(bs)

        def fits(p, n):
            if p + n > end:
                return False
            i = bisect.bisect_right(cuts, p)
            return i >= len(cuts) or cuts[i] >= p + n
        out = []
        p = a
        while p < end:
            u32 = int.from_bytes(self.rom[p - BASE:p - BASE + 4], "little") if p + 4 <= end else None
            cont = self.container_at(p)
            if cont and cont[0] == p and cont[2] == "record" and fits(p, cont[1] - p):
                r, k, c = cont[3]
                ln = self.record_call(p, r, k, c)
                if ln:
                    out.append((p, cont[1] - p, ln))
                    p = cont[1]
                    continue
            if cont:
                done = False
                for o, n, fname, sp in self.fields(cont):
                    if cont[0] + o == p and fits(p, n):
                        if sp is None:
                            vals = [int.from_bytes(self.rom[p + 2 * i - BASE:p + 2 * i + 2 - BASE], "little", signed=True)
                                    for i in range(4)]
                            out.append((p, n, "\t.short\t%d, %d, %d, %d\t; %s" % (*vals, fname)))
                        else:
                            v = int.from_bytes(self.rom[p - BASE:p - BASE + n], "little")
                            d = {1: ".byte", 2: ".short", 4: ".long"}[n]
                            what = "%s %s" % (cont[3][2]["name"] if cont[2] == "record" else cont[3]["name"], fname)
                            out.append((p, n, "\t%s\t%s\t; %s" % (d, sp(v), what)))
                        p += n
                        done = True
                        break
                if done:
                    continue
            if p in self.cells and fits(p, self.cells[p][0]):
                n, owner = self.cells[p]
                v = int.from_bytes(self.rom[p - BASE:p - BASE + n], "little")
                out.append((p, n, "\t%s\t0x%x\t; work cell: %s" % (".long" if n == 4 else ".short", v, owner)))
                p += n
                continue
            if self.in_image(p) and p % 2 == 0 and fits(p, 2) and p + 1 not in self.cells:
                v = int.from_bytes(self.rom[p - BASE:p - BASE + 2], "little")
                out.append((p, 2, "\t.short\t0x%x\t; work cell no record of this tree points at" % v))
                p += 2
                continue
            if p in self.slot_ptr and u32 is not None and fits(p, 4):
                desc = self.slot_ptr[p]
                hint = self.pointer_hint(p, u32) if u32 is not None and BASE <= u32 < END else None
                sp = self.spell_target(u32, True, hint) if BASE <= u32 < END else None
                if sp is None and desc[0] == "table" and u32 < BASE:
                    sp = "0x%x" % u32
                    out.append((p, 4, "\t.long\t%s\t; RAM: the work-RAM copy of element %d" % (sp, desc[2])))
                    p += 4
                    continue
                if sp:
                    out.append((p, 4, "\t.long\t%s" % sp))
                    p += 4
                    continue
            if (p in self.strings or p in self.ends or p in self.new or self.is_pointed(p)) and not self.in_image(p):
                n = self.string_len(p, end, p in self.strings)
                if n and fits(p, n):
                    o = p - BASE
                    raw = self.rom[o:o + n]
                    txt = raw[:raw.index(0)]
                    if n > len(txt) + 1:
                        out.append((p, n, "\taligned_string %s" % text_of(txt)))
                    else:
                        out.append((p, n, "\t.asciz\t%s" % text_of(txt)))
                    p += n
                    continue
            if u32 is not None and fits(p, 4) and self.plausible(u32):
                sp = self.spell_target(u32, not (self.run_at(u32) or u32 in self.line_start),
                                       self.pointer_hint(p, u32))
                if sp:
                    out.append((p, 4, "\t.long\t%s" % sp))
                    p += 4
                    continue
            out.append((p, 1, None))
            p += 1
        return out

    def is_pointed(self, p):
        return p in self.targets

    def plan(self):
        """pass 1: every pointer the runs hold that names a plausible target, so strings they point
        at are typed as strings"""
        self.targets = set()
        for a, bs in self.runs:
            for i in range(len(bs) - 3):
                v = int.from_bytes(bs[i:i + 4], "little")
                if BASE <= v < END and (a + i in self.slot_ptr or self.plausible(v)):
                    self.targets.add(v)
        # pointers anywhere in the image (the C slices, the lines of the newer tree) into the runs
        rom = self.rom
        want = set()
        for a, bs in self.runs:
            want.update(range(a, a + len(bs)))
        for o in range(0, len(rom) - 3):
            if rom[o + 3] == 0 and rom[o + 2] >= 0xE0:
                v = rom[o] | rom[o + 1] << 8 | rom[o + 2] << 16
                if v in want:
                    self.targets.add(v)
        for p, d in self.slot_ptr.items():
            if self.run_at(p):
                v = self.M.u32(p)
                if BASE <= v < END:
                    self.targets.add(v)


def rows_text(marker, bs):
    return [marker] + ["\t.byte\t" + ", ".join("0x%02x" % b for b in bs[k:k + 8]) for k in range(0, len(bs), 8)]


def convert(tree, listing=False):
    T = Tree(tree)
    T.collect_runs()
    T.plan()
    # each block as a sequence: ('bytes', addr, bytes, {addr: [comment lines]}) runs, split only at
    # label lines; ('line', text) for those labels and for lines no run surrounds
    per_block = []
    for path, rel, i, j, items in T.blocks:
        seq, pending = [], []
        for kind, a, x, ln in items:
            if kind == "row" and a is not None:
                if seq and seq[-1][0] == "bytes" and seq[-1][1] + len(seq[-1][2]) == a:
                    seq[-1][3].setdefault(a, []).extend(pending)
                    seq[-1] = ("bytes", seq[-1][1], seq[-1][2] + x, seq[-1][3])
                else:
                    seq.append(("bytes", a, x, {a: pending}))
                pending = []
            elif kind == "row":
                seq += [("line", None, t, None) for t in pending] + [("raw", None, x, None)]
                pending = []
            elif LABEL_LINE.match(x):
                seq += [("line", None, t, None) for t in pending] + [("line", None, x, None)]
                pending = []
            else:
                pending.append(x)
        seq += [("line", None, t, None) for t in pending]
        per_block.append((path, rel, i, j, seq))
    # type every run; a new label inside a typed item forces a cut there, and the runs are typed again
    cuts = set()
    for _ in range(8):
        results = []
        starts = set()
        cl = sorted(cuts)
        for path, rel, i, j, seq in per_block:
            res = []
            for kind, a, x, com in seq:
                if kind == "bytes":
                    its = T.type_run(a, x, cl)
                    starts |= {p for p, n, ln in its}
                    res.append((kind, a, x, com, its))
                else:
                    res.append((kind, a, x, com, None))
            results.append((path, rel, i, j, res))
        bad = {t for t in T.new if T.run_at(t) and t not in starts}
        if not bad - cuts:
            break
        cuts |= bad
    out_files, edits = {}, collections.defaultdict(list)
    typed = left = 0
    for path, rel, i, j, res in results:
        L = out_files.setdefault(path, S.rd(path).split("\n"))
        marker = L[i]
        new = []
        for kind, a, x, com, items in res:
            if kind == "line":
                new.append(x)
                continue
            if kind == "raw":
                new += rows_text(marker, x)
                left += len(x)
                continue
            pend = []

            def flush():
                nonlocal pend, left
                if pend:
                    new.extend(rows_text(marker, bytes(pend)))
                    left += len(pend)
                    pend = []
            for p, n, ln in items:
                lead = [c for q in sorted(com) if p <= q < p + n for c in com[q]]
                if p in T.new or lead:
                    flush()
                new.extend(lead)
                if p in T.new:
                    new.append(T.new[p] + ":")
                if ln is None:
                    pend.append(T.rom[p - BASE])
                    continue
                flush()
                new.append(ln)
                typed += n
            flush()
        if new != L[i:j]:
            edits[path].append((i, j, new))
    for (rel, lineno), labs in T.ext_labels.items():
        path = os.path.join(ROOT, tree, "maincpu", rel)
        out_files.setdefault(path, S.rd(path).split("\n"))
        edits[path].append((lineno - 1, lineno - 1, [x + ":" for x in labs]))
    files = {}
    for path, ed in edits.items():
        L = out_files[path]
        for i, j, new in sorted(ed, key=lambda e: (e[0], e[1]), reverse=True):
            L[i:j] = new
        files[path] = "\n".join(L)
    if listing:
        for t, nm in sorted(T.new.items()):
            print("  new label %06x %s" % (t, nm))
    return files, typed, left, T


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True, choices=("v6", "v5"))
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--list", action="store_true")
    a = ap.parse_args()
    files, t, l_, T = convert(a.tree, a.list)
    print("%s: %d bytes typed as NAKA objects / pointers / strings, %d left as TODO(port) rows, %d new labels, %d files"
          % (a.tree, t, l_, len(T.new), len(files)))
    if a.dry_run or not files:
        return
    backup = {p: S.rd(p) for p in files}
    for p, s in files.items():
        S.wr(p, s)
    ok, err = S.build_ok(a.tree)
    if not ok:
        for p, s in backup.items():
            S.wr(p, s)
        S.build_ok(a.tree)
        sys.exit("not byte-identical; files restored\n" + err)
    print("%s: byte-identical" % a.tree)


if __name__ == "__main__":
    main()
