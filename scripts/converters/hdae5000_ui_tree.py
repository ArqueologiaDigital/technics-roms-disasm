#!/usr/bin/env python3
r"""hdae5000_ui_tree.py -- write the HD-AE5000 GUI as a nested tree of NAKA objects.

QUESTION ANSWERED / JOB IT DOES
-------------------------------
The HD-AE5000's UI is one NAKA Viewable table (object table 0x7F, 789 objects in
v2.06i, 786 in v2.01i): a pointer table, a parallel name table, a pool of
variable-length object records in ROM, 20 more records in the initialised .data
image (copied to RAM), and the RAM variables those records point at.  Until this
script the pool was written record by record with raw class ids, numeric
parent / child / sibling indices and undecoded "class body" words.

This converter rewrites all of it from the ROM image, once, into the form the
macros of hdae5000/shared/naka_ui_macros.s assemble:

  * one macro per NAKA class (`AcScreenMenu`, `TtlScreenR`, `Label`, ...), whose
    parameters are the class chain's own field names (propname) -- the firmware
    describes its own records, see THE CLASS SYSTEM in
    scripts/analysis/nakarest_objtab_map.py;
  * the object tree as NESTING: `ui_sub` / `ui_endsub` around the children of an
    object.  The macros compute every object index and every super / sub / next /
    prev link from that nesting (the table is the preorder walk of a forest, for
    both versions, with no exception -- notes/data-gui-hdae5000-2026-10-29/);
  * the geometry as x / y / w / h, class ids by name, captions inline, strings
    elsewhere by label, object ids as HDAE5000_OBJ_<name>, function ids as
    NAKA_APFUNC_ / NAKA_MAINFUNC_ names, title ids as TITLE_*, RAM variables by
    the label of their initial value in the .data image;
  * the object table, the name table and the RAM-object pointers generated from
    the tree (`ui_object_table`, `ui_name_table`).

It writes, per tree (hdae5000/ = v2.06i, hdae5000_v2_01i/ = v2.01i):
    <tree>/hdae5000_ui_tree.s        the tree, the two tables and the name pool
    hdae5000/shared/naka_ui_macros.s the class macros (union of both versions)
and splices `.include "hdae5000_ui_tree.s"` into <tree>/hdae5000_data_tables.s in
place of the old pool / table / name-pool section, and rewrites the run-time
state block and the 20 RAM-object records of <tree>/hdae5000_init_data.s.

It REFUSES (exit 1) unless its byte model of everything it writes equals the ROM;
`make gate` (the assembler) is the final word.

RUN (from the repo root, on a built tree: it reads the current ELF's labels)
    python3 scripts/converters/hdae5000_ui_tree.py v2_06i            # check only
    python3 scripts/converters/hdae5000_ui_tree.py v2_06i --write
    python3 scripts/converters/hdae5000_ui_tree.py v2_01i --write
    python3 scripts/converters/hdae5000_ui_tree.py --macros          # rewrite the macro file
Needs rebuilt_ROMs/kn5000_v10_program.llvm.elf (host class definitions) and the
HD-AE5000 ELF of the version.
"""
import collections
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "analysis"))
import nakarest_objtab_map as nakamap  # noqa: E402

LLVM = os.path.expanduser("~/compartilhado/llvm-project/build/bin")
BASE = 0x280000
SIG_SIZE = nakamap.SIG_SIZE
VERSIONS = {
    "v2_06i": dict(tree="hdae5000", elf="hd-ae5000_v2_06i", tag="v2.06i"),
    "v2_01i": dict(tree="hdae5000_v2_01i", elf="hd-ae5000_v2_01i", tag="v2.01i"),
}
MACROS = os.path.join(ROOT, "hdae5000", "shared", "naka_ui_macros.s")
NONE = 0xFFFF
NO_OBJECT = 0xFFFFFFFF
# field type letters (propdata) and how a value of that type is spelled
T_STR = "X"             # pointer to a string
T_RAMVAR = "mnrs"        # pointer to a RAM variable (all into the .data image copy)
T_OBJ = "Nt"             # object id: screen (N), window (t)
T_TITLE = "a"            # title id
T_FUNC = "jk"            # ApFunction (j) / MainFunction (k) id
TYPE_WORD = {"m": "RAM variable", "n": "RAM variable", "r": "RAM variable", "s": "RAM variable",
             "N": "screen object id", "t": "window object id", "a": "title id",
             "j": "ApFunction id", "k": "MainFunction id", "X": "string",
             "c": "font id", "^": "colour", "_": "border", "b": "icon id", "d": "alignment",
             "e": "edit-switch number", "f": "style", "g": "line mode", "G": "boolean",
             "A": "number", "B": "number", "C": "byte"}


def fail(msg):
    sys.exit("REFUSED: " + msg)


def nm_syms(elf):
    out = subprocess.run([os.path.join(LLVM, "llvm-nm"), "--defined-only", elf],
                         capture_output=True, text=True, check=True).stdout
    sym, absy = {}, {}
    for ln in out.split("\n"):
        f = ln.split()
        if len(f) == 3:
            (absy if f[1] in "aA" else sym)[f[2]] = int(f[0], 16)
    return sym, absy


def esc(bs):
    out = []
    for c in bs:
        if c == 0x22:
            out.append('\\"')
        elif c == 0x5C:
            out.append("\\\\")
        elif 0x20 <= c < 0x7F:
            out.append(chr(c))
        else:
            out.append("\\%03o" % c)
    return '"' + "".join(out) + '"'


def ident(s):
    s = re.sub(r"[^A-Za-z0-9]+", "_", s).strip("_")
    return s


# --------------------------------------------------------------------- model
class HostClasses:
    """The main CPU's class definitions (v10 ELF + ROM), for the 0x016S classes S < 0xA."""
    def __init__(self):
        self.m = nakamap.Map("v10")

    def get(self, cid):
        return self.m.klass(cid)


