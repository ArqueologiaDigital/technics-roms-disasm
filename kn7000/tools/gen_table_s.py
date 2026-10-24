#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates a byte-exact source for a KN7000 table-flash image (CPU 0x48000000).
#
#   * the uint32 offset directory at 0x0 as .long <segment> - TableRomDirectory rows;
#   * every asset segment under the label and header comment tools/table_segments.py
#     gives it: a JPEG segment as .incbin of its file in src/table/ (written there
#     with --jpg-dir; a file already there must hold the same bytes, so two builds
#     share one copy), a 4-byte marker as .byte, the GUI resource header as .long
#     <table> rows, the rest as .incbin_range; with --compare each segment is marked
#     "unchanged" or "CHANGED" against the same segment of another build;
#   * with --plugin: the SP7001 XAPR plug-in appended after the directory image,
#     as real MN10300 assembly for its code (unidasm mnemonics re-encoded by the
#     repo's mn10300_asm encoder; anything it can't reproduce stays a .byte escape),
#     its header slots and MILK reflection tables as .long <name> rows, and its
#     keystream records and known strings as bytes with the text in a comment.
#
# The result assembles with tools/kn7asm.py; `make verify-sp7001` checks it is
# byte-identical to the dump.
#
# Usage:
#   gen_table_s.py --rom T.rom --out T.s [--jpg-dir src/table]
#                  [--compare OTHER.rom --compare-label NAME]
#                  [--plugin LO:HI --plugin-code LO:HI] [--sym F.sym ...] [--title ...]
import argparse
import hashlib
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_program_s as G     # noqa: E402  (disasm_function, encoder, name_target)
import gen_symbols as GS      # noqa: E402  (find_tables)
import table_segments as TS   # noqa: E402  (what each directory segment is)

BASE = 0x48000000


def u32(d, o):
    return struct.unpack_from("<I", d, o)[0]


def directory(d):
    first = u32(d, 0)
    ents = [first]
    for i in range(1, first // 4):
        v = u32(d, 4 * i)
        if v <= ents[-1] or v > len(d):
            break
        ents.append(v)
    return ents                      # segment i = [ents[i], ents[i+1])


def load_syms(paths):
    """-> {cpu: (name, note)} from .sym files (first definition of an address wins)."""
    out = {}
    for p in paths:
        for line in open(p):
            if line.lstrip().startswith(";"):
                continue
            m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)(.*)$", line.rstrip("\n"))
            if m:
                note = m.group(3).split(";", 1)[1].strip() if ";" in m.group(3) else ""
                out.setdefault(int(m.group(1), 16), (m.group(2), note))
    return out


def hexbytes(bs):
    return ", ".join(f"0x{b:02X}" for b in bs)


def text(bs):
    s = bs.decode("latin1")
    return "".join(c if 32 <= ord(c) < 127 and c not in "#;" else f"\\x{ord(c):02X}" for c in s)



def lowhex(line):
    """Hex numbers in a comment line in lowercase (the tree's notation rule)."""
    return re.sub(r"0x[0-9A-Fa-f]+", lambda m: m.group(0).lower(), line)


def jpeg_split(seg, start):
    """-> (jpeg, pad) when `seg` (at file offset `start`) is one JPEG (FF D8 .. FF D9)
    followed only by the zero bytes that pad it to a 4-byte boundary, else None."""
    end = seg.rfind(b"\xff\xd9") + 2
    if seg[:2] != b"\xff\xd8" or end < 4:
        return None
    jpeg, pad = seg[:end], seg[end:]
    if pad != bytes(len(pad)) or len(pad) != -(start + end) % 4:
        return None
    return jpeg, pad


def jpeg_dims(jpeg):
    i = 2
    while i + 9 <= len(jpeg):
        mark, ln = jpeg[i + 1], struct.unpack_from(">H", jpeg, i + 2)[0]
        if mark in (0xC0, 0xC1, 0xC2):
            h, w = struct.unpack_from(">HH", jpeg, i + 5)
            return w, h
        i += 2 + ln
    return None


def put_jpeg(jpg_dir, name, jpeg):
    """Write <jpg_dir>/<name> unless it is already there; it must hold these bytes."""
    path = os.path.join(jpg_dir, name)
    if os.path.exists(path):
        if open(path, "rb").read() != jpeg:
            sys.exit(f"gen_table_s: {path} exists with other bytes than this build's segment")
        return
    os.makedirs(jpg_dir, exist_ok=True)
    open(path, "wb").write(jpeg)


