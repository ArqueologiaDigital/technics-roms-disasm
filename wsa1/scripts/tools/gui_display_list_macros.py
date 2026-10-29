#!/usr/bin/env python3
"""gui_display_list_macros.py -- respell the WSA1's display-list records as the macros of include/wsa1_gui.inc.

QUESTION IT ANSWERS
  "Can every display-list record in prom_a and prom_b be written as ONE line that names its drawing service,
   its geometry (x / y / w / h in panel pixels), its text, its bitmap and its live variable, instead of an
   opcode byte, a length byte and a run of anonymous `.short` words -- with the ROM bytes unchanged?"

  The records are the WSA1's whole GUI: there is no string table and no widget class system; every label,
  box, line, bitmap and live readout on the 320 x 240 LCD is one record of a display list, run by one of two
  interpreters in prom_b (wsa1/notes/FINDINGS-ui-display-list.md, FINDINGS-ui-display-list-interpreter-b.md).

WHAT IT READS
  Every module file of prom_a and prom_b (bytes, latin-1 round trip: the files hold raw high bytes in
  `.ascii`).  A record HEADER is a `.byte <op>, <len>` line whose comment names the record's handler,
  `op NN, N bytes ... handler 0xF31xxx` -- the comment every display-list emitter in this tree wrote.  The
  handler decides the interpreter (A: 0xF31A3A..0xF31AEB, B: 0xF31B21..0xF31D20), the opcode decides the
  record kind.  The BODY is the `.byte` / `.short` / `.long` / `.ascii` lines that follow until exactly
  <len> bytes are accounted for.  A record is left untouched (and reported) when a label, a directive of
  another kind, or a line that straddles the record's end comes first.

WHAT IT WRITES (--apply)
  One macro line per record, e.g.
      dl_text8x14	x=176, y=82, text="TONE LAYER"
      dl_box		x0=12, y0=31, x1=60, y1=50
      dlb_string	var=ModelingPage_Fields+3, mask=0x80, shift=7, svc=LCDSVC_DrawText8x14, table=DLTable_OffOn, width=3, x=64, y=156
  Geometry is decoded from the record's words: a text / blit position is a display-RAM byte offset
  (LCD_Svc_06_DrawText8x14, LCD_Svc_03_BlitColumns: `IX` = offset within the layer) and the SED1330 is
  programmed with AP = 40 bytes per line (LCD_Init_SED1330's SYSTEM SET), so offset = y * 40 + x / 8; the
  four-word records are (X0, Y0, X1, Y1) in pixels (LCD_X0..LCD_Y1, read by LCD_Svc_00_DrawLine and the
  box / fill services).  A numeric pointer that lands exactly on a label of the same image is spelled with
  that label (the ELF's symbol table); a 16-bit variable address that is an `.equ` of include/wsa1_ram.inc
  is spelled with its name.  The comments the emitters generated (`op NN ... -> handler`, `+0x02 source
  variable ...`, `character codes below 0x20`, `text at row R, col C`, bare addresses) restate what the
  macro now says and are dropped; any other comment is kept on the macro line.

  The gate (make gate-wsa1) is the only certificate: the macros compute every length byte themselves, so a
  record whose text or fields were mis-read cannot rebuild the ROM.

RUN (inside wsa1/)
  make all                                                     # the ELFs give the symbol tables
  python3 scripts/tools/gui_display_list_macros.py             # dry run: what would change, per file
  python3 scripts/tools/gui_display_list_macros.py --stats     # opcode / kind statistics
  python3 scripts/tools/gui_display_list_macros.py --apply     # rewrite, then: make gate-wsa1
"""
import argparse
import collections
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.join(os.path.expanduser("~"), "compartilhado", "llvm-project", "build", "bin", "llvm-nm")

A_HANDLERS = {0xF31A3A, 0xF31A52, 0xF31A75, 0xF31A9F, 0xF31AAC, 0xF31ABE, 0xF31ACE, 0xF31AEB}
B_HANDLERS = {0xF31B21, 0xF31B39, 0xF31B57, 0xF31B86, 0xF31BA1, 0xF31BD7, 0xF31C14, 0xF31C56, 0xF31C9E,
              0xF31D20}