class Version:
    def __init__(self, ver, host):
        self.ver = ver
        cfg = VERSIONS[ver]
        self.tree = os.path.join(ROOT, cfg["tree"])
        self.tag = cfg["tag"]
        self.rom = open(os.path.join(ROOT, "original_ROMs", "hd-ae5000_%s.ic4" % ver), "rb").read()
        elf = os.path.join(ROOT, "rebuilt_ROMs", "%s.llvm.elf" % cfg["elf"])
        self.sym, self.abs = nm_syms(elf)
        self.addr2sym = collections.defaultdict(list)
        for k, v in self.sym.items():
            self.addr2sym[v].append(k)
        self.host = host
        S = self.sym
        self.img = S["HDAE5000_DataSegmentImage"]
        self.img_end = S["HDAE5000_Init_Data_End"]
        # the copy destination: hdae5000_ui_display.s's copy loop, `ld xde, <dest>` (0x2394ce
        # v2.01i, 0x23952a v2.06i); read from the RAM pointer of the first RAM object below
        self.ptrtab = S["HDAE5000_UiObject_PtrTable"]
        self.nametab = S["HDAE5000_UiObjectName_PtrTable"]
        self.state = S["HDAE5000_WindowState_Init"]
        self.geom = S["HDAE5000_WindowGeometry_Init"]
        self.geom_end = S["HDAE5000_ScreenProc_Table"]
        n = 0
        while self.u32(self.ptrtab + 4 * n):
            n += 1
        self.nobj = n
        self.ptr = [self.u32(self.ptrtab + 4 * i) for i in range(n)]
        self.nptr = [self.u32(self.nametab + 4 * i) for i in range(n + 1)]
        self.rname = [self.cstr(a).decode("latin-1") for a in self.nptr]
        ram = [p for p in self.ptr if p < BASE]
        # first RAM record is 8 bytes after the WindowGeometry_Init label (four 0xffff words)
        self.ramb = min(ram) - (self.geom + 8 - self.img)
        self.load_classes()
        self.load_objects()

    # raw access
    def u8(self, a):
        return self.rom[a - BASE]

    def u16(self, a):
        return int.from_bytes(self.rom[a - BASE:a - BASE + 2], "little")

    def u32(self, a):
        return int.from_bytes(self.rom[a - BASE:a - BASE + 4], "little")

    def cstr(self, a):
        b = self.rom[a - BASE:]
        return b[:b.index(0)]

    def ram2rom(self, p):
        return p - self.ramb + self.img

    def in_img_ram(self, p):
        return self.ramb <= p < self.ramb + (self.img_end - self.img)

    def load_classes(self):
        S = self.sym
        rt, n = S["HDAE5000_RECORD_TABLE"], self.u16(S["HDAE5000_RECORD_COUNT"])
        self.hd = {}
        for k in range(n):
            a = rt + 24 * k
            c = dict(proc=self.u32(a), parent=self.u32(a + 4), allsize=self.u16(a + 8),
                     selfsize=self.u16(a + 10), name=self.cstr(self.u32(a + 12)).decode(),
                     sig=self.cstr(self.u32(a + 16)).decode(), pn=self.u32(a + 20))
            pl = self.ram2rom(c["pn"])
            c["fields"] = [self.cstr(self.u32(pl + 4 * i)).decode() for i in range(len(c["sig"]) + 1)]
            self.hd[0x016A0000 | k] = c

    def klass(self, cid):
        return self.hd.get(cid) or self.host.get(cid)

    def class_layout(self, cid):
        """(name, allsize, [(off, field, letter)], chain names)"""
        chain, c = [], cid
        while c not in (NO_OBJECT, 0x01600000):
            k = self.klass(c)
            if k is None:
                fail("class 0x%08x unknown" % c)
            chain.append(k)
            c = k["parent"]
        fields, off = [], 0
        for k in reversed(chain):
            for ch, name in zip(k["sig"], k["fields"]):
                fields.append((off, name, ch))
                off += SIG_SIZE[ch]
        if off != chain[0]["allsize"]:
            fail("class 0x%08x: fields sum to %d, allsize %d" % (cid, off, chain[0]["allsize"]))
        return chain[0]["name"], chain[0]["allsize"], fields, [k["name"] for k in chain]

    def load_objects(self):
        n = self.nobj
        pool = sorted(p for p in self.ptr if p >= BASE)
        pool_end = self.ptrtab
        nxt = {p: q for p, q in zip(pool, pool[1:] + [pool_end])}
        ramp = sorted(p for p in self.ptr if p < BASE)
        self.pool, self.pool_end = pool[0], pool_end
        objs = []
        for i, p in enumerate(self.ptr):
            o = dict(i=i, p=p, ram=p < BASE, rname=self.rname[i])
            a = self.ram2rom(p) if o["ram"] else p
            o["a"] = a
            o["cid"] = self.u32(a)
            o["cname"], o["allsize"], o["fields"], o["chain"] = self.class_layout(o["cid"])
            if o["ram"]:
                k = ramp.index(p)
                o["end"] = self.ram2rom(ramp[k + 1]) if k + 1 < len(ramp) else a + o["allsize"]
            else:
                o["end"] = nxt[p]
            o["super"], o["sub"], o["next"], o["prev"] = (self.u16(a + 4), self.u16(a + 6),
                                                          self.u16(a + 8), self.u16(a + 10))
            objs.append(o)
        self.objs = objs
        # the tree must be the preorder of a forest whose indices are the table order
        order = []

        def walk(i, d):
            order.append(i)
            objs[i]["depth"] = d
            c = objs[i]["sub"]
            while c != NONE:
                walk(c, d + 1)
                c = objs[c]["next"]
        for o in objs:
            if o["super"] == NONE:
                walk(o["i"], 0)
        if order != list(range(n)):
            fail("the object table is not the preorder walk of its tree")
        for o in objs:
            if o["super"] == NONE and (o["next"] != NONE or o["prev"] != NONE):
                fail("root #%d has siblings" % o["i"])
        self.name_objects()

    def name_objects(self):
        """Symbol names: the firmware's own resource name where the name table has one,
        otherwise <named or titled ancestor>_<caption or class>."""
        used = collections.Counter()
        objs = self.objs
        for o in objs:
            if o["rname"]:
                if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", o["rname"]):
                    fail("object #%d name %r is not a symbol" % (o["i"], o["rname"]))
                used[o["rname"]] += 1
        dup = [k for k, v in used.items() if v > 1]
        if dup:
            fail("duplicate object names %s" % dup)
        taken = set(used)
        for o in objs:
            if o["rname"]:
                o["name"] = o["rname"]
                continue
            par = objs[o["super"]]["name"] if o["super"] != NONE else "Root"
            cap = ""
            for off, fn, ch in o["fields"]:
                if ch == T_STR:
                    v = self.u32(o["a"] + off)
                    if o["a"] <= v < o["end"]:
                        cap = ident(self.cstr(v).decode("latin-1"))
                        if cap:
                            break
            role = cap[:24] if cap else self.role(o)
            base = "%s_%s" % (par, role)
            if len(base) > 60:
                base = "%s_%s" % (par.split("_")[0], role)
            nm, k = base, 2
            while nm in taken:
                nm, k = "%s_%d" % (base, k), k + 1
            taken.add(nm)
            o["name"] = nm

    def role(self, o):
        """A name for an uncaptioned object from what it does: the firmware-named object
        it opens or switches to, its language-text entry, its page, or else its class."""
        flds = {fn: (off, ch) for off, fn, ch in o["fields"]}
        for fn in ("screen", "window"):
            if fn in flds and flds[fn][1] in T_OBJ:
                val = self.u32(o["a"] + flds[fn][0])
                if val >> 16 == 0x007F and (val & 0xFFFF) < self.nobj:
                    t = self.objs[val & 0xFFFF]["rname"]
                    if t:
                        verb = {"IvExitScreen": "Exit", "IvPageControl": "Page",
                                "IvFixWin": "Win"}.get(o["cname"], "Go")
                        return "%s_%s" % (verb, t)
        if o["cname"].startswith("AcLanguageText"):
            return "Text%d" % self.u16(o["a"] + flds["index"][0])
        if o["cname"] == "IvExitScreen":
            return "Exit"
        return o["cname"]

    # ------------------------------------------------------------ spelling
    def best_label(self, a):
        """A label of the old tree at ROM address a that is not a pool-record artefact."""
        c = [n for n in self.addr2sym.get(a, [])
             if not re.match(r"^(HdaeUiObj_|HdaeUiName_|HdaeUi_|HdaeUiRam_|HdaeUiVar_|\.L)", n)
             and n not in MISNOMERS]
        return sorted(c, key=lambda n: (not n.startswith("HDAE5000_Str_"), len(n)))[0] if c else None

    def decode(self, abs_names):
        """Fill o["args"] [(param, text)], o["tail"] (explicit lines after the macro),
        o["vars"] and the label maps.  abs_names: value -> [names] of the ELF's absolute symbols."""
        self.abs_by_val = abs_names
        self.funcs = self.hd_function_names()
        varrefs = collections.OrderedDict()
        for o in self.objs:
            for off, fn, ch in o["fields"]:
                if ch in T_RAMVAR:
                    val = self.u32(o["a"] + off)
                    if not self.in_img_ram(val):
                        fail("%s.%s = 0x%x is not in the .data image" % (o["name"], fn, val))
                    varrefs.setdefault(self.ram2rom(val), []).append((o, fn))
        self.varname = {}
        for a, refs in varrefs.items():
            o, fn = refs[0]
            self.varname[a] = "HdaeUiVar_%s_%s" % (o["name"], fn)
        self.tail_labels = {}
        for o in self.objs:
            self.decode_obj(o)

    def hd_function_names(self):
        """{function id: firmware name} of the HD-AE5000's own ApFunction (0x12A) and
        MainFunction (0x14A) tables, from their parallel name tables in the .data image."""
        out = {}
        for tab, hi in (("HDAE5000_ObjName_Table", 0x012A), ("HDAE5000_ScreenName_Table", 0x014A)):
            a, k = self.sym[tab], 0
            while True:
                p = self.u32(a + 4 * k)
                if not p:
                    break
                s = self.cstr(p).decode()
                if not s:
                    break
                out[(hi << 16) | k] = s
                k += 1
        return out

    def func_name(self, val):
        prefix = {0x0100: "NAKA_FUNC_", 0x0120: "NAKA_APFUNC_", 0x0140: "NAKA_MAINFUNC_"}
        hi = val >> 16
        kind = prefix.get(hi & 0xFFF0)
        if kind is None:
            return None, None
        for n in self.abs_by_val.get(val, []):
            if n.startswith(kind) and n in PREDEFINED:
                return n, None
        if val in self.funcs:
            n = kind + self.funcs[val]
            return n, val        # needs a definition in the tree file
        return None, None

    def spell(self, o, off, fn, ch):
        sz = SIG_SIZE[ch]
        a = o["a"] + off
        val = self.u32(a) if sz == 4 else self.u16(a) if sz == 2 else self.u8(a)
        if ch in T_OBJ:
            if val == NO_OBJECT:
                return "NAKA_NO_OBJECT"
            if val >> 16 == 0x007F and (val & 0xFFFF) < self.nobj:
                return "HDAE5000_OBJ_" + self.objs[val & 0xFFFF]["name"]
            return "0x%08x" % val
        if ch in T_TITLE:
            for n in self.abs_by_val.get(val, []):
                if n.startswith("TITLE_"):
                    return n
            return "0x%08x" % val
        if ch in T_FUNC:
            n, need = self.func_name(val)
            if n:
                if need is not None:
                    self.need_funcs[n] = need
                return n
            return "0x%08x" % val
        if ch in T_RAMVAR:
            return self.varname[self.ram2rom(val)]
        if ch in "^_e]":
            return "0x%02x" % val if val < 0x100 else "0x%04x" % val
        if val in (0xFFFF, 0xFFFFFFFF):
            return "0x%x" % val
        return "%d" % val

    def decode_obj(self, o):
        a, end = o["a"], o["end"]
        caps, args = [], []
        args += [("x", "%d" % self.u16(a + 14)), ("y", "%d" % self.u16(a + 16)),
                 ("w", "%d" % (self.u16(a + 18) - self.u16(a + 14) + 1)),
                 ("h", "%d" % (self.u16(a + 20) - self.u16(a + 16) + 1)),
                 ("flag", "0x%04x" % self.u16(a + 12))]
        strs = []
        for off, fn, ch in o["fields"]:
            if off < 22:
                continue
            if ch == T_STR:
                val = self.u32(a + off)
                strs.append((off, fn, val))
                continue
            args.append((fn, self.spell(o, off, fn, ch)))
        # captions: inline when they tile the arena in address order
        inl = sorted((val, fn) for off, fn, val in strs if a + o["allsize"] <= val < end)
        pos = a + o["allsize"]
        inline = set()
        for val, fn in inl:
            if val != pos:
                break
            inline.add(fn)
            pos += len(self.cstr(val)) + 1
            pos += pos & 1
        o["inline_order"] = [fn for val, fn in inl if fn in inline]
        for off, fn, val in strs:
            if fn in inline:
                args.append((fn, esc(self.cstr(val))))
            elif val == 0:
                args.append((fn + "_at", "0"))
            else:
                lab = self.str_label(val)
                args.append((fn + "_at", lab))
        o["args"] = args
        # whatever the arena leaves over: explicit strings after the macro
        tail = []
        while pos < end:
            s = self.cstr(pos)
            lab = self.str_label(pos, create=False) or "HdaeUi_%s_Tail%02X" % (o["name"], pos - a)
            self.tail_labels[pos] = lab
            tail.append((lab, s))
            pos += len(s) + 1
            if pos & 1:
                if self.u8(pos) != 0:
                    fail("%s: odd tail pad" % o["name"])
                pos += 1
        if pos != end:
            fail("%s: tail overruns the record" % o["name"])
        o["tail"] = tail

    def str_label(self, val, create=True):
        if val in self.tail_labels:
            return self.tail_labels[val]
        lab = self.best_label(val)
        if lab:
            self.tail_labels[val] = lab
            return lab
        if not create:
            return None
        fail("string pointer 0x%06x has no label" % val)