def gui_resource_tables(d, s, e, ROMQ):
    """Segment 0: five header words (four table pointers and a 0) copied out by
    InitializeResource, zeros, then the four tables the pointers name."""
    names = ["ResBitmapTable", "ResFrameTable", "ResIconTable", "ResFontTable"]
    ptrs = [u32(d, s + 4 * k) for k in range(5)]
    offs = [p - BASE for p in ptrs[:4]]
    assert ptrs[4] == 0 and offs == sorted(offs) and s + 20 <= offs[0] and offs[-1] < e, "GUI header"
    assert d[s + 20:offs[0]] == bytes(offs[0] - s - 20), "GUI header padding"
    B = [f"    .long\t{', '.join(names)}, 0",
         f"    .space\t0x{offs[0] - s - 20:x}, 0x00"]
    for k, (nm, o) in enumerate(zip(names, offs)):
        end = offs[k + 1] if k + 1 < len(offs) else e
        B += [f"{nm}:", f"    .incbin_range\t{ROMQ}, 0x{o:06x}, 0x{end:06x}"]
    return B


def directory_image(d, dirents, ROMQ, jpg_dir, other, compare_label):
    """-> (body lines, segments changed vs `other`) for the directory and its segments."""
    nseg = len(dirents) - 1
    build = d[dirents[7]:dirents[8]].split(b"\n")[0].decode("ascii")
    segs = TS.segment_table(build)
    B = ["", "# ---- the offset directory ----",
         "# Segment i starts at TableRomDirectory + dir[i]; the last entry is the end of the",
         "# directory image. The firmware reaches segment i with",
         "# `mov (TableRomDirectory + 4 * i), Rn` then `add TABLE_ROM_BASE, Rn`.",
         "TableRomDirectory:"]
    for i in range(nseg):
        B.append(f"    .long\t{segs[i][0]} - TableRomDirectory")
    B.append("    .long\tTableRomImageEnd - TableRomDirectory")
    pad = d[4 * len(dirents):dirents[0]]
    assert set(pad) <= {0}, "directory padding is not zero"
    B += [f"    .space\t0x{dirents[0]:x} - {len(dirents)} * 4, 0x00",
          f"    .org\t0x{dirents[0]:06x}"]

    changed = 0
    for i in range(nseg):
        s, e = dirents[i], dirents[i + 1]
        seg = d[s:e]
        label, kind, jpg, notes = segs[i]
        note = ""
        if other:
            od, oe = other
            if i + 1 < len(oe):
                same = od[oe[i]:oe[i + 1]] == seg
                note = (f"; unchanged vs {compare_label}" if same else
                        f"; CHANGED vs {compare_label} (was 0x{oe[i + 1] - oe[i]:x} bytes)")
                changed += not same
            else:
                note = f"; not in {compare_label}"
                changed += 1
        B += ["", f"# dir[{i}], 0x{e - s:x} bytes{note}."] + [f"# {lowhex(n)}" for n in notes] + [f"{label}:"]
        if kind == "jpeg":
            jp = jpeg_split(seg, s)
            assert jp, f"segment {i} ({label}) is not a padded JPEG"
            jpeg, pad = jp
            w, h = jpeg_dims(jpeg)
            put_jpeg(jpg_dir, jpg, jpeg)
            B.append(f'    .incbin\t"{jpg_dir}/{jpg}"   # {w}x{h} JPEG, {len(jpeg)} bytes')
            if pad:
                B.append("    .align\t4")
        elif kind == "marker":
            assert len(seg) == 4, f"segment {i} ({label}) is not a 4-byte marker"
            shown = seg.rstrip(b"\0").decode("latin1").replace("\n", "\\n")
            B.append(f'    .byte\t{", ".join(f"0x{b:02x}" for b in seg)}   # "{shown}"')
        elif kind == "gui":
            B += gui_resource_tables(d, s, e, ROMQ)
        else:
            B.append(f"    .incbin_range\t{ROMQ}, 0x{s:06x}, 0x{e:06x}")
    B += ["", "TableRomImageEnd:"]
    return B, changed


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rom", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--title", default="KN7000 table flash image - byte-exact.")
    ap.add_argument("--jpg-dir", default="src/table",
                    help="where the JPEG segments are kept (as the source's .incbin paths name them)")
    ap.add_argument("--compare", help="another build's table image (per-segment equality)")
    ap.add_argument("--compare-label", default="the other build")
    ap.add_argument("--plugin", help="file range LO:HI of an appended XAPR plug-in")
    ap.add_argument("--plugin-code", help="file range LO:HI of the plug-in's code")
    ap.add_argument("--sym", nargs="*", default=[],
                    help=".sym files: the plug-in's own names first, then everything it calls")
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../../mame-sony-video/unidasm"))
    a = ap.parse_args()

    d = open(a.rom, "rb").read()
    ROMQ = f'"{a.rom}"'
    dirents = directory(d)
    nseg = len(dirents) - 1
    other = None
    if a.compare:
        od = open(a.compare, "rb").read()
        oe = directory(od)
        other = (od, oe)

    L = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
         "# Licensed under the terms of the GNU General Public License v3 or later",
         "#",
         f"# {a.title}",
         f"# GENERATED by tools/gen_table_s.py -- do not edit by hand.",
         "#",
         f"# Layout: a {len(dirents)}-entry uint32 offset directory at 0x0 (dir[0] = 0x{dirents[0]:X},",
         f"# dir[{nseg}] = 0x{dirents[-1]:X} = end of the directory image), zero padding to",
         f"# 0x{dirents[0]:X}, then {nseg} asset segments. Segment names and comments come from",
         "# tools/table_segments.py; the JPEG segments are files in src/table/.",
         f"# Reference image: {os.path.basename(a.rom)}, SHA-1 {hashlib.sha1(d).hexdigest()}."]
    body, changed = directory_image(d, dirents, ROMQ, a.jpg_dir, other, a.compare_label)
    cur = dirents[-1]

    used, equ = set(), {}
    if a.plugin:
        plo, phi = (int(x, 0) for x in a.plugin.split(":"))
        clo, chi = (int(x, 0) for x in a.plugin_code.split(":"))
        if set(d[cur:plo]) != {0xFF}:
            sys.exit("gen_table_s: gap before the plug-in is not erased flash")
        body += ["", "# ---- erased flash (0xFF) between the directory image and the plug-in ----",
                 f"    .space 0x{plo:06X} - 0x{cur:06X}, 0xFF", f"    .org 0x{plo:06X}"]
        pb, pc = plugin(d, plo, phi, clo, chi, a, ROMQ, used, equ)
        L += pc
        body += pb
        cur = phi
    if set(d[cur:]) <= {0xFF} and cur < len(d):
        body += ["", "# ---- erased flash (0xFF) to the end of the device ----",
                 f"    .space 0x{len(d):06X} - 0x{cur:06X}, 0xFF"]
    elif cur < len(d):
        body.append(f".incbin_range {ROMQ}, 0x{cur:06X}, 0x{len(d):06X}")
    body.append(f".org 0x{len(d):06x}   # end of image")

    L += ["", ".equ TABLE_ROM_BASE, 0x48000000",
          ".mnbase 0x48000000   # CPU address of output offset 0 (for PC-relative ops)"]
    if equ:
        L += ["", f"# {len(equ)} symbols referenced by the plug-in source (CPU addresses)"]
        for nm, v in sorted(equ.items(), key=lambda kv: kv[1]):
            L.append(f".equ {nm}, 0x{v:08X}")
    open(a.out, "w").write("\n".join(L + body) + "\n")
    print(f"wrote {a.out}: {nseg} segments" + (f" ({changed} changed vs {a.compare_label})" if other else "")
          + (f", plug-in 0x{plo:06X}..0x{phi:06X}" if a.plugin else ""))