# interpreter A: opcode -> (macro, shape).  The opcode IS the SWI7 service number (DLHandler_IX_Text:
# `ld A,(XIY)` / `swi 7`); the macro is named after the service in SWI7_ServiceTable.
A_KIND = {
    0x00: ("dl_line", "rect"), 0x01: ("dl_hline", "rect"), 0x02: ("dl_vline", "rect"),
    0x05: ("dl_fill_rect", "rect"), 0x09: ("dl_box", "rect"), 0x0A: ("dl_box_shadow2", "rect"),
    0x11: ("dl_hline_dither", "rect"), 0x12: ("dl_vline_dashed", "rect"), 0x13: ("dl_box_patterned", "rect"),
    0x15: ("dl_line_dashed", "rect"), 0x1B: ("dl_erase_rect", "rect"), 0x22: ("dl_box_shadow1", "rect"),
    0x06: ("dl_text8x14", "text"), 0x07: ("dl_text8x16", "text"), 0x08: ("dl_text16x16", "text"),
    0x16: ("dl_kana_halfwidth", "text"), 0x19: ("dl_katakana16", "text"), 0x1A: ("dl_kanji_a16", "text"),
    0x1D: ("dl_hiragana16", "text"), 0x1F: ("dl_kanji_b16", "text"), 0x20: ("dl_text8x10", "text"),
    0x21: ("dl_text16x24", "text"), 0x1E: ("dl_scroll_layer", "text"), 0x18: ("dl_svc18_unimplemented", "text"),
    0x17: ("dl_text8x8_packed", "ptext"), 0x1C: ("dl_text16x16_packed", "ptext"),
    0x0B: ("dl_plot", "point"), 0x0E: ("dl_clear_area", "clear"),
    0x03: ("dl_bitmap", "blit"), 0x04: ("dl_read_area", "blit"),
    0x23: ("dl_value_glyph", "glyph"),
}
B_KIND = {
    0x00: "dlb_number", 0x06: "dlb_number16", 0x05: "dlb_number_signed",
    0x09: "dlb_number_xy", 0x0A: "dlb_number16_xy", 0x0B: "dlb_number_signed_xy",
    0x02: "dlb_string", 0x07: "dlb_string_xy",
    0x03: "dlb_rect_entry", 0x08: "dlb_rect_entry_op08", 0x04: "dlb_area_entry",
    0x01: "dlb_centred_span",
}
B_LEN = {0x00: 10, 0x06: 10, 0x05: 11, 0x09: 12, 0x0A: 12, 0x0B: 13, 0x02: 15, 0x07: 17, 0x03: 11, 0x08: 11,
         0x04: 11, 0x01: 12}
# SWI7 service numbers (SWI7_ServiceTable, prom_a 0xF8E9C6) -> the equate wsa1_gui.inc defines
SVC = {0x00: "DrawLine", 0x01: "DrawHLine", 0x02: "DrawVLine", 0x03: "BlitColumns", 0x04: "ReadColumns",
       0x05: "FillRect", 0x06: "DrawText8x14", 0x07: "DrawText8x16", 0x08: "DrawText16x16", 0x09: "DrawBox",
       0x0A: "DrawBoxShadow2", 0x0B: "PlotPoint", 0x0C: "SetLayersOn", 0x0D: "SetLayersFlashing",
       0x0E: "ClearColumns", 0x0F: "SetPanel2Layer", 0x10: "SetPanel3Layer", 0x11: "DrawHLineDither",
       0x12: "DrawVLineDashed", 0x13: "DrawBoxPatterned", 0x14: "FillRectPattern", 0x15: "DrawLineDashed",
       0x16: "DrawKatakanaHalfWidth", 0x17: "DrawText8x8Packed", 0x19: "DrawKatakana16x16",
       0x1A: "DrawKanjiSetA16x16", 0x1B: "EraseRect", 0x1C: "DrawText16x16Packed", 0x1D: "DrawHiragana16x16",
       0x1E: "ScrollCurrentLayer", 0x1F: "DrawKanjiSetB16x16", 0x20: "DrawText8x10", 0x21: "DrawText16x24",
       0x22: "DrawBoxShadow1"}

HDR = re.compile(r'^\s*\.byte\s+(0x[0-9A-Fa-f]{1,2}|\d+)\s*,\s*(0x[0-9A-Fa-f]{1,2}|\d+)\s*;(.*)$')
HDR_CMT = re.compile(r'\bop ([0-9A-Fa-f]{2}), (\d+) bytes\b.*?\bhandler 0x([0-9A-Fa-f]{6})')
BODY = re.compile(r'^\s*\.(byte|short|long|ascii)\s+(.*)$')
LABEL = re.compile(r'^\s*([A-Za-z_.$][\w.$]*)\s*:')