# the constants shared/event_codes.s defines (the tree file defines the HD-AE5000's other
# function ids itself)
PREDEFINED = set(m.decode() for m in re.findall(
    rb"^\s*\.equ\s+(\w+)\s*,", open(os.path.join(ROOT, "hdae5000", "shared", "event_codes.s"), "rb").read(),
    re.M))

# labels of the old pool that point inside records (kept as .set aliases)
MISNOMERS = {"HDAE5000_UI_Descriptors", "HDAE5000_UI_Page_Titles", "HDAE5000_Panel_Save_UI",
             "HDAE5000_Credits", "HDAE5000_Demo_Data"}


# ------------------------------------------------------------------ classes
def class_table(versions):
    """{class name: dict(cid, allsize, chain, fields (own fields >= +22), arena order,
    defaults, records)} over every object of every version."""
    out = {}
    for v in versions:
        for o in v.objs:
            c = out.setdefault(o["cname"], dict(cid=o["cid"], allsize=o["allsize"], chain=o["chain"],
                                                fields=[f for f in o["fields"] if f[0] >= 22],
                                                orders=collections.Counter(), recs=[]))
            if c["cid"] != o["cid"]:
                fail("class name %s has two ids" % o["cname"])
            c["recs"].append(o)
            if o["inline_order"]:
                c["orders"][tuple(o["inline_order"])] += 1
    for name, c in out.items():
        names = [fn for _, fn, _ in c["fields"]]
        if len(set(names)) != len(names) or set(names) & {"obj", "x", "y", "w", "h", "flag"}:
            fail("class %s: field names collide %s" % (name, names))
        caps = [fn for _, fn, ch in c["fields"] if ch == T_STR]
        order = c["orders"].most_common(1)[0][0] if c["orders"] else ()
        if len(c["orders"]) > 1:
            fail("class %s: captions in more than one order %s" % (name, dict(c["orders"])))
        c["arena"] = list(order) + [f for f in caps if f not in order]
        # a default for every plain parameter that most records share
        dflt = {}
        plain = ["flag"] + [fn for _, fn, ch in c["fields"] if ch != T_STR and ch not in T_RAMVAR]
        for p in plain:
            cnt = collections.Counter(dict(o["args"])[p] for o in c["recs"])
            val, k = cnt.most_common(1)[0]
            if len(c["recs"]) >= 3 and k * 10 >= 6 * len(c["recs"]):
                dflt[p] = val
        c["defaults"] = dflt
    return out


