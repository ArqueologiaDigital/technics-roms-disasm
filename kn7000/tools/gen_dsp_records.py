#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Extract and disassemble the Technics SX-KN7000 effects-DSP (IC306,
# Analog Devices ADSP-21065L "SHARC") programs, which are embedded in the
# MN10300 program flash as a pool of host-download records.
#
# The main CPU host-boots the DSP by streaming these records through its host
# port (index 0x98000000 / data 0x9C000000). Each record is a run of blocks:
#
#     block  = { u16 id=0x2004 (big-endian),
#                u8  mode  (0x80 = PM / program memory, 0x00 = DM / data memory),
#                u8  flag  (0xFF on the record's last block, else 0x00),
#                u16 A     (unused / 0),
#                u16 target   (destination word address in DSP memory),
#                u16 C     (unused / 0),
#                u16 len   (payload length in bytes),
#                u8  payload[len] }
#     record = one or more blocks, ended by a 12-byte all-zero terminator.
#
# PM payload = 6 bytes per 48-bit instruction word (three big-endian u16, the
# first being the most-significant). To disassemble with MAME's `unidasm
# -arch sharc` (which reads one 48-bit opcode right-justified in an 8-byte
# little-endian slot) each word is repacked as  w0<<32 | w1<<16 | w2  and
# stored little-endian. This MSW-first packing is verified: it reproduces the
# ADSP-2106x reset/interrupt vector table (IDLE at 0x8004, RTI-filled vectors).
#
# DM payload = 5 bytes per entry (a 40-bit SHARC data word; the DSP's data bus
# is 32/40-bit). Emitted as an annotated data table, not disassembled.
#
# Curated annotations are merged in from two side files, so regeneration never
# loses hand-written analysis:
#   * dsp/records.tsv     - per-record role + name + one-line note (headers)
#   * dsp/sym/recNN.sym   - per-record labels/comments: "pm:0xADDR Name ; note"
#
# Output is deterministic (no timestamps / absolute paths) so
# `make disasm-dsp && git diff --exit-code disasm/dsp` is a drift check.

import argparse
import os
import subprocess
import struct
import sys

POOL_ID = 0x2004
DSP_CPU_BASE = 0x48400000   # program flash is mapped here on the MN10300 bus


def u16be(rom, o):
    return (rom[o] << 8) | rom[o + 1]


def parse_pool(rom, start, end):
    """Return a list of records; each record is a list of block dicts."""
    records = []
    o = start
    while o < end:
        blocks = []
        while o + 12 <= end and u16be(rom, o) == POOL_ID:
            mode = rom[o + 2]
            flag = rom[o + 3]
            target = u16be(rom, o + 6)
            ln = u16be(rom, o + 10)
            blocks.append({
                "is_pm": bool(mode & 0x80),
                "mode": mode,
                "flag": flag,
                "target": target,
                "len": ln,
                "payload_off": o + 12,
            })
            o = o + 12 + ln
        # skip the inter-record terminator (zero-filled) up to the next header
        while o + 2 <= end and u16be(rom, o) != POOL_ID:
            o += 1
        if not blocks:
            break
        rec_off = blocks[0]["payload_off"] - 12
        records.append({"off": rec_off, "blocks": blocks})
    return records


def classify(blocks):
    """Heuristic role from the block signature (see the notes files for detail)."""
    tgts = [(b["is_pm"], b["target"]) for b in blocks]
    has_pm = any(b["is_pm"] for b in blocks)
    if (True, 0x8000) in tgts:
        return "kernel"           # the resident kernel carries the PM@8000 vectors
    if len(blocks) == 2 and set(tgts) == {(False, 0xC000), (True, 0x8400)} \
            and sum(b["len"] for b in blocks) == 661:
        return "probe"            # the 4 board-variant probe records (identical shape)
    if has_pm:
        return "effect"           # an effect microprogram (code loads at PM 0x8400)
    return "data"                 # parameter/coefficient-only record (DM blocks only)