# body / header comments the emitters generated; they restate the record and are dropped
DROP_CMT = [
    re.compile(r'^[0-9A-Fa-f]{6}$'),
    re.compile(r'^[0-9A-Fa-f]{6}\s+(op|B op) [0-9A-Fa-f]{2}, \d+ bytes.*$'),
    re.compile(r'^(B )?op [0-9A-Fa-f]{2}, \d+ bytes.*handler 0x[0-9A-Fa-f]{6}.*$'),
    re.compile(r'^\+0x[0-9A-Fa-f]{2} .*$'),
    re.compile(r'^\+\d+\s.*$'),
    re.compile(r'^([0-9A-Fa-f]{6}\s+)?(character|glyph) codes below 0x20$'),
    re.compile(r'^operand bytes the handler does not read$'),   # an A-layout remark; every macro field is read
]


def drop_comment(c):
    c = c.strip()
    return not c or any(p.match(c) for p in DROP_CMT)


def split_comment(line):
    """(code, comment) -- the first `;` outside a string."""
    q = False
    i = 0
    while i < len(line):
        ch = line[i]
        if q:
            if ch == '\\':
                i += 2
                continue
            if ch == '"':
                q = False
        elif ch == '"':
            q = True
        elif ch == ';':
            return line[:i], line[i + 1:]
        i += 1
    return line, None


def parse_string(s):
    """GNU-as string body (between the quotes) -> bytes."""
    out = bytearray()
    i = 0
    while i < len(s):
        ch = s[i]
        if ch == '\\':
            n = s[i + 1]
            if n in '01234567':
                j = i + 1
                while j < len(s) and j < i + 4 and s[j] in '01234567':
                    j += 1
                out.append(int(s[i + 1:j], 8) & 0xFF)
                i = j
                continue
            m = {'n': 10, 't': 9, 'r': 13, 'b': 8, 'f': 12, '"': 34, '\\': 92}
            if n in m:
                out.append(m[n])
                i += 2
                continue
            if n == 'x':
                j = i + 2
                while j < len(s) and s[j] in '0123456789abcdefABCDEF':
                    j += 1
                out.append(int(s[i + 2:j], 16) & 0xFF)
                i = j
                continue
            raise ValueError("escape \\%s" % n)
        out.append(ord(ch) & 0xFF)
        i += 1
    return bytes(out)


def parse_ascii_operands(ops):
    """`.ascii "a", "b"` -> bytes, or None."""
    out = b""
    rest = ops.strip()
    while rest:
        if not rest.startswith('"'):
            return None
        i = 1
        while i < len(rest):
            if rest[i] == '\\':
                i += 2
                continue
            if rest[i] == '"':
                break
            i += 1
        else:
            return None
        out += parse_string(rest[1:i])
        rest = rest[i + 1:].strip()
        if rest.startswith(','):
            rest = rest[1:].strip()
        elif rest:
            return None
    return out


NUM = re.compile(r'^(0x[0-9A-Fa-f]+|\d+)$')


def cells_of(kind, ops):
    """A body line -> list of cells: ('b', value) per byte, or ('sym', size, expr)."""
    if kind == 'ascii':
        b = parse_ascii_operands(ops)
        if b is None:
            return None
        return [('b', x) for x in b]
    size = {'byte': 1, 'short': 2, 'long': 4}[kind]
    out = []
    for item in [x.strip() for x in ops.split(',')]:
        if not item:
            return None
        if NUM.match(item):
            v = int(item, 0)
            if v >= 1 << (8 * size):
                return None
            for k in range(size):
                out.append(('b', (v >> (8 * k)) & 0xFF))
        else:
            if kind == 'byte':
                return None
            out.append(('sym', size, item))
    return out


class Rec:
    def __init__(self, op, ln, interp, cells, comments):
        self.op, self.len, self.interp, self.cells, self.comments = op, ln, interp, cells, comments
        self.offs = []          # cell start offsets
        o = 0
        for c in cells:
            self.offs.append(o)
            o += 1 if c[0] == 'b' else c[1]

    def field(self, off, size):
        """int, or an expression string, or raise."""
        if off in self.offs:
            i = self.offs.index(off)
            c = self.cells[i]
            if c[0] == 'sym':
                if c[1] != size:
                    raise ValueError("symbolic cell of size %d at +%d, field size %d" % (c[1], off, size))
                return c[2]
            v = 0
            for k in range(size):
                c = self.cells[i + k]
                if c[0] != 'b':
                    raise ValueError("field +%d straddles a symbol" % off)
                v |= c[1] << (8 * k)
            return v
        raise ValueError("field +%d starts inside a symbolic cell" % off)

    def text(self, off):
        out = bytearray()
        i = self.offs.index(off) if off in self.offs else None
        if i is None:
            raise ValueError("text start inside a cell")
        for c in self.cells[i:]:
            if c[0] != 'b':
                raise ValueError("symbol inside text")
            out.append(c[1])
        return bytes(out)