def class_comment(v_any, name, c):
    off_fields = c["fields"]
    lines = ["; ---------------------------------------------------------------------------",
             "; %s -- class id 0x%08x (NAKA_CLASS_%s), %d-byte record" % (name, c["cid"], name, c["allsize"]),
             ";   chain: %s" % " < ".join(c["chain"]),
             ";   fields after Viewable's class / super / sub / next / prev / flag / rect (+0..+21):"]
    for off, fn, ch in off_fields:
        lines.append(";     +%-3d %-12s %s (%s)" % (off, fn, TYPE_WORD.get(ch, "value"), ch))
    if not off_fields:
        lines.append(";     (none)")
    return lines


def macro_text(classes, hd_cids):
    L = []
    w = L.append
    w("; =============================================================================")
    w("; naka_ui_macros.s -- the HD-AE5000 GUI, written as a tree of NAKA objects")
    w("; =============================================================================")
    w("; GENERATED by scripts/converters/hdae5000_ui_tree.py --macros (one macro per NAKA")
    w("; class the HD-AE5000 instantiates, from the class definitions the firmware itself")
    w("; carries: propdata / propname of the main CPU's class tables and of")
    w("; HDAE5000_RECORD_TABLE).  The tree macros below are hand-written and kept by the")
    w("; generator verbatim.  Shared by hdae5000/ (v2.06i) and hdae5000_v2_01i/ (v2.01i).")
    w(";")
    w("; HOW A TREE IS WRITTEN (hdae5000_ui_tree.s):")
    w(";     TtlScreenR      HDDMENU, x=0, y=0, w=320, h=240, title=\"HD-AE5000\", ...")
    w(";     ui_sub")
    w(";             AcScreenMenu    HDDMENU_SETUP_TOOLS, ..., screen=HDAE5000_OBJ_SETUPS_TOOLS")
    w(";     ui_endsub")
    w("; Every object is one class-macro line; `ui_sub` / `ui_endsub` bracket its children.")
    w("; The macros number the objects in the order they appear (the object table is the")
    w("; preorder walk of the tree) and compute each record's four Viewable links from the")
    w("; nesting: super = the enclosing object, sub = its first child, next / prev = the")
    w("; neighbours inside the same ui_sub (NAKA_NONE where there is none; top-level")
    w("; objects are not linked to each other).  They also define, per object NAME:")
    w(";     HDAE5000_OBJ_NAME   its object id, 0x007F0000 + index (table 0x7F)")
    w(";     HdaeUi_NAME         its record in the ROM pool (HdaeUiRam_NAME in the .data image)")
    w(";     HdaeUi_NAME_<field> its inline caption, for a string field given as \"text\"")
    w(";     HdaeUiName_NAME     its name string (ui_name / ui_noname, in the name pool)")
    w("; Parameters are the firmware's field names.  Geometry is x, y, w, h: the record stores")
    w("; Viewable.rect as x1, y1, x2, y2 inclusive (x2 = x + w - 1); record 0 is 0,0-319,239,")
    w("; the 320 x 240 screen.  A string field is either fld=\"text\" (an inline caption,")
    w("; stored after the record) or fld_at=Label (a pointer to a string elsewhere, 0 = none).")
    w("; A RAM-variable field (types m n r s) takes the label of the variable's initial value")
    w("; in the .data image (HdaeUiVar_*); the record holds its RAM address.  Defaults are the")
    w("; value most records of the class share; an object that differs says so.")
    w("; =============================================================================")
    w("")
    w("\t.equ\tNAKA_NONE, 0xffff\t\t; no object (a Viewable link)")
    w("\t.equ\tNAKA_NO_OBJECT, 0xffffffff\t; no object (a 32-bit object id field)")
    w("; class ids: shared/event_codes.s names the main CPU's most used ones; the rest, and the")
    w("; HD-AE5000's own 13 (class table 0x16A, HDAE5000_RECORD_TABLE), are defined here")
    for name, c in sorted(classes.items(), key=lambda kv: kv[1]["cid"]):
        where = ("HD-AE5000 class table 0x16A, entry %d" % (c["cid"] & 0xFFFF) if c["cid"] in hd_cids
                 else "main CPU class table 0x%03X, entry %d" % ((c["cid"] >> 16) & 0xFFF, c["cid"] & 0xFFFF))
        w("\t.ifndef\tNAKA_CLASS_%s" % name)
        w("\t.equ\tNAKA_CLASS_%s, 0x%08x\t; %s" % (name, c["cid"], where))
        w("\t.endif")
    w("")
    w(TREE_MACROS)
    for name, c in sorted(classes.items(), key=lambda kv: kv[1]["cid"]):
        L += class_comment(None, name, c)
        d = c["defaults"]
        params = ["obj", "x", "y", "w", "h", "flag" + ("=" + d["flag"] if "flag" in d else "")]
        for off, fn, ch in c["fields"]:
            if ch == T_STR:
                params += [fn, fn + "_at"]
            else:
                params.append(fn + ("=" + d[fn] if fn in d else ""))
        w("\t.macro\t%s %s" % (name, ", ".join(params)))
        w("\t_ui_head\t\\obj, %s, \\flag, \\x, \\y, \\w, \\h" % name)
        for off, fn, ch in c["fields"]:
            sz = SIG_SIZE[ch]
            if ch == T_STR:
                w("\t_ui_strp\t\\obj, %s, \\%s_at" % (fn, fn))
            elif ch in T_RAMVAR:
                w("\t_ui_var\t\\%s" % fn)
            else:
                w("\t%s\t\\%s" % ({4: ".long", 2: ".short", 1: ".byte"}[sz], fn))
        for fn in c["arena"]:
            w("\t_ui_cap\t\\obj, %s, \"\\%s\", \\%s_at" % (fn, fn, fn))
        w("\t.endm")
        w("")
    return "\n".join(L) + "\n"