def repack_pm(rom, off, nbytes):
    """6-byte MSW-first PM words -> 8-byte little-endian slots for unidasm."""
    out = bytearray()
    for i in range(nbytes // 6):
        w0 = u16be(rom, off + i * 6)
        w1 = u16be(rom, off + i * 6 + 2)
        w2 = u16be(rom, off + i * 6 + 4)
        out += struct.pack("<Q", (w0 << 32) | (w1 << 16) | w2)
    return bytes(out)


def disasm_pm(unidasm, blob, base_word):
    """Run unidasm -arch sharc; return list of (addr, hexopcode, mnemonic)."""
    import tempfile
    with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as tf:
        tf.write(blob)
        path = tf.name
    try:
        out = subprocess.run(
            [unidasm, path, "-arch", "sharc", "-basepc", "0x%X" % base_word],
            capture_output=True, text=True, check=True).stdout
    finally:
        os.unlink(path)
    rows = []
    for line in out.splitlines():
        # "8004: 0000008000000000  IDLE"
        if ":" not in line:
            continue
        addr, rest = line.split(":", 1)
        addr = addr.strip()
        rest = rest.strip()
        if not rest:
            continue
        parts = rest.split(None, 1)
        opc = parts[0]
        mnem = parts[1].strip() if len(parts) > 1 else ""
        try:
            a = int(addr, 16)
        except ValueError:
            continue
        rows.append((a, opc, mnem))
    return rows


def load_syms(symdir, idx):
    """Load dsp/sym/recNN.sym -> {(space, addr): (label, comment)}."""
    syms = {}
    path = os.path.join(symdir, "rec%02d.sym" % idx)
    if not os.path.isfile(path):
        return syms
    for raw in open(path):
        line = raw.rstrip("\n")
        if not line.strip() or line.lstrip().startswith(";"):
            continue
        body, _, comment = line.partition(";")
        toks = body.split()
        if len(toks) < 2:
            continue
        key = toks[0].lower()               # "pm:0x8004" / "dm:0x9800"
        if ":" not in key:
            continue
        space, _, addr = key.partition(":")
        try:
            a = int(addr, 16)
        except ValueError:
            continue
        syms[(space, a)] = (toks[1], comment.strip())
    return syms


def load_manifest(path):
    """dsp/records.tsv -> {idx: (role, name, note)} (curated columns)."""
    man = {}
    if not os.path.isfile(path):
        return man
    for raw in open(path):
        if not raw.strip() or raw.startswith("#"):
            continue
        cols = raw.rstrip("\n").split("\t")
        if len(cols) < 7:
            continue
        try:
            idx = int(cols[0])
        except ValueError:
            continue
        man[idx] = (cols[5], cols[6], cols[7] if len(cols) > 7 else "")
    return man


def block_summary(blocks):
    parts = []
    for b in blocks:
        kind = "PM" if b["is_pm"] else "DM"
        unit = b["len"] // 6 if b["is_pm"] else b["len"] // 5
        parts.append("%s@%04X:%d%s" % (kind, b["target"], unit,
                                       "w" if b["is_pm"] else "e"))
    return " ".join(parts)


def wrap(text, width=76):
    words, line, out = text.split(), "", []
    for w in words:
        if line and len(line) + 1 + len(w) > width:
            out.append(line)
            line = w
        else:
            line = (line + " " + w) if line else w
    if line:
        out.append(line)
    return out


def emit_record(rom, unidasm, rec, idx, role, name, note, syms, bindir, outdir):
    off = rec["off"]
    cpu = off + DSP_CPU_BASE
    fname = "rec%02d_%s_0x%08X.asm" % (idx, role, cpu)
    lines = []
    lines.append(";" + "=" * 76)
    lines.append("; KN7000 effects-DSP (IC306 ADSP-21065L) download record %02d  [%s]"
                 % (idx, role.upper()))
    if name:
        lines.append("; %s" % name)
    lines.append("; pool CPU 0x%08X / file 0x%06X   %d blocks: %s"
                 % (cpu, off, len(rec["blocks"]), block_summary(rec["blocks"])))
    if note:
        for w in wrap(note):
            lines.append("; " + w)
    lines.append("; Regenerated by tools/gen_dsp_records.py — edits go in")
    lines.append("; dsp/sym/rec%02d.sym and dsp/records.tsv, not here." % idx)
    lines.append(";" + "=" * 76)
    lines.append("")

    for b in rec["blocks"]:
        if b["len"] == 0:
            continue
        if b["is_pm"]:
            nwords = b["len"] // 6
            lines.append("; ---- PM @ 0x%04X   (%d words, flag 0x%02X) %s"
                         % (b["target"], nwords, b["flag"], "-" * 24))
            blob = repack_pm(rom, b["payload_off"], b["len"])
            binpath = os.path.join(bindir, "rec%02d_pm_%04X.bin" % (idx, b["target"]))
            open(binpath, "wb").write(blob)
            for (a, opc, mnem) in disasm_pm(unidasm, blob, b["target"]):
                sym = syms.get(("pm", a))
                if sym:
                    lbl, cmt = sym
                    lines.append("%s:%s" % (lbl, ("   ; " + cmt) if cmt else ""))
                trail = ""
                lines.append("%04x: %-16s %s%s" % (a, opc, mnem, trail))
            lines.append("")
        else:
            nent = b["len"] // 5
            lines.append("; ---- DM @ 0x%04X   (%d entries x 5 bytes, flag 0x%02X) %s"
                         % (b["target"], nent, b["flag"], "-" * 14))
            po = b["payload_off"]
            for i in range(nent):
                a = b["target"] + i
                ent = rom[po + i * 5: po + i * 5 + 5]
                val = int.from_bytes(ent, "big")
                sym = syms.get(("dm", a))
                lbl = ("%s: " % sym[0]) if sym else ""
                cmt = ("  ; " + sym[1]) if (sym and sym[1]) else ""
                lines.append("%04x: %s   %s   ; = 0x%010X%s"
                             % (a, lbl.ljust(0), " ".join("%02X" % x for x in ent),
                                val, cmt))
            # trailing partial bytes, if any
            rem = b["len"] - nent * 5
            if rem:
                tail = rom[po + nent * 5: po + b["len"]]
                lines.append("; +%d trailing byte(s): %s"
                             % (rem, " ".join("%02X" % x for x in tail)))
            lines.append("")

    open(os.path.join(outdir, fname), "w").write("\n".join(lines) + "\n")
    return fname


def main():
    ap = argparse.ArgumentParser(description="Extract+disassemble the KN7000 SHARC DSP record pool.")
    ap.add_argument("--rom", required=True)
    ap.add_argument("--pool", nargs=2, required=True, metavar=("START", "END"),
                    help="file offsets, e.g. 0x2BCEC4 0x2CE68D")
    ap.add_argument("--unidasm", default="../mame-sony-video/unidasm")
    ap.add_argument("--out", default="disasm/dsp")
    ap.add_argument("--bindir", default="build/dsp")
    ap.add_argument("--symdir", default="dsp/sym")
    ap.add_argument("--manifest", default="dsp/records.tsv")
    ap.add_argument("--init-manifest", action="store_true",
                    help="write a skeleton records.tsv if it does not exist, then stop")
    ap.add_argument("--base", type=lambda s: int(s, 0), default=DSP_CPU_BASE)
    args = ap.parse_args()

    rom = open(args.rom, "rb").read()
    start = int(args.pool[0], 0)
    end = int(args.pool[1], 0)
    records = parse_pool(rom, start, end)

    if args.init_manifest:
        if os.path.exists(args.manifest):
            sys.stderr.write("refusing to overwrite existing %s\n" % args.manifest)
            return 1
        os.makedirs(os.path.dirname(args.manifest) or ".", exist_ok=True)
        with open(args.manifest, "w") as f:
            f.write("# idx\trom_off\tcpu_addr\tbody_bytes\tnblocks\trole\tname\tnote\n")
            for idx, rec in enumerate(records):
                role = classify(rec["blocks"])
                body = sum(12 + b["len"] for b in rec["blocks"])
                f.write("%d\t0x%06X\t0x%08X\t%d\t%d\t%s\t\t\n"
                        % (idx, rec["off"], rec["off"] + args.base, body,
                           len(rec["blocks"]), role))
        sys.stderr.write("wrote skeleton %s (%d records)\n" % (args.manifest, len(records)))
        return 0

    os.makedirs(args.out, exist_ok=True)
    os.makedirs(args.bindir, exist_ok=True)
    man = load_manifest(args.manifest)

    index = []
    for idx, rec in enumerate(records):
        auto_role = classify(rec["blocks"])
        role, name, note = man.get(idx, (auto_role, "", ""))
        role = role or auto_role
        syms = load_syms(args.symdir, idx)
        fname = emit_record(rom, args.unidasm, rec, idx, role, name, note,
                            syms, args.bindir, args.out)
        index.append((idx, rec, role, name, fname))

    # index.asm — a manifest listing of the whole pool
    il = []
    il.append("; KN7000 effects-DSP (IC306 ADSP-21065L) — download-record pool index")
    il.append("; pool: program flash 0x%08X..0x%08X (file 0x%06X..0x%06X), %d records"
              % (start + args.base, end + args.base, start, end, len(records)))
    il.append("; PM words are 48-bit (SHARC); DM entries are 40-bit data words.")
    il.append("; Regenerated by tools/gen_dsp_records.py.")
    il.append(";")
    il.append("; idx  role     CPU addr     blocks")
    for (idx, rec, role, name, fname) in index:
        il.append("; %3d  %-7s  0x%08X  %s%s"
                  % (idx, role, rec["off"] + args.base, block_summary(rec["blocks"]),
                     ("   " + name) if name else ""))
    open(os.path.join(args.out, "index.asm"), "w").write("\n".join(il) + "\n")

    sys.stderr.write("wrote %d record listings + index.asm to %s\n"
                     % (len(records), args.out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