def qstring(b):
    s = []
    for x in b:
        if x == 0x22:
            s.append('\\"')
        elif x == 0x5C:
            s.append('\\\\')
        elif 0x20 <= x < 0x7F:
            s.append(chr(x))
        else:
            s.append('\\%03o' % x)
    return '"' + ''.join(s) + '"'


class Ctx:
    def __init__(self, image):
        self.image = image
        self.syms = {}           # address -> label (same image only)
        elf = os.path.join(ROOT, "rebuilt_ROMs", "wsa1_%s.llvm.elf" % image)
        if not os.path.exists(elf):
            sys.exit("build first: %s missing (make all)" % elf)
        out = subprocess.run([NM, "--defined-only", elf], capture_output=True, text=True, check=True).stdout
        cand = collections.defaultdict(list)
        for l in out.splitlines():
            p = l.split()
            if len(p) == 3 and p[1] in "tTdD":
                if p[2].startswith(".L") or p[2].startswith("$"):
                    continue
                cand[int(p[0], 16)].append(p[2])
        for a, names in cand.items():
            # prefer names that are not address placeholders
            names.sort(key=lambda n: (bool(re.search(r'[0-9A-F]{6}', n)), len(n)))
            self.syms[a] = names[0]
        self.ram = {}
        for l in open(os.path.join(ROOT, "include", "wsa1_ram.inc"), encoding="latin-1"):
            m = re.match(r'^\s*\.equ\s+(\w+),\s*(0x[0-9A-Fa-f]+|\d+)', l)
            if m:
                self.ram.setdefault(int(m.group(2), 0), m.group(1))
        self.sorted_syms = None
        byname = {n: a for a, n in self.ram.items()}
        self.ram_spelled = {}
        for f in glob.glob(os.path.join(ROOT, "prom_[ab]", "**", "*.s"), recursive=True):
            for m in re.finditer(r'\b([A-Za-z_]\w*)\s*\+\s*(0x[0-9A-Fa-f]+|\d+)\b',
                                 open(f, "rb").read().decode("latin-1")):
                if m.group(1) in byname:
                    a = byname[m.group(1)] + int(m.group(2), 0)
                    if a not in self.ram:
                        self.ram_spelled.setdefault(a, "%s+%d" % (m.group(1), int(m.group(2), 0)))
        self.lo, self.hi = {"prom_a": (0xF80000, 0x1000000), "prom_b": (0xF00000, 0xF80000)}[image]

    def ptr(self, v):
        """A 32-bit pointer field: the label at that address in this image; else the RAM `.equ`; else
        `Label+off` of the nearest label below it in this image (within 0x400 bytes: the target is inside
        that labelled object); else the number."""
        if isinstance(v, str):
            return v
        if self.lo <= v < self.hi:
            if v in self.syms:
                return self.syms[v]
            if self.sorted_syms is None:
                self.sorted_syms = sorted(a for a in self.syms if self.lo <= a < self.hi)
            import bisect
            k = bisect.bisect_right(self.sorted_syms, v) - 1
            if k >= 0 and v - self.sorted_syms[k] <= 0x400:
                base = self.sorted_syms[k]
                return "%s+0x%x" % (self.syms[base], v - base)
        elif v < 0x100000 and v in self.ram:
            return self.ram[v]
        return "0x%08x" % v

    def var(self, v):
        """A 16-bit variable address: its `.equ` in include/wsa1_ram.inc; else `Name+n` when the tree's
        sources already spell that address so (e.g. DisplayListB_Stage+1); else the number."""
        if isinstance(v, str):
            return v
        if v == 0:
            return "DLB_NoVariable"         # mask 0 with address 0: include/wsa1_gui.inc
        if v in self.ram:
            return self.ram[v]
        if v in self.ram_spelled:
            return self.ram_spelled[v]
        return "0x%04x" % v