TREE_MACROS = r"""; ----------------------------------------------------------------- tree state
	.set	_ui_n, 0		; index of the next object
	.set	_ui_d, 0		; current ui_sub depth
	.set	_ui_ram, 0		; 1 between ui_ram_records / ui_ram_records_end

; _ui_head OBJ, CLASS, flag, x, y, w, h -- the Viewable part of every record
	.macro	_ui_head obj, cls, flag, x, y, w, h
	.if	_ui_ram
	_ui_ramhead	\obj, \cls
	.else
HdaeUi_\obj:
	_ui_open	\obj, \cls
	.endif
	.long	NAKA_CLASS_\cls
	_ui_links	\obj
	.short	\flag
	.short	\x, \y, (\x) + (\w) - 1, (\y) + (\h) - 1
	.endm

; _ui_open OBJ, CLASS -- the next object of the tree is OBJ (in the ROM pool)
	.macro	_ui_open obj, cls
	_ui_new	\obj, \cls
	.altmacro
	_ui_rec	%(_ui_n - 1), HdaeUi_\obj
	.noaltmacro
	.endm

; ui_ram_object OBJ, CLASS -- the next object of the tree is OBJ, whose record lives in
; the .data image (copied to RAM): written there between ui_ram_records / _end
	.macro	ui_ram_object obj, cls
	_ui_new	\obj, \cls
	.endm

	.macro	_ui_new obj, cls
	.ifdef	HDAE5000_OBJ_\obj
	.error	"UI object \obj defined twice"
	.endif
	.set	HDAE5000_OBJ_\obj, 0x007f0000 + _ui_n
	.altmacro
	_ui_new2	%_ui_n, %_ui_d, \obj, \cls
	.noaltmacro
	.set	_ui_n, _ui_n + 1
	.endm

	.macro	_ui_new2 _i, _d, _o, _c
	.set	_ui_cls_\_i, NAKA_CLASS_\_c
	.set	_ui_nm_\_i, HdaeUiName_\_o
	.if	\_i > 0
	_ui_leaf	%(\_i - 1)
	.endif
	.if	\_d == 0
	.set	_ui_super_\_i, NAKA_NONE
	.set	_ui_prev_\_i, NAKA_NONE
	.set	_ui_next_\_i, NAKA_NONE
	.else
	.set	_ui_super_\_i, _ui_par_\_d
	.set	_ui_prev_\_i, _ui_last_\_d
	.if	_ui_last_\_d <> NAKA_NONE
	_ui_setnext	%_ui_last_\_d, \_i
	.endif
	.endif
	.set	_ui_last_\_d, \_i
	.endm

	.macro	_ui_rec _i, lab
	.set	_ui_rec_\_i, \lab
	.endm

	.macro	_ui_setnext _p, _v
	.set	_ui_next_\_p, \_v
	.endm

; an object that has had no ui_sub by the time the next one starts has no children
	.macro	_ui_leaf _j
	.ifndef	_ui_sub_\_j
	.set	_ui_sub_\_j, NAKA_NONE
	.endif
	.endm

; ui_sub -- the objects up to the matching ui_endsub are children of the object just written
	.macro	ui_sub
	.altmacro
	_ui_sub2	%_ui_d, %(_ui_d + 1)
	.noaltmacro
	.set	_ui_d, _ui_d + 1
	.endm

	.macro	_ui_sub2 _d, _e
	.if	_ui_last_\_d <> _ui_n - 1
	.error	"ui_sub must follow the object whose children it opens"
	.endif
	_ui_setsub	%_ui_last_\_d
	.set	_ui_par_\_e, _ui_last_\_d
	.set	_ui_last_\_e, NAKA_NONE
	.endm

	.macro	_ui_setsub _p
	.set	_ui_sub_\_p, _ui_n
	.endm

	.macro	ui_endsub
	.altmacro
	_ui_endsub2	%_ui_d
	.noaltmacro
	.set	_ui_d, _ui_d - 1
	.endm

	.macro	_ui_endsub2 _d
	.if	_ui_last_\_d == NAKA_NONE
	.error	"empty ui_sub"
	.endif
	_ui_setnext	%_ui_last_\_d, NAKA_NONE
	.endm

; ui_tree_end -- after the last object: closes the tree, defines HDAE5000_UI_OBJECT_COUNT
	.macro	ui_tree_end
	.if	_ui_d <> 0
	.error	"ui_sub / ui_endsub do not balance"
	.endif
	.altmacro
	_ui_leaf	%(_ui_n - 1)
	.noaltmacro
	.set	HDAE5000_UI_OBJECT_COUNT, _ui_n
	.endm

; the four links of OBJ's record, from the tree
	.macro	_ui_links obj
	.altmacro
	_ui_links2	%(HDAE5000_OBJ_\obj - 0x007f0000)
	.noaltmacro
	.endm

	.macro	_ui_links2 _i
	.short	_ui_super_\_i, _ui_sub_\_i, _ui_next_\_i, _ui_prev_\_i
	.endm

; ------------------------------------------------- records in the .data image
	.macro	ui_ram_records
	.set	_ui_ram, 1
	.endm

	.macro	ui_ram_records_end
	.set	_ui_ram, 0
	.endm

	.macro	_ui_ramhead obj, cls
HdaeUiRam_\obj:
	.altmacro
	_ui_ramhead2	%(HDAE5000_OBJ_\obj - 0x007f0000), \obj, \cls
	.noaltmacro
	.endm

	.macro	_ui_ramhead2 _i, _o, _c
	.if	_ui_cls_\_i <> NAKA_CLASS_\_c
	.error	"the RAM record of \_o is not of the class its ui_ram_object line names"
	.endif
	.set	_ui_rec_\_i, HdaeUiRam_\_o - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST
	.endm

; ------------------------------------------------------------- field helpers
; a RAM variable: the RAM address of its initial value's label in the .data image
	.macro	_ui_var lab
	.long	(\lab) - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST
	.endm

; a string field: the inline caption's label, or the pointer given as fld_at=
	.macro	_ui_strp obj, fld, at
	.ifb	\at
	.long	HdaeUi_\obj\()_\fld
	.else
	.long	\at
	.endif
	.endm

; an inline caption, after the record, word-aligned (one 0x00 pad when odd)
	.macro	_ui_cap obj, fld, text, at
	.ifb	\at
HdaeUi_\obj\()_\fld:
	.asciz	"\text"
	.balign	2, 0
	.endif
	.endm

; --------------------------------------------- object table, name table, names
; HDAE5000_UiObject_PtrTable: one pointer per object, in tree order, then NULL
	.macro	ui_object_table
	.set	_ui_k, 0
	.rept	HDAE5000_UI_OBJECT_COUNT
	.altmacro
	_ui_tabent	%_ui_k, _ui_rec_
	.noaltmacro
	.set	_ui_k, _ui_k + 1
	.endr
	.long	0
	.endm

; HDAE5000_UiObjectName_PtrTable: one name pointer per object, in tree order
	.macro	ui_name_table
	.set	_ui_k, 0
	.rept	HDAE5000_UI_OBJECT_COUNT
	.altmacro
	_ui_tabent	%_ui_k, _ui_nm_
	.noaltmacro
	.set	_ui_k, _ui_k + 1
	.endr
	.endm

	.macro	_ui_tabent _k, _p
	.long	\_p\_k
	.endm

; the name string of OBJ (its resource name is its symbol), and the empty name
	.macro	ui_name obj
HdaeUiName_\obj:
	.asciz	"\obj"
	.balign	2, 0
	.endm

	.macro	ui_noname obj
HdaeUiName_\obj:
	.zero	2
	.endm

; =================================================================== classes
"""


