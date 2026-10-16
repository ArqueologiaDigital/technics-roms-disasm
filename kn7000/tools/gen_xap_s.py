#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates a byte-exact source for an SP7001 .XAP plug-in file (e.g. BASEEXT.XAP,
# the Key Soft Service "base extension" on the SP7001 table floppy).
#
# The table-flash XAPR plug-in loads an .XAP by reading the WHOLE file -- exactly
# 0x1D000 bytes -- to the fixed work-RAM address 0x5029B000 and calling its first
# byte; so the file is an absolute image linked at that address: code from offset
# 0, then data (strings, pointer tables, the C runtime's tables), then 0xFF up to
# 0x1D000 (the space its variables occupy at run time).
#
#   * code: MN10300 assembly via the shared emitter in gen_table_s.py (unidasm
#     mnemonics re-encoded by the repo's encoder; .byte escapes otherwise), split at
#     every call target, at the function pointers found in its data, and at names;
#   * names: --sym files, plus every routine that is BYTE-IDENTICAL (start to its
#     first return) to a named routine of the firmware it runs on (--fw-*), e.g.
#     the soft-float and printf runtime the plug-in links its own copy of;
#   * data: pointer runs as .long rows, NUL-terminated strings as bytes with their
#     text, the rest .incbin_range; the 0xFF tail as .space.
#
# Usage:
#   gen_xap_s.py --xap F.xap --out F.s --base 0x5029B000 --code LO:HI [--sym F.sym ...]
#                [--fw-rom P.rom --fw-r1-end N --fw-lib-file N --fw-sym S.sym ...] [--title ...]
import argparse
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_program_s as G          # noqa: E402
import gen_table_s as T            # noqa: E402

RETS = ("ret", "retf", "rets", "rti")


def index(unidasm, path, base_pc, skip, count):
    """{pc: (bytes, mnemonic)} from one linear unidasm pass."""
    out = subprocess.run([unidasm, path, "-arch", "mn10300", "-basepc", f"0x{base_pc:x}",
                          "-skip", f"0x{skip:x}", "-count", str(count)],
                         capture_output=True, text=True).stdout
    ix = {}
    for m in re.finditer(r"^([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s+(\S+)", out, re.M):
        ix[int(m.group(1), 16)] = (bytes.fromhex(m.group(2).replace(" ", "")), m.group(3))
    return ix


def body(ix, start):
    """bytes of the routine at `start` up to and including its first return."""
    out, pc = b"", start
    while pc in ix and len(out) <= 0x400:
        b, mn = ix[pc]
        out += b
        pc += len(b)
        if mn in RETS:
            return out
    return None