def odd_geometry(args):
    """True when a reading puts a corner or a position off the panel (x > 320 or y > 240)."""
    d = dict(a.split("=", 1) for a in args if "=" in a and not a.startswith("text="))
    for kx, ky in (("x", "y"), ("x0", "y0"), ("x1", "y1")):
        try:
            if int(d.get(kx, "0"), 0) > 320 or int(d.get(ky, "0"), 0) > 240:
                return True
        except ValueError:
            pass
    return False


def xy_of_offset(v):
    return (v % 40) * 8, v // 40


def num(v):
    return v if isinstance(v, str) else str(v)


def hexb(v):
    return v if isinstance(v, str) else "0x%02x" % v


def svc(v):
    if isinstance(v, str):
        return v
    return "LCDSVC_" + SVC[v] if v in SVC else "0x%02x" % v


def emit(rec, ctx):
    """-> (macro, [args]) or raise ValueError."""
    op, f = rec.op, rec.field
    if rec.interp == 'A':
        if op not in A_KIND:
            raise ValueError("A op %02X has no macro" % op)
        mac, shape = A_KIND[op]
        if shape == 'rect':
            if rec.len != 10:
                raise ValueError("rect len")
            return mac, ["x0=%s" % num(f(2, 2)), "y0=%s" % num(f(4, 2)), "x1=%s" % num(f(6, 2)), "y1=%s" % num(f(8, 2))]
        if shape == 'text':
            pos = f(2, 2)
            if isinstance(pos, str):
                raise ValueError("symbolic text position")
            x, y = xy_of_offset(pos)
            return mac, ["x=%d" % x, "y=%d" % y, "text=%s" % qstring(rec.text(4))]
        if shape == 'ptext':
            return mac, ["x=%s" % num(f(2, 2)), "y=%s" % num(f(4, 2)), "text=%s" % qstring(rec.text(6))]
        if shape == 'point':
            if rec.len != 6:
                raise ValueError("point len")
            return mac, ["x=%s" % num(f(2, 2)), "y=%s" % num(f(4, 2))]
        if shape == 'clear':
            if rec.len != 8:
                raise ValueError("clear len")
            pos = f(2, 2)
            x, y = xy_of_offset(pos)
            return mac, ["x=%d" % x, "y=%d" % y, "w=%d" % (f(4, 2) * 8), "h=%d" % f(6, 2)]
        if shape == 'blit':
            if rec.len != 12:
                raise ValueError("blit len")
            pos = f(6, 2)
            x, y = xy_of_offset(pos)
            key = "bitmap" if op == 3 else "buffer"
            return mac, ["%s=%s" % (key, ctx.ptr(f(2, 4))), "x=%d" % x, "y=%d" % y, "w=%d" % (f(8, 2) * 8), "h=%d" % f(10, 2)]
        if shape == 'glyph':
            if rec.len != 5:
                raise ValueError("glyph len")
            x, y = xy_of_offset(f(3, 2))
            return mac, ["glyph=%d" % f(2, 1), "x=%d" % x, "y=%d" % y]
    else:
        if op not in B_KIND:
            raise ValueError("B op %02X has no macro" % op)
        if rec.len != B_LEN[op]:
            raise ValueError("B op %02X len %d" % (op, rec.len))
        mac = B_KIND[op]
        head = ["var=%s" % ctx.var(f(2, 2)), "mask=%s" % hexb(f(4, 1)), "shift=%s" % num(f(5, 1))]
        if op == 0x01:
            return mac, head + ["x0=%s" % num(f(6, 2)), "x1=%s" % num(f(8, 2)), "y1=%s" % num(f(10, 2))]
        head.append("svc=%s" % svc(f(6, 1)))
        if op in (0x00, 0x06):
            x, y = xy_of_offset(f(7, 2))
            return mac, head + ["x=%d" % x, "y=%d" % y, "digits=%s" % num(f(9, 1))]
        if op == 0x05:
            x, y = xy_of_offset(f(7, 2))
            return mac, head + ["x=%d" % x, "y=%d" % y, "digits=%s" % num(f(9, 1)), "signflag=%s" % hexb(f(10, 1))]
        if op in (0x09, 0x0A):
            return mac, head + ["x=%s" % num(f(7, 2)), "y=%s" % num(f(9, 2)), "digits=%s" % num(f(11, 1))]
        if op == 0x0B:
            return mac, head + ["x=%s" % num(f(7, 2)), "y=%s" % num(f(9, 2)), "digits=%s" % num(f(11, 1)),
                                "signflag=%s" % hexb(f(12, 1))]
        if op == 0x02:
            x, y = xy_of_offset(f(13, 2))
            return mac, head + ["table=%s" % ctx.ptr(f(7, 4)), "width=%s" % num(f(11, 2)), "x=%d" % x, "y=%d" % y]
        if op == 0x07:
            return mac, head + ["table=%s" % ctx.ptr(f(7, 4)), "width=%s" % num(f(11, 2)),
                                "x=%s" % num(f(13, 2)), "y=%s" % num(f(15, 2))]
        if op in (0x03, 0x08, 0x04):
            return mac, head + ["table=%s" % ctx.ptr(f(7, 4))]
    raise ValueError("unhandled")