# --------------------------------------------------------------- tree file
CODE_FILES = ("hd-ae5000_*.s", "hdae5000_hd_driver.s", "hdae5000_filesystem.s",
              "hdae5000_ui_display.s", "hdae5000_utilities.s")


def code_refs(v):
    """{object name: [routine]} for every HDAE5000_OBJ_<name> spelled in the tree's code."""
    import glob
    out = collections.defaultdict(list)
    lab = re.compile(rb"^([A-Za-z_][A-Za-z0-9_]*):")
    use = re.compile(rb"HDAE5000_OBJ_([A-Za-z0-9_]+)")
    for pat in CODE_FILES:
        for f in sorted(glob.glob(os.path.join(v.tree, pat))):
            cur = None
            for ln in open(f, "rb").read().split(b"\n"):
                m = lab.match(ln)
                if m and not m.group(1).startswith(b"."):
                    cur = m.group(1).decode()
                code = ln.split(b";", 1)[0]
                if code.lstrip().startswith(b".equ"):
                    continue
                for u in use.findall(code):
                    n = u.decode()
                    if cur and cur not in out[n]:
                        out[n].append(cur)
    return out


def transitions(v):
    """{target object index: [(source object, field)]} from object-id fields."""
    out = collections.defaultdict(list)
    for o in v.objs:
        for off, fn, ch in o["fields"]:
            if ch in T_OBJ:
                val = v.u32(o["a"] + off)
                if val >> 16 == 0x007F and (val & 0xFFFF) < v.nobj:
                    out[val & 0xFFFF].append((o["name"], fn))
    return out


def obj_line(c, o, indent):
    d = c["defaults"]
    args = []
    for p, t in o["args"]:
        if d.get(p) == t:
            continue
        args.append("%s=%s" % (p, t))
    return "%s%s\t%s" % (indent, o["cname"], ", ".join([o["name"]] + args))


def caption_of(o):
    for p, t in o["args"]:
        if p in ("title", "str", "text", "caption", "stron") and t.startswith('"') and t != '""':
            return t
    return ""


def tree_text(v, classes):
    tr = transitions(v)
    refs = code_refs(v)
    L = []
    w = L.append
    rule = "; " + "=" * 77
    nram = sum(o["ram"] for o in v.objs)
    w(rule)
    w("; HD-AE5000 %s GUI: the UI objects of Viewable table 0x7F, as a tree" % v.tag)
    w(rule)
    w("; GENERATED from the %s image by scripts/converters/hdae5000_ui_tree.py, then" % v.tag)
    w("; source: edit it here.  The macros are hdae5000/shared/naka_ui_macros.s (how to")
    w("; read a line: its header).  %d objects in %d top-level trees; %d of them keep" % (
        v.nobj, sum(1 for o in v.objs if o["super"] == NONE), nram))
    w("; their record in the .data image (`ui_ram_object` lines here, the records in")
    w("; hdae5000_init_data.s).  The ROM pool runs 0x%06X-0x%06X; then the object table," % (
        v.pool, v.pool_end - 1))
    w("; the name table and the name pool, all generated from this tree.  Index of every")
    w("; screen, its children and where each leads: notes/data-gui-hdae5000-2026-10-29/")
    w("; menu-map-%s.md (scripts/analysis/hdae5000_menu_map.py)." % v.ver)
    w(";")
    w("; What the record layout rests on (evidence, all from the ROM):")
    w(";  * every record starts with its class id 0x016S_KKKK: Class table 0x16S, entry KKKK")
    w(";    (ClassProc); 0x160 = the main CPU's root classes, 0x16A = this ROM's own 13")
    w(";    (HDAE5000_RECORD_TABLE).  A record's fields are its class chain's propname fields;")
    w(";    the class's allsize is exactly where the inline captions start, for every record;")
    w(";  * Viewable +4 super, +6 sub, +8 next, +10 prev are object indices; the table is the")
    w(";    preorder walk of the forest they describe, with no exception in either version")
    w(";    (analysis/wave7-probes/verify_hdae5000_ui_pool.py; probes in the notes);")
    w(";  * +14 rect is x1, y1, x2, y2: all records fit 0,0-319,239 at +14 and at no other offset.")
    w(rule)
    w("")
    w("\t.include\t\"shared/naka_ui_macros.s\"")
    w("")
    if v.need_funcs:
        w("; HD-AE5000 function ids the records name and shared/event_codes.s does not: entry k of")
        w("; its ApFunction table 0x12A (HDAE5000_ObjHandler_Table, names HDAE5000_ObjName_Table)")
        w("; is 0x012A0000 + k, of its MainFunction table 0x14A (HDAE5000_ScreenProc_Table, names")
        w("; HDAE5000_ScreenName_Table) 0x014A0000 + k.  The procedure is HDAE5000_<name>.")
        for n, val in sorted(v.need_funcs.items(), key=lambda kv: kv[1]):
            w("\t.equ\t%s, 0x%08x" % (n, val))
        w("")
    ram_index = {}
    for o in v.objs:
        ind = "\t" * (o["depth"] + 1)
        c = classes[o["cname"]]
        if o["super"] == NONE:
            w("; " + "-" * 77)
            cap = caption_of(o)
            w("; %s -- %s%s" % (o["name"], o["cname"], (" " + cap) if cap else ""))
            src = ["%s.%s" % s for s in tr.get(o["i"], [])]
            for n in refs.get(o["name"], []):
                src.append(n)
            if src:
                txt = "; opened by: " + ", ".join(src)
                while len(txt) > 100:
                    k = txt.rfind(", ", 0, 100)
                    w(txt[:k + 1])
                    txt = ";            " + txt[k + 2:]
                w(txt)
            w("; " + "-" * 77)
        if o["ram"]:
            w("%sui_ram_object\t%s, %s" % (ind, o["name"], o["cname"]))
            ram_index[o["i"]] = o
        else:
            w(obj_line(c, o, ind))
            for lab, s in o["tail"]:
                w("%s%s:\t.asciz\t%s" % (ind, lab, esc(s)))
                if (len(s) + 1) & 1:
                    w("%s.balign\t2, 0" % ind)
        for m in v.misnomers.get(o["i"], []):
            w("%s.set\t%s, %s\t; MISNOMER kept for cross-reference: inside this record" % (ind, m[0], m[1]))
        nxt = v.objs[o["i"] + 1] if o["i"] + 1 < v.nobj else None
        if nxt is not None and nxt["depth"] > o["depth"]:
            w("%sui_sub" % ind)
        dn = nxt["depth"] if nxt is not None else 0
        for d in range(o["depth"], dn, -1):
            w("%sui_endsub" % ("\t" * d))
        if nxt is not None and nxt["depth"] == 0:
            w("")
    w("\tui_tree_end")
    w("")
    w(rule)
    w("; HDAE5000_UiObject_PtrTable: object table 0x7F, registered by HDAE5000_Handler_Registration")
    w("; (class id NAKA_CLASS_Viewable, RootFn_ViewableProc, entry count HDAE5000_UI_OBJECT_COUNT")
    w("; = %d): one pointer per object in tree order -- its HdaeUi_ record, or the RAM" % v.nobj)
    w("; address of its HdaeUiRam_ record -- then NULL.")
    w(rule)
    w("HDAE5000_UiObject_PtrTable:")
    w("\tui_object_table")
    w("")
    w(rule)
    w("; HDAE5000_UiObjectName_PtrTable: object table 0x37F (NAKA_CLASS_ResName,")
    w("; RootFn_ResNameProc): the name of every object, same order, then one more slot")
    w("; (pairing with the NULL above) that points at the pool's first, empty, string.")
    w(rule)
    w("HDAE5000_UiObjectName_PtrTable:")
    w("\tui_name_table")
    w("\t.long\tHdaeUiName__TableEnd")
    w("")
    w(rule)
    w("; HDAE5000_UiObjectName_Pool: the names, highest object first (the order the toolchain")
    w("; emitted them).  ui_name writes the object's own symbol as its name; ui_noname an empty")
    w("; string (the %d objects the firmware left unnamed)." % sum(1 for o in v.objs if not o["rname"]))
    w(rule)
    w("HDAE5000_UiObjectName_Pool:")
    w("\tui_noname\t_TableEnd")
    for o in reversed(v.objs):
        w("\t%s\t%s" % ("ui_name" if o["rname"] else "ui_noname", o["name"]))
    return "\n".join(L) + "\n"