def code_entries(d, rom, unidasm, base, clo, chi, names, labels=(), extra=()):
    """Entry points of the MN10300 code in file range [clo, chi) of an image linked
    at `base`: the named starts in `names` (except in-code labels and *_entry
    register-save entries), every `call`/`calls` target inside the range, and any
    `extra` addresses (e.g. function pointers found in data). A target 3 bytes past
    an `add -N, sp` frame setup is that function's register-save entry, not a new
    function. Updates `names` with func_<ADDR> / *_entry labels; returns sorted CPU
    addresses."""
    import subprocess
    raw = subprocess.run([unidasm, rom, "-arch", "mn10300", "-basepc", f"0x{base + clo:x}",
                          "-skip", f"0x{clo:x}", "-count", str(chi - clo)],
                         capture_output=True, text=True).stdout
    targets = {int(t, 16) for t in re.findall(r"\scalls?\s+0x([0-9a-f]+)", raw)} | set(extra)
    starts = {c for c in names if clo <= c - base < chi and c not in labels
              and not names[c].endswith("_entry")}
    for t in sorted(targets):
        o = t - base
        if not clo <= o < chi or t in starts:
            continue
        if d[o - 3:o - 1] == b"\xf8\xfe" and (t - 3) in starts:      # X+3 entry of a named X
            names.setdefault(t, names[t - 3] + "_entry")
        elif d[o - 3:o - 1] == b"\xf8\xfe":                         # unnamed X with an +3 entry
            starts.add(t - 3)
            names.setdefault(t - 3, f"func_{t - 3:08X}")
            names.setdefault(t, f"func_{t - 3:08X}_entry")
        elif t not in names or not names[t].endswith("_entry"):
            starts.add(t)
            names.setdefault(t, f"func_{t:08X}")
    return sorted(starts | {base + clo})