REATTRIBUTED = []
MIXED = []
LABEL_LINE = re.compile(r'^\s*[A-Za-z_.$][\w.$]*\s*:')


def parse_records(lines):
    """[(first line, one past last line, Rec or None, why)] for every record header in a file."""
    out = []
    i = 0
    while i < len(lines):
        m = HDR.match(lines[i])
        hc = HDR_CMT.search(m.group(3)) if m else None
        if not (m and hc):
            i += 1
            continue
        op, ln = int(m.group(1), 0), int(m.group(2), 0)
        handler = int(hc.group(3), 16)
        interp = 'A' if handler in A_HANDLERS else 'B' if handler in B_HANDLERS else None
        if interp is None or int(hc.group(1), 16) != op or int(hc.group(2)) != ln:
            out.append((i, i + 1, None, "header disagrees with its comment"))
            i += 1
            continue
        comments = [m.group(3)]
        cells = [('b', op), ('b', ln)]
        j = i + 1
        size = 2
        why = None
        while size < ln:
            if j >= len(lines):
                why = "file ends inside the record"
                break
            code, cmt = split_comment(lines[j])
            bm = BODY.match(code)
            cs = cells_of(bm.group(1), bm.group(2)) if bm else None
            if cs is None:
                why = "body not a whole run of data lines"
                break
            n = sum(1 if c[0] == 'b' else c[1] for c in cs)
            if size + n > ln:
                why = "a body line straddles the record's end"
                break
            cells += cs
            size += n
            if cmt is not None:
                comments.append(cmt)
            j += 1
        if why:
            out.append((i, i + 1, None, why))
            i += 1
            continue
        out.append((i, j, Rec(op, ln, interp, cells, comments), None))
        i = j
    return out


def runs_of(lines, recs):
    """Group record indices into RUNS: records with nothing but other records' lines between them."""
    runs, cur = [], []
    for k, (i, j, rec, why) in enumerate(recs):
        if cur:
            pi, pj = recs[cur[-1]][0], recs[cur[-1]][1]
            if i != pj:
                runs.append(cur)
                cur = []
        cur.append(k)
    if cur:
        runs.append(cur)
    return runs


def decide(rec, ctx, addr, audit):
    """-> (interp, macro, args, how) or raise ValueError."""
    if addr is not None and addr in audit:  # (kept for reference; process() decides per run)
        rec.interp = audit[addr]
        mac, args = emit(rec, ctx)
        return mac, args, "audit"
    first = rec.interp
    try:
        mac, args = emit(rec, ctx)
        return mac, args, "comment"
    except (ValueError, KeyError) as e:
        # An emitter that attributed a list to interpreter A by its layout alone left some of
        # interpreter B's records commented as A's.  Each of B's opcodes has exactly ONE length
        # (DisplayListB_HandlerTable's handlers; FINDINGS-ui-display-list-interpreter-b.md), so a
        # record whose A reading is impossible and whose length is B's own is read as B's.
        if first != 'A' or B_LEN.get(rec.op) != rec.len:
            raise ValueError(str(e))
        rec.interp = 'B'
        mac, args = emit(rec, ctx)
        return mac, args, "length"


