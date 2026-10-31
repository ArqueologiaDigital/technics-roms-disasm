#!/usr/bin/env python3
"""List every MN89304 register write the KN5000 sources make, routine by routine.

Question answered: which VGA / MN89304 registers does each init routine program, with
which values, and in which order (kn5000-ezo)?

It reads the LLVM sources as bytes and follows the register-write idioms they use:
the VGA_WRITE / VGA_SEQUENCER / VGA_GFX_CONTROLLER / VGA_COLOR_CRTC / VGA_ATTRIBUTE
macros (and their `_`-prefixed and RET_ twins), and the open-coded form
`ld(w) wa, PORT` / `ld(w) bc, VALUE` / `calr|jrl|call _Write_VGA_Register`.  A
`_VGA_READ 0x3da` / read of 0x3da resets the attribute flip-flop, as on a VGA.
Port writes are then decoded into register writes:
  0x3c4/0x3c5 sequencer, 0x3ce/0x3cf graphics controller, 0x3d4/0x3d5 CRTC,
  0x3c0 attribute (index/data alternating), 0x3c8/0x3c9 DAC, others as plain ports.
Writes to sequencer 0x0a/0x0b/0x0c are also shown with the sequencer 0x09 value
written last ("seq9=N"), because the firmware always programs them in that order.

Only straight-line code is followed: a value set in one branch and written after a
join is reported as the last value seen in source order, so check branchy routines
(VGA_Initialize's region test for seq 0x0f) by hand.

Usage:
  python3 notes/open4-kn5000-b/display/probes/vga_register_writes.py \
      v10/maincpu/shared/vga_init.s v10/maincpu/display/graphics_text_vga.s
  python3 .../vga_register_writes.py --ext-table FILE...   # the seq9-indexed table only
"""
import re
import sys

CONST = {}
for path in ("v10/maincpu/shared/vga_constants.s",):
    try:
        for line in open(path, "rb").read().decode("latin-1").splitlines():
            m = re.match(r"\s*\.equ\s+(\w+),\s*(0x[0-9a-fA-F]+|\d+)", line)
            if m:
                CONST[m.group(1)] = int(m.group(2), 0)
    except FileNotFoundError:
        pass


def val(tok):
    tok = tok.strip().split(":")[0]
    if tok in CONST:
        return CONST[tok]
    return int(tok, 0)


MAC = re.compile(r"\s*(RET_)?_?(VGA_WRITE|VGA_SEQUENCER|VGA_GFX_CONTROLLER|VGA_COLOR_CRTC|VGA_ATTRIBUTE|VGA_READ)\s+([^;]*)")
LDWA = re.compile(r"\s*ldw?\s+wa,\s*(\d[0-9xa-fA-F]*)(:i3)?\s*(;.*)?$")
LDBC = re.compile(r"\s*ldw?\s+bc,\s*(\d[0-9xa-fA-F]*)(:i3)?\s*(;.*)?$")
WR = re.compile(r"\s*(calr|jrl|call|jrl\s+t,)\s+_?Write_VGA_Register")
RD = re.compile(r"\s*(calr|call)\s+_?Read_VGA_Register")
LABEL = re.compile(r"^([A-Za-z_][\w]*):")
PAIRS = {"VGA_SEQUENCER": (0x3c4, 0x3c5), "VGA_GFX_CONTROLLER": (0x3ce, 0x3cf),
         "VGA_COLOR_CRTC": (0x3d4, 0x3d5), "VGA_ATTRIBUTE": (0x3c0, 0x3c0)}


def port_writes(path):
    """Yield (label, lineno, 'W'|'R', port, value)."""
    label, wa, bc = None, None, None
    for n, raw in enumerate(open(path, "rb").read().decode("latin-1").splitlines(), 1):
        if raw.lstrip().startswith(".macro"):
            label = "<macro>"
            continue
        m = LABEL.match(raw)
        if m and not m.group(1).startswith("."):
            label = m.group(1)
            continue
        if label == "<macro>":
            continue
        m = MAC.match(raw)
        if m:
            kind, args = m.group(2), [a for a in m.group(3).split(",") if a.strip()]
            if kind == "VGA_WRITE":
                yield label, n, "W", val(args[0]), val(args[1])
            elif kind == "VGA_READ":
                yield label, n, "R", val(args[0]), None
            else:
                a, d = PAIRS[kind]
                yield label, n, "W", a, val(args[0])
                yield label, n, "W", d, val(args[1])
            continue
        m = LDWA.match(raw)
        if m:
            wa = int(m.group(1), 0)
            continue
        m = LDBC.match(raw)
        if m:
            bc = int(m.group(1), 0)
            continue
        if WR.match(raw) and wa is not None and bc is not None:
            yield label, n, "W", wa, bc
        elif RD.match(raw) and wa is not None:
            yield label, n, "R", wa, None


def decode(path):
    """Yield (label, lineno, register-name, value)."""
    idx = {0x3c4: None, 0x3ce: None, 0x3d4: None}
    attr_flip, attr_idx, seq9 = 0, None, None
    for label, n, rw, port, v in port_writes(path):
        if rw == "R":
            if port == 0x3da:
                attr_flip = 0
            continue
        if port in idx:
            idx[port] = v
        elif port in (0x3c5, 0x3cf, 0x3d5):
            i = idx[port - 1]
            name = {0x3c5: "seq", 0x3cf: "gc", 0x3d5: "crtc"}[port]
            reg = f"{name} 0x{i:02x}"
            if port == 0x3c5 and i == 0x09:
                seq9 = v
            if port == 0x3c5 and i in (0x0a, 0x0b, 0x0c) and seq9 is not None:
                reg += f" [seq9=0x{seq9:02x}]"
            yield label, n, reg, v
        elif port == 0x3c0:
            if attr_flip == 0:
                attr_idx = v
            else:
                yield label, n, f"attr 0x{attr_idx:02x}", v
            attr_flip ^= 1
        else:
            yield label, n, f"port 0x{port:03x}", v


def main(argv):
    ext = "--ext-table" in argv
    files = [a for a in argv if not a.startswith("--")]
    for path in files:
        print(f"## {path}")
        last = None
        table = {}
        for label, n, reg, v in decode(path):
            if label != last:
                if ext and table:
                    dump_table(last, table)
                table = {}
                if not ext:
                    print(f"\n{label}:")
                last = label
            if ext:
                m = re.match(r"seq 0x0([abc]) \[seq9=0x([0-9a-f]+)\]", reg)
                if m:
                    table.setdefault(int(m.group(2), 16), {})[m.group(1)] = v
            else:
                print(f"  {path}:{n:<5} {reg:<22} = 0x{v:02x}")
        if ext and table:
            dump_table(last, table)


def dump_table(label, table):
    print(f"\n{label}: seq 0x09 index -> data written to seq 0x0a / 0x0b / 0x0c")
    for k in sorted(table):
        e = table[k]
        cell = lambda c: f"0x{e[c]:02x}" if c in e else "  - "
        print(f"  0x{k:02x}: {cell('a')} {cell('b')} {cell('c')}")


if __name__ == "__main__":
    main(sys.argv[1:])