def emit_code(d, base, clo, chi, starts, names, notes, ROMQ, used):
    """MN10300 assembly for [clo, chi), split at `starts`: each chunk's mnemonics
    come from unidasm and are kept only where the repo's encoder reproduces the
    exact bytes (else a .byte escape); a chunk whose decode runs off its end stays
    .incbin_range. Returns (lines, chunks converted, chunks kept raw)."""
    B, nconv, nfail = [], 0, 0
    bounds = list(starts) + [base + chi]
    for i, s in enumerate(bounds[:-1]):
        e = bounds[i + 1]
        so, eo = s - base, e - base
        nm = names.get(s, f"func_{s:08X}")
        B.append(f"# {nm}  (CPU 0x{s:08X})")
        if notes.get(s):
            B.append(f"#   {notes[s]}")
        ins = G.disasm_function(d, so, eo, base)
        if ins is None:
            B.append(f".incbin_range {ROMQ}, 0x{so:06X}, 0x{eo:06X}   # decode misaligned: kept raw")
            nfail += 1
            continue
        nconv += 1
        for off, bs, mn, ops in ins:
            cpu = base + off
            if cpu != s and cpu in names:
                kind = ("register-save `call` entry" if names[cpu].endswith("_entry") else
                        notes.get(cpu, "label"))
                B.append(f"# {names[cpu]}:   ({kind})")
                used.add(cpu)
            try:
                enc = G.ASM.encode(mn, ops, cpu)
            except G.ASM.EncError:
                enc = None
            if enc == bs:
                if mn in G.CALL_MNEMS:
                    ops = G.name_target(ops, names, used)
                B.append(f"    {mn:8s}{ops}".rstrip())
            else:
                B.append(f"    .byte {hexbytes(bs)}   # {mn} {ops}".rstrip())
    return B, nconv, nfail