def process(path, ctx, stats, fails, addrs, audit):
    raw = open(path, "rb").read().decode("latin-1")
    lines = raw.split("\n")
    recs = parse_records(lines)
    plan = {}                       # first line -> (one past last, text)
    for run in runs_of(lines, recs):
        made, bad = [], None
        info = []
        for k in run:
            i, j, rec, why = recs[k]
            if rec is None:
                bad = (i, why)
                break
            commented = rec.interp
            forced = audit.get(addrs.get((path, i)))
            res = {}
            for interp in ('A', 'B'):
                rec.interp = interp
                try:
                    res[interp] = emit(rec, ctx)
                except (ValueError, KeyError):
                    pass
            rec.interp = commented
            info.append([i, j, rec, commented, forced, res, None, None])
        if not bad:
            # 1. the length audit's call-site attribution decides where it has one
            # 2. else the comment, unless that reading is impossible and B's is not: B's opcodes have ONE
            #    length each, so such a record is B's ("length")
            # 3. a B record makes its neighbours B too while they read as B ("adjacent"): the two
            #    interpreters' lists are disjoint (0 records reached by both, the audit), and every list
            #    found this way was walked by an emitter that only knew interpreter A's layout
            for r in info:
                i, j, rec, commented, forced, res = r[:6]
                if forced:
                    r[6], r[7] = forced, "audit"
                elif commented == 'A' and 'A' in res and odd_geometry(res['A'][1]) and 'B' in res and \
                        B_LEN.get(rec.op) == rec.len and not odd_geometry(res['B'][1]):
                    # 4. an A reading whose corners lie off the 320 x 240 panel, where B's reading is on it
                    r[6], r[7] = 'B', "geometry"
                elif commented in res:
                    r[6], r[7] = commented, "comment"
                elif commented == 'A' and 'B' in res and B_LEN.get(rec.op) == rec.len:
                    r[6], r[7] = 'B', "length"
            changed = True
            while changed:
                changed = False
                for n, r in enumerate(info):
                    if r[6] != 'B' or r[7] == "audit" and False:
                        continue
                    for m in (n - 1, n + 1):
                        if 0 <= m < len(info):
                            q = info[m]
                            if q[6] != 'B' and q[7] != "audit" and 'B' in q[5] and B_LEN.get(q[2].op) == q[2].len:
                                q[6], q[7] = 'B', "adjacent"
                                changed = True
            for r in info:
                i, j, rec, commented, forced, res, interp, how = r
                if interp is None or interp not in res:
                    bad = (i, "%s op %02X: no reading" % (commented, rec.op))
                    break
                rec.interp = interp
                mac, args = res[interp]
                made.append((i, j, rec, mac, args, how, commented))
        if bad:
            # one record that cannot be read leaves its whole run as it is: a list walked from the
            # wrong start reads as plausible text for a while before it fails
            fails.append((path, bad[0] + 1, bad[1] + ("  (run of %d records left as is)" % len(run))))
            continue
        kinds = {m[2].interp for m in made}
        if len(kinds) > 1:
            MIXED.append((path, made[0][0] + 1, len(made),
                          collections.Counter((m[6], m[2].interp, m[5]) for m in made)))
        for i, j, rec, mac, args, how, commented in made:
            comments = rec.comments
            if rec.interp != commented:
                stats[("%s->%s by %s" % (commented, rec.interp, how), rec.op, mac)] += 1
                REATTRIBUTED.append((path, i + 1, rec.op, how))
                comments = [c for c in comments if not re.search(r'handler 0x', c)]
            keep = ["var: " + m.group(1) for m in (re.search(r'source variable -- (.*)$', c) for c in comments) if m]
            keep += [c.strip() for c in comments if not drop_comment(c)]
            keep = [re.sub(r'^[0-9A-Fa-f]{6}\s+', '', c) for c in keep]
            keep = [c for c in keep if c and not re.match(r'^(B )?op [0-9A-Fa-f]{2}, \d+ bytes', c)]
            if odd_geometry(args):
                keep.append("TODO: this position lies off the 320 x 240 panel, so this record's framing is "
                            "unconfirmed (no call site walks to it; gui_display_list_macros.py)")
            tail = ("\t; " + "; ".join(keep)) if keep else ""
            plan[i] = (j, "\t%s\t%s%s" % (mac, ", ".join(args), tail))
            stats[(rec.interp, rec.op, mac)] += 1
    out = []
    i = 0
    while i < len(lines):
        if i in plan:
            j, text = plan[i]
            out.append(text)
            i = j
        else:
            out.append(lines[i])
            i += 1
    return "\n".join(out), len(plan), raw


PROBE_DIR = os.path.join(os.environ.get("TMPDIR") or os.path.join(os.path.expanduser("~"), "compartilhado", "tmp"),
                         "gui_display_list_probe")