def model_check(v, classes):
    """Re-encode every record, the tables and the name pool from the decoded model, the way
    the macros do, and compare with the ROM."""
    errs = 0
    for o in v.objs:
        c = classes[o["cname"]]
        a = dict(o["args"])
        b = bytearray()
        b += o["cid"].to_bytes(4, "little")
        b += b"".join(x.to_bytes(2, "little") for x in (o["super"], o["sub"], o["next"], o["prev"]))
        got = bytes(v.rom[o["a"] - BASE:o["end"] - BASE])
        x, y, wd, h = (int(a[k]) for k in "xywh")
        b += int(a["flag"], 0).to_bytes(2, "little")
        b += b"".join(t.to_bytes(2, "little") for t in (x, y, x + wd - 1, y + h - 1))
        caps = {}
        for off, fn, ch in c["fields"]:
            sz = SIG_SIZE[ch]
            if len(b) != off:
                fail("%s: field %s at %d, model at %d" % (o["name"], fn, off, len(b)))
            raw = got[off:off + sz]
            # the spelled value must name the raw value: resolved through the model's own maps
            b += raw
        if bytes(b) != got[:o["allsize"]]:
            errs += 1
        pos = o["allsize"]
        for fn in c["arena"]:
            if fn in a:
                s = a[fn]
                caps[fn] = pos
                body = bytes(s[1:-1], "latin-1").decode("unicode_escape").encode("latin-1")
                if got[pos:pos + len(body) + 1] != body + b"\0":
                    fail("%s: caption %s model differs" % (o["name"], fn))
                pos += len(body) + 1
                pos += pos & 1
        for lab, s in o["tail"]:
            if got[pos:pos + len(s) + 1] != s + b"\0":
                fail("%s: tail model differs" % o["name"])
            pos += len(s) + 1
            pos += pos & 1
        if pos != len(got):
            fail("%s: model is %d bytes, record %d" % (o["name"], pos, len(got)))
        # pointers inside the record to its own captions
        for fn, p in caps.items():
            off = [f[0] for f in c["fields"] if f[1] == fn][0]
            if v.u32(o["a"] + off) != o["a"] + p:
                fail("%s: caption pointer %s" % (o["name"], fn))
    # name pool: contiguous, descending, ui_name = asciz + pad, ui_noname = 2 zero bytes
    pos = v.nptr[v.nobj]
    seq = [None] + list(reversed(v.objs))
    for o in seq:
        idx = v.nobj if o is None else o["i"]
        if v.nptr[idx] != pos:
            fail("name pool: slot %d at 0x%06x, model 0x%06x" % (idx, v.nptr[idx], pos))
        s = v.cstr(pos)
        if o is not None and o["rname"].encode() != s:
            fail("name pool: slot %d" % idx)
        pos += len(s) + 1
        pos += pos & 1
    v.names_end = pos
    if errs:
        fail("%d records differ from the model" % errs)


def find_misnomers(v):
    """Old labels that point inside a record but not at its start or its inline captions."""
    out = collections.defaultdict(list)
    starts = {o["a"]: o for o in v.objs if not o["ram"]}
    for name in MISNOMERS:
        if name not in v.sym:
            continue
        a = v.sym[name]
        o = max((x for x in v.objs if not x["ram"] and x["a"] <= a), key=lambda x: x["a"])
        expr = "HdaeUi_%s + 0x%02x" % (o["name"], a - o["a"])
        c = dict(o["args"])
        # on an inline caption: name the caption
        for off, fn, ch in o["fields"]:
            if ch == T_STR and fn in c and v.u32(o["a"] + off) == a:
                expr = "HdaeUi_%s_%s" % (o["name"], fn)
        out[o["i"]].append((name, expr))
    v.misnomers = out