def plugin(d, plo, phi, clo, chi, a, ROMQ, used, equ):
    """Returns (body lines, extra header-comment lines) for the XAPR plug-in."""
    syms = load_syms(a.sym)
    own = {cpu for cpu in syms if plo <= cpu - BASE < phi}
    names = {cpu: nm for cpu, (nm, _n) in syms.items()}
    # one CPU address per name: a name that also exists elsewhere (e.g. in the
    # program image) keeps it for the plug-in's own address, others get a suffix
    by_name = {}
    for cpu, nm in sorted(names.items(), key=lambda kv: (kv[0] not in own, kv[0])):
        if nm in by_name and by_name[nm] != cpu:
            names[cpu] = f"{nm}_at_{cpu:08X}"
        else:
            by_name[nm] = cpu
    notes = {cpu: n for cpu, (_nm, n) in syms.items()}
    labels = {cpu for cpu, n in notes.items() if n.startswith("label:")}

    G.ROM, G.UNIDASM = a.rom, a.unidasm
    starts = code_entries(d, a.rom, a.unidasm, BASE, clo, chi, names, labels)
    names.setdefault(BASE + clo, f"plugin_code_{BASE + clo:08X}")

    B = ["", "# ============================================================================",
         "# SP7001 XAPR plug-in (the Key Soft Service 'KSS' application resident in",
         "# table flash). Program build 942 validates it with PlugInProbe and calls its",
         "# header slots; see kn7000_sp7001_new.sym and notes/sp7001-build-diff.md.",
         "# ============================================================================"]

    def nm_or_hex(v):
        if v in names:
            used.add(v)
            return names[v]
        return f"0x{v:08X}"

    # ---- header ----
    B += ["", f"# XaprHeader  (CPU 0x{BASE + plo:08X})",
          f"    .byte {hexbytes(d[plo:plo + 4])}   # '{text(d[plo:plo + 4])}' magic"]
    for o in range(plo + 4, clo, 4):
        v = u32(d, o)
        B.append(f"    .long {nm_or_hex(v)}   # +0x{o - plo:02X}")

    # ---- code ----
    lines, nconv, nfail = emit_code(d, BASE, clo, chi, starts, names, notes, ROMQ, used)
    B += lines

    # ---- data: reflection tables, keystream, known strings, the rest raw ----
    special = {}                                   # file off -> (end, lines)
    GS.PROGRAM_BASE = BASE
    GS._is_code = lambda v: clo <= v - BASE < chi
    for code_arr, name_arr, n in GS.find_tables(d, GS._ident_offsets(d)):
        if not chi <= code_arr < phi:
            continue
        rows = [f"# MILK reflection table: {n} code pointers, NUL, {n} name pointers (CPU 0x{BASE + code_arr:08X})"]
        for k in range(n):
            rows.append(f"    .long {nm_or_hex(u32(d, code_arr + 4 * k))}")
        rows.append("    .long 0")
        for k in range(n):
            p = u32(d, name_arr + 4 * k) - BASE
            rows.append(f"    .long 0x{u32(d, name_arr + 4 * k):08X}   # -> \"{text(d[p:d.index(0, p)])}\"")
        special[code_arr] = (name_arr + 4 * n, rows)
    for cpu, (nm, note) in syms.items():
        o = cpu - BASE
        if not chi <= o < phi - 4 or o in special:      # header/footer handled apart
            continue
        if nm == "KssKeystreamRecords":
            rows, p = [f"# {nm}  (CPU 0x{cpu:08X})", f"#   {note}"], o
            while d[p + 20] == 0 and all(c in b"0123456789abcdefghijklmnopqrstuvwxyz" for c in d[p:p + 20]):
                rows.append(f"    .byte {hexbytes(d[p:p + 21])}   # \"{text(d[p:p + 20])}\"")
                p += 21
            special[o] = (p, rows)
            used.add(cpu)
        elif note.startswith("'") or note.startswith('"'):
            end = d.index(0, o) + 1
            rows = [f"# {nm}  (CPU 0x{cpu:08X})", f"    .byte {hexbytes(d[o:end])}   # \"{text(d[o:end - 1])}\""]
            special[o] = (end, rows)
            used.add(cpu)
    foot = phi - 4
    B += ["", "# ---- plug-in data: strings, widget/descriptor tables ----"]
    cur = chi
    for o in sorted(special):
        end, rows = special[o]
        if o < cur:
            continue
        if cur < o:
            B.append(f".incbin_range {ROMQ}, 0x{cur:06X}, 0x{o:06X}")
        B += rows
        cur = end
    if cur < foot:
        B.append(f".incbin_range {ROMQ}, 0x{cur:06X}, 0x{foot:06X}")
    B += [f"# XaprFooter  (CPU 0x{BASE + foot:08X})",
          f"    .byte {hexbytes(d[foot:phi])}   # '{text(d[foot:phi])}' magic (checked by PlugInProbe)"]

    for v in used:
        equ[names[v]] = v
    for cpu in own:                               # document every plug-in name
        if names[cpu] not in equ:
            equ[names[cpu]] = cpu
    hdr = [f"# Plug-in: {nconv} code chunks converted to MN10300 assembly"
           + (f", {nfail} kept raw (misaligned decode)" if nfail else "") + "."]
    print(f"gen_table_s: plug-in code {nconv} chunks converted, {nfail} raw; "
          f"{len(special)} typed data blocks")
    return B, hdr


if __name__ == "__main__":
    main()