def firmware_routines(rom, r1_end, lib_file, syms, unidasm):
    """{routine bytes (to first return): name} for the uniquely-named routines of
    the firmware image `rom` (program flash at 0x48400000, code region 1 up to file
    `r1_end`; the library image at file `lib_file`, run at 0x4C000000)."""
    d = open(rom, "rb").read()
    end = len(d.rstrip(b"\xff"))
    ix = index(unidasm, rom, 0x48400080, 0x80, r1_end - 0x80)
    ix.update(index(unidasm, rom, 0x4C000000, lib_file, end - lib_file))
    out = {}
    for cpu, (nm, _n) in T.load_syms(syms).items():
        if nm.endswith("_entry"):
            continue
        b = body(ix, cpu)
        if b and len(b) >= 8:
            out.setdefault(b, set()).add(nm)
    return {b: sorted(n)[0] for b, n in out.items() if len(n) == 1}


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--xap", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--base", type=lambda v: int(v, 0), required=True)
    ap.add_argument("--code", required=True, help="file range LO:HI holding code")
    ap.add_argument("--sym", nargs="*", default=[])
    ap.add_argument("--fw-rom", help="the firmware program image the plug-in runs on")
    ap.add_argument("--fw-r1-end", type=lambda v: int(v, 0), help="its code region 1 end (file)")
    ap.add_argument("--fw-lib-file", type=lambda v: int(v, 0), help="its library image (file)")
    ap.add_argument("--fw-sym", nargs="*", default=[], help="its symbol files")
    ap.add_argument("--title", default="SP7001 .XAP plug-in - byte-exact.")
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../mame-sony-video/unidasm"))
    a = ap.parse_args()

    d = open(a.xap, "rb").read()
    base = a.base
    clo, chi = (int(x, 0) for x in a.code.split(":"))
    ROMQ = f'"{a.xap}"'
    G.ROM, G.UNIDASM = a.xap, a.unidasm

    syms = T.load_syms(a.sym)
    names = {cpu: nm for cpu, (nm, _n) in syms.items()}
    notes = {cpu: n for cpu, (_nm, n) in syms.items()}
    labels = {cpu for cpu, n in notes.items() if n.startswith("label:")}

    # end of initialised data = last byte that is not erased flash/fill
    dend = len(d)
    while dend > chi and d[dend - 1] == 0xFF:
        dend -= 1
    dend = (dend + 3) & ~3

    # function pointers in the data: aligned words pointing at instruction starts
    xix = index(a.unidasm, a.xap, base + clo, clo, chi - clo)
    starts_lin = set(xix)
    fptr = set()
    for o in range(chi + (-chi) % 4, dend, 4):
        w = struct.unpack_from("<I", d, o)[0]
        if w in starts_lin:
            fptr.add(w)
    starts = T.code_entries(d, a.xap, a.unidasm, base, clo, chi, names, labels, fptr)
    names.setdefault(base + clo, "XapEntry")

    # name routines that are byte-identical copies of named firmware routines
    copies = {}
    if a.fw_rom:
        fw = firmware_routines(a.fw_rom, a.fw_r1_end, a.fw_lib_file, a.fw_sym, a.unidasm)
        for s in starts:
            b = body(xix, s)
            if b and b in fw and names.get(s, "").startswith("func_"):
                names[s] = fw[b]
                notes.setdefault(s, f"byte-identical copy of the firmware's {fw[b]}")
                copies[s] = fw[b]
        # names must stay unique within this file
        seen = {}
        for s in sorted(names):
            nm = names[s]
            if nm in seen and seen[nm] != s:
                names[s] = f"{nm}_at_{s:08X}"
            else:
                seen[nm] = s

    used = set()
    code, nconv, nfail = T.emit_code(d, base, clo, chi, starts, names, notes, ROMQ, used)

    # ---- data ----
    def ptr_ok(w):
        return base <= w < base + len(d)

    def nm_or_hex(w):
        if w in names:
            used.add(w)
            return names[w]
        return f"0x{w:08X}"

    def is_str(o):
        e = d.find(b"\x00", o, min(dend, o + 512))
        if e - o < 2:
            return 0
        s = d[o:e]
        if all(0x20 <= c < 0x7F or c in (9, 10, 13) or 0xC0 <= c <= 0xFC for c in s) \
                and sum(0x20 <= c < 0x7F for c in s) * 2 >= len(s):
            return e + 1 - o
        return 0

    D = ["", "# ---- data: strings, pointer tables, C-runtime tables ----"]
    o, raw0, nstr, nptr = chi, chi, 0, 0

    def flush(upto):
        if upto > raw0:
            D.append(f".incbin_range {ROMQ}, 0x{raw0:06X}, 0x{upto:06X}")
    while o < dend:
        if o % 4 == 0 and o + 8 <= dend and ptr_ok(struct.unpack_from("<I", d, o)[0]) \
                and ptr_ok(struct.unpack_from("<I", d, o + 4)[0]):
            flush(o)
            rows = []
            while o + 4 <= dend and o % 4 == 0 and ptr_ok(struct.unpack_from("<I", d, o)[0]):
                rows.append(nm_or_hex(struct.unpack_from("<I", d, o)[0]))
                o += 4
            D.append(f"# pointer table (CPU 0x{base + o - 4 * len(rows):08X}, {len(rows)} entries)")
            for i in range(0, len(rows), 4):
                D.append(f"    .long {', '.join(rows[i:i + 4])}")
            nptr += 1
            raw0 = o
            continue
        n = is_str(o) if (o == chi or d[o - 1] in (0, 0xFF)) else 0
        if n:
            flush(o)
            D.append(f"    .byte {T.hexbytes(d[o:o + n])}   # \"{T.text(d[o:o + n - 1])}\"")
            nstr += 1
            o += n
            raw0 = o
            continue
        o += 1
    flush(dend)
    tail = ["", "# ---- 0xFF to the 0x1D000-byte load window: the plug-in's variables at run time ----",
            f"    .space 0x{len(d):06X} - 0x{dend:06X}, 0xFF"] if set(d[dend:]) <= {0xFF} else \
           [f".incbin_range {ROMQ}, 0x{dend:06X}, 0x{len(d):06X}"]

    equ = {names[v]: v for v in used}
    for cpu in names:
        if base <= cpu < base + len(d) and not names[cpu].startswith("func_"):
            equ.setdefault(names[cpu], cpu)
    L = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
         "# Licensed under the terms of the GNU General Public License v3 or later",
         "#",
         f"# {a.title}",
         "# GENERATED by tools/gen_xap_s.py -- do not edit by hand.",
         "#",
         f"# Linked for, and loaded at, CPU 0x{base:08X}: the table-flash XAPR plug-in's",
         "# loader reads the whole 0x1D000-byte file there and calls its first byte",
         "# (XapEntry). Code 0x%06X..0x%06X (%d chunks as MN10300 assembly%s), data to"
         % (clo, chi, nconv, f", {nfail} raw" if nfail else ""),
         f"# 0x{dend:06X}, then 0xFF. {len(copies)} routines are named as byte-identical copies",
         "# of the firmware's (its own copy of the same C runtime).",
         "",
         f".mnbase 0x{base:08X}   # CPU address of output offset 0 (for PC-relative ops)"]
    if equ:
        L += ["", f"# {len(equ)} symbols (CPU addresses)"]
        L += [f".equ {nm}, 0x{v:08X}" for nm, v in sorted(equ.items(), key=lambda kv: kv[1])]
    L += ["", "# ---- code ----"] + code + D + tail + [f".org 0x{len(d):06X}   # end of file"]
    open(a.out, "w").write("\n".join(L) + "\n")
    print(f"wrote {a.out}: code {nconv} chunks as asm ({nfail} raw), {len(copies)} routines named "
          f"as firmware copies; data: {nstr} strings, {nptr} pointer tables; data end 0x{dend:06X}")


if __name__ == "__main__":
    main()