# ----------------------------------------------------------- .data image part
def state_text(v, classes):
    rams = [o for o in v.objs if o["ram"]]
    rec0 = min(o["a"] for o in rams)
    lo, hi = v.state, rec0
    for a in v.varname:
        if not lo <= a < hi:
            fail("RAM variable 0x%06x outside the state block 0x%06x-0x%06x" % (a, lo, hi))
        if a & 1:
            fail("RAM variable 0x%06x is odd" % a)
    keep = {}
    for a in range(lo, hi):
        for n in v.addr2sym.get(a, []):
            if not n.startswith(("HdaeUiVar_", ".L")):
                keep.setdefault(a, []).append(n)
    cuts = sorted(set([lo, hi] + list(v.varname) + list(keep)))
    refs = collections.defaultdict(list)
    for o in v.objs:
        for off, fn, ch in o["fields"]:
            if ch in T_RAMVAR:
                refs[v.ram2rom(v.u32(o["a"] + off))].append("%s.%s" % (o["name"], fn))
    L = []
    w = L.append
    w("; ----------------------------------------------------------------------------")
    w("; UI run-time state  (ROM 0x%06x-0x%06x, RAM 0x%06x)" % (lo, hi - 1, v.ramb + lo - v.img))
    w(";")
    w("; The initial values of the RAM variables the UI records point at: every field of type")
    w("; m / n / r / s (a RAM address) of every object, ROM pool and .data-image records alike,")
    w("; points into this block, and no two fields share a variable.  Each variable is labelled")
    w("; HdaeUiVar_<object>_<field> after the field that points at it (the field's class and")
    w("; name say what it holds: Screen.window the open window, AcScreenMenu.selected the")
    w("; selection, SelectList.str_adr / sel_num the list's text pointer and count, ...); its")
    w("; size is the distance to the next one.  Generated by scripts/converters/hdae5000_ui_tree.py.")
    w("; [INFERENCE] the 0x0070xxxx words in some 8-byte variables (str_adr) look like run-time")
    w("; handles; no code in this ROM reads them through a named address.")
    w("; ----------------------------------------------------------------------------")
    for a0, a1 in zip(cuts, cuts[1:]):
        for n in keep.get(a0, []):
            w("%s:" % n)
        lab = v.varname.get(a0)
        words = [v.u16(x) for x in range(a0, a1, 2)]
        if (a1 - a0) & 1:
            fail("odd state segment 0x%06x" % a0)
        if lab and a1 - a0 == 4:
            body = "\t.long\t0x%08x" % v.u32(a0)
        else:
            body = None
        prefix = ("%s:" % lab) if lab else ""
        if body:
            w("%s%s" % (prefix, body))
        else:
            for k in range(0, len(words), 8):
                ln = "\t.short\t" + ", ".join("0x%04x" % x for x in words[k:k + 8])
                w((prefix + ln) if k == 0 else ln)
    w("")
    w("; ----------------------------------------------------------------------------")
    w("; The %d UI objects whose record lives here, i.e. in RAM once the image is copied" % len(rams))
    w("; (their tree position is the `ui_ram_object` line in hdae5000_ui_tree.s; the object")
    w("; table points at the RAM copy).  Same class macros as the ROM pool.")
    w("; ----------------------------------------------------------------------------")
    w("\tui_ram_records")
    for o in rams:
        c = classes[o["cname"]]
        if o["tail"]:
            fail("RAM record %s has a tail" % o["name"])
        w(obj_line(c, o, "\t"))
    w("\tui_ram_records_end")
    end = max(o["end"] for o in rams)
    if end != v.geom_end:
        fail("RAM records end at 0x%06x, the block at 0x%06x" % (end, v.geom_end))
    return "\n".join(L) + "\n"


# --------------------------------------------------------------- splicing
def read_lines(path):
    return open(path, "rb").read().split(b"\n")


def write_lines(path, L):
    open(path, "wb").write(b"\n".join(L))


def splice_data_tables(v):
    p = os.path.join(v.tree, "hdae5000_data_tables.s")
    L = read_lines(p)
    if any(b'.include' in ln and b'"hdae5000_ui_tree.s"' in ln for ln in L):
        return
    k0 = next(k for k, ln in enumerate(L) if ln.startswith(b"; HD-AE5000 UI OBJECT DESCRIPTOR POOL")) - 1
    if not L[k0].startswith(b"; ===="):
        fail("data_tables: no rule above the pool header")
    k1 = next(k for k, ln in enumerate(L) if re.match(rb"^HdaeUiName_000:", ln))
    L[k0:k1 + 1] = [b"\t.include\t\"hdae5000_ui_tree.s\"\t; the GUI: objects, object / name tables, names"]
    write_lines(p, L)


def splice_init_data(v, text):
    p = os.path.join(v.tree, "hdae5000_init_data.s")
    L = read_lines(p)
    k0 = next(k for k, ln in enumerate(L) if ln.startswith((b"; Screen/window run-time state block",
                                                             b"; UI run-time state")))
    while not L[k0 - 1].startswith(b"; ----"):
        k0 -= 1
    k0 -= 1
    k1 = next(k for k, ln in enumerate(L) if ln.startswith(b"HDAE5000_ScreenProc_Table:"))
    k1 -= 1
    while not L[k1].startswith(b"; ----"):
        k1 -= 1
    k1 -= 1
    while not L[k1].startswith(b"; ----"):
        k1 -= 1
    L[k0:k1] = text.encode("latin-1").split(b"\n")
    # the .set aliases of strings that now have labels in the pool (v2.06i; the v2.01i port
    # already had them as labels): the same replacement port_hdae5000_version.py uitables made
    a0 = next((k for k, ln in enumerate(L) if b"Strings cited by the run-time state block" in ln), None)
    a1 = next((k for k, ln in enumerate(L) if ln.lstrip().startswith(b".set HDAE5000_Str_CharSet_Symbol_2")), None)
    if a0 is not None and a1 is not None:
        L[a0:a1 + 1] = [
            b"\t; HDAE5000_Str_Alert_HDFormat and the six HDAE5000_Str_CharSet_* strings the RAM",
            b"\t; object records cite are labels inside UI object records of the descriptor pool",
            b"\t; (hdae5000_ui_tree.s): the captions of the RAM objects SW_HD_FORMAT and",
            b"\t; HddNamingABC / abc / Symbol, stored in the records of their ROM neighbours."]
    write_lines(p, L)


# ------------------------------------------------------------------- main

# ------------------------------------------------------------------- main
def main():
    args = sys.argv[1:]
    write = "--write" in args
    host = HostClasses()
    vs = {ver: Version(ver, host) for ver in VERSIONS}
    for v in vs.values():
        absn = collections.defaultdict(list)
        for k, val in v.abs.items():
            absn[val].append(k)
        v.need_funcs = {}
        v.decode(absn)
        find_misnomers(v)
        for n, val in v.need_funcs.items():
            if n in v.abs and v.abs[n] != val:
                fail("%s is 0x%x in the build, 0x%x in the %s function table" % (n, v.abs[n], val, v.ver))
    classes = class_table(vs.values())
    hd_cids = {c for v in vs.values() for c in v.hd}
    for v in vs.values():
        model_check(v, classes)
        print("%s: %d objects (%d in RAM), %d classes, %d RAM variables, %d function ids to define; "
              "layout model holds" % (v.ver, v.nobj, sum(o["ram"] for o in v.objs),
                                      len({o["cname"] for o in v.objs}), len(v.varname), len(v.need_funcs)))
    if "--macros" in args:
        open(MACROS, "w").write(macro_text(classes, hd_cids))
        print("wrote", os.path.relpath(MACROS, ROOT))
    for ver in [a for a in args if a in VERSIONS]:
        v = vs[ver]
        tt = tree_text(v, classes)
        st = state_text(v, classes)
        if write:
            open(os.path.join(v.tree, "hdae5000_ui_tree.s"), "w", encoding="latin-1").write(tt)
            splice_data_tables(v)
            splice_init_data(v, st)
            print("wrote", os.path.relpath(v.tree, ROOT))
        else:
            print("%s: %d tree lines, %d state lines (check only; --write to write)" % (
                ver, tt.count("\n"), st.count("\n")))


if __name__ == "__main__":
    main()