def probe_addresses(images):
    """{(path, line index): ROM address} of every record header, by assembling a scratch copy of the tree
    with a probe label in front of each header (labels emit no bytes)."""
    import shutil
    llvm = os.path.dirname(NM)
    if os.path.isdir(PROBE_DIR):
        assert PROBE_DIR.endswith("gui_display_list_probe")
        shutil.rmtree(PROBE_DIR)
    for d in ("include", "kernel", "dsp", "maincpu") + tuple(images):
        shutil.copytree(os.path.join(ROOT, d), os.path.join(PROBE_DIR, d))
    where = {}
    n = 0
    for image in images:
        for path in sorted(glob.glob(os.path.join(ROOT, image, "modules", "*.s"))):
            lines = open(path, "rb").read().decode("latin-1").split("\n")
            heads = {i for i, j, rec, why in parse_records(lines)}
            out = []
            for i, l in enumerate(lines):
                if i in heads:
                    out.append("GuiProbe_%d:" % n)
                    where["GuiProbe_%d" % n] = (path, i)
                    n += 1
                out.append(l)
            dst = os.path.join(PROBE_DIR, os.path.relpath(path, ROOT))
            open(dst, "wb").write("\n".join(out).encode("latin-1"))
    addrs = {}
    for image in images:
        obj = os.path.join(PROBE_DIR, image + ".o")
        elf = os.path.join(PROBE_DIR, image + ".elf")
        subprocess.run([os.path.join(llvm, "llvm-mc"), "-triple=tlcs900", "-filetype=obj", "-I", ".", "-I", image,
                        "-o", obj, os.path.join(image, "wsa1_%s.s" % image)], cwd=PROBE_DIR, check=True,
                       stderr=subprocess.DEVNULL)
        subprocess.run([os.path.join(llvm, "ld.lld"), "-e", "0", "-T", os.path.join(image, image + ".ld"), "-o", elf,
                        obj], cwd=PROBE_DIR, check=True)
        for l in subprocess.run([NM, elf], capture_output=True, text=True, check=True).stdout.splitlines():
            p = l.split()
            if len(p) == 3 and p[2] in where:
                addrs[where[p[2]]] = int(p[0], 16)
    return addrs


def audit_attribution():
    """{record address: 'A' | 'B'} from notes/prom_b_dl_length_audit.py --records: each record is
    attributed to the interpreter of the call sites whose walk reaches it (0 records are reached by both)."""
    out = subprocess.run([sys.executable, os.path.join(ROOT, "notes", "prom_b_dl_length_audit.py"), "--records"],
                         capture_output=True, text=True, check=True, cwd=ROOT).stdout
    att = {}
    for l in out.splitlines():
        m = re.match(r'^\s*([AB]) only\s+0x([0-9A-Fa-f]{6})\s', l)
        if m:
            att[int(m.group(2), 16)] = m.group(1)
    return att


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--stats", action="store_true")
    ap.add_argument("--fails", action="store_true", help="list every record left untouched")
    a = ap.parse_args()
    stats = collections.Counter()
    fails = []
    total = 0
    addrs = probe_addresses(("prom_a", "prom_b"))
    audit = audit_attribution()
    print("record headers located: %d; records the length audit attributes by call site: %d" % (len(addrs), len(audit)))
    for image in ("prom_a", "prom_b"):
        ctx = Ctx(image)
        for path in sorted(glob.glob(os.path.join(ROOT, image, "modules", "*.s"))):
            new, n, old = process(path, ctx, stats, fails, addrs, audit)
            total += n
            if n:
                print("%-70s %5d records" % (os.path.relpath(path, ROOT), n))
            if a.apply and new != old:
                open(path, "wb").write(new.encode("latin-1"))
    print("records respelled: %d   left untouched: %d" % (total, len(fails)))
    if a.stats:
        for (interp, op, mac), n in sorted(stats.items()):
            print("  %s op %02X  %-26s %5d" % (interp, op, mac, n))
    if a.fails:
        for p, l, op, how in REATTRIBUTED:
            print("  re-read (%s) %s:%d  op %02X" % (how, os.path.relpath(p, ROOT), l, op))
        for p, l, n, c in MIXED:
            print("  mixed run %s:%d  %d records  %s" % (os.path.relpath(p, ROOT), l, n, dict(c)))
    if a.fails or (fails and not a.apply):
        for p, l, why in fails[:400 if a.fails else 20]:
            print("  untouched %s:%d  %s" % (os.path.relpath(p, ROOT), l, why))


if __name__ == "__main__":
    main()
