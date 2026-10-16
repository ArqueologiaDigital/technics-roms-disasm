#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Port a symbol file recovered for one KN7000 firmware build to another build
# of the same firmware (e.g. program 941 / table 84 -> SP7001's 942 / 83).
#
# Question it answers: "which of the names we already recovered for the old
# build still apply to the new one, and at what address?" -- so reverse-
# engineering effort is spent only on what actually changed.
#
# Each address is translated in its own space:
#   program flash 0x48400000.. : exact file-offset map (tools/offset_map.py)
#   table flash   0x48000000.. : exact file-offset map of the two table images
#   library 0x4C000000..       : the boot copies the library image from program
#                                flash file offset LIB_BASE to 0x4C000000, so a
#                                lib address goes lib -> old file -> new file -> lib
#   work RAM      0x50000000.. : majority vote over the absolute RAM references
#                                in code the two builds share (new globals shift
#                                later ones; |delta| < 0x1000 rejects misaligned-
#                                window noise); an address is ported only when it is
#                                itself referenced, or lies strictly inside a run of
#                                referenced addresses that all moved by one delta
#   anything else              : unchanged (I/O, fixed windows)
# An entry that cannot be ported (its bytes were deleted, or its RAM delta is
# ambiguous) is written commented-out with the reason, never guessed.
#
# --check-recovered re-derives the reflection-table names directly from the new
# program image (tools/gen_symbols.py), an end-to-end test of the offset map:
# every name must sit exactly at its ported address, unless the disagreement is
# explained -- the old and new bytes are identical (an ambiguous run, e.g. of
# 3-byte stubs) or the build's table now points into newly inserted code (the
# function was rewritten). Explained cases take the build's own address; an
# unexplained one aborts.
#
# Usage:
#   port_symbols.py OLD_PROG NEW_PROG OLD_TABLE NEW_TABLE IN.sym OUT.sym
#                   [--inc OUT.inc] [--title TEXT]
#                   [--check-recovered LO:HI [LO:HI ...]]   (new code file ranges)
import argparse
import bisect
import collections
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from offset_map import OffsetMap, _trim   # noqa: E402

PROG, TABLE, LIB, RAM = 0x48400000, 0x48000000, 0x4C000000, 0x50000000
OLD_LIB_FILE_BASE = 0x3B8FD1          # notes/library-rom-loading.md (build 941)


def space(a):
    if PROG <= a < PROG + 0x400000:
        return "prog"
    if TABLE <= a < TABLE + 0x400000:
        return "table"
    if LIB <= a < LIB + 0x100000:
        return "lib"
    if RAM <= a < RAM + 0x1000000:
        return "ram"
    return "other"


def ram_map(pmap, A, B):
    """old RAM address -> delta, from aligned references in 1:1 program runs."""
    votes = collections.defaultdict(collections.Counter)
    for a0, a1, b0 in pmap.blocks:
        for i in range(a0, a1 - 3):
            va = struct.unpack_from("<I", A, i)[0]
            if not RAM <= va < RAM + 0x1000000:
                continue
            vb = struct.unpack_from("<I", B, b0 + i - a0)[0]
            if RAM <= vb < RAM + 0x1000000:
                votes[va][vb - va] += 1
    out = {}
    for va, c in votes.items():
        (d, n), tot = c.most_common(1)[0], sum(c.values())
        # |d| < 0x1000: a misaligned 4-byte window over a relocated program
        # pointer or over opcode bytes can look like a consistently-moved RAM
        # address with a large delta; real moves come from a few new globals
        if n >= 2 and n >= 0.8 * tot and abs(d) < 0x1000:
            out[va] = d
    return out


class Porter:
    def __init__(self, old_prog, new_prog, old_tab, new_tab):
        self.A, self.B = _trim(old_prog), _trim(new_prog)
        self.pmap = OffsetMap(old_prog, new_prog)
        self.tmap = OffsetMap(old_tab, new_tab)
        self.new_lib_base = self.pmap.map(OLD_LIB_FILE_BASE)
        self.ram = ram_map(self.pmap, self.A, self.B)
        self._ram_keys = sorted(self.ram)

    def _ram(self, a):
        if a in self.ram:
            return a + self.ram[a], None
        i = bisect.bisect_right(self._ram_keys, a) - 1
        if i < 0 or i + 1 >= len(self._ram_keys):
            return None, "RAM address outside the referenced range"
        lo, hi = self._ram_keys[i], self._ram_keys[i + 1]
        if self.ram[lo] == self.ram[hi]:
            return a + self.ram[lo], None
        return None, (f"RAM delta ambiguous (0x{lo:08X} moved {self.ram[lo]:+d}, "
                      f"0x{hi:08X} moved {self.ram[hi]:+d})")

    def port(self, a):
        """-> (new_addr, None) or (None, reason)"""
        sp = space(a)
        if sp == "prog":
            n = self.pmap.map(a - PROG)
            return (PROG + n, None) if n is not None else (None, "program bytes deleted in new build")
        if sp == "table":
            n = self.tmap.map(a - TABLE)
            return (TABLE + n, None) if n is not None else (None, "table bytes not present in new build")
        if sp == "lib":
            n = self.pmap.map(a - LIB + OLD_LIB_FILE_BASE)
            if n is None:
                return None, "library bytes deleted in new build"
            return LIB + n - self.new_lib_base, None
        if sp == "ram":
            return self._ram(a)
        return a, None


LINE = re.compile(r"^(\s*)0x([0-9A-Fa-f]+)(\s+)(\S+)(.*)$")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("old_prog")
    ap.add_argument("new_prog")
    ap.add_argument("old_table")
    ap.add_argument("new_table")
    ap.add_argument("in_sym")
    ap.add_argument("out_sym")
    ap.add_argument("--inc", help="also write .equ lines for every ported entry")
    ap.add_argument("--title", default="ported symbols")
    ap.add_argument("--check-recovered", nargs="+", metavar="LO:HI",
                    help="new-build code file ranges for gen_symbols' reflection scan")
    args = ap.parse_args()

    P = Porter(*(open(p, "rb").read() for p in
                 (args.old_prog, args.new_prog, args.old_table, args.new_table)))

    # The new build's own reflection tables are authoritative for the names they
    # carry. Where they disagree with the offset map, accept the build's address
    # only when the disagreement is explained; anything else is a map error.
    override, notes = {}, []
    if args.check_recovered:
        import gen_symbols as g
        rngs = [tuple(int(x, 0) for x in r.split(":")) for r in args.check_recovered]
        g._is_code = lambda v: any(lo <= v - g.PROGRAM_BASE < hi for lo, hi in rngs)
        g.CODE_LO, g.CODE_HI = min(r[0] for r in rngs), max(r[1] for r in rngs)
        direct = {nm: cpu for cpu, _o, nm in g.recover_symbols(open(args.new_prog, "rb").read())}
        olds = {}
        for line in open(args.in_sym):
            m = LINE.match(line.rstrip("\n"))
            if m and not line.lstrip().startswith(";"):
                olds.setdefault(m.group(4), int(m.group(2), 16))
        old_sorted = sorted(olds.values())
        agree = 0
        for nm, cpu in sorted(direct.items(), key=lambda kv: kv[1]):
            if nm not in olds:
                notes.append(("new name", nm, None, cpu)); override[nm] = cpu
                continue
            oa = olds[nm]
            pa, _why = P.port(oa)
            if pa == cpu:
                agree += 1
                continue
            nf, of = cpu - PROG, oa - PROG
            i = bisect.bisect_right(old_sorted, oa)
            L = max(1, min(16, (old_sorted[i] - oa) if i < len(old_sorted) else 16))
            if any(a <= nf < b for a, b in P.pmap.inserted):
                kind = "rewritten: now names new code"
            elif P.A[of:of + L] == P.B[nf:nf + L]:
                kind = "identical-bytes run, alignment ambiguous"
            else:
                sys.exit(f"port_symbols: {nm}: offset map says "
                         f"{('0x%08X' % pa) if pa else 'deleted'}, new build's table says "
                         f"0x{cpu:08X}, and the bytes differ -- map error")
            override[nm] = cpu
            notes.append((kind, nm, oa, cpu))
        print(f"  reflection names: {len(direct)} in the new build's tables, {agree} exactly "
              f"at the ported address, {len(override)} taken from the build's own table:")
        for kind, nm, oa, cpu in notes:
            print(f"    {nm:22s} {('0x%08X' % oa) if oa else '(new)':>10} -> 0x{cpu:08X}  {kind}")

    out, equ, stats, unported = [], [], collections.Counter(), []
    ported_at = {}
    for line in open(args.in_sym):
        m = LINE.match(line.rstrip("\n"))
        if not m or line.lstrip().startswith(";"):
            out.append(line.rstrip("\n"))
            continue
        ind, hexa, sep, name, rest = m.groups()
        a = int(hexa, 16)
        n, why = (override[name], None) if name in override else P.port(a)
        sp = space(a)
        if n is None:
            stats[sp + " unported"] += 1
            unported.append((a, name, why))
            out.append(f"; UNPORTED ({why}): 0x{a:08X}{sep}{name}{rest}")
            continue
        stats[sp + (" moved" if n != a else " same")] += 1
        ported_at[name] = n
        out.append(f"{ind}0x{n:08X}{sep}{name}{rest}")
        note = rest.split(";", 1)[1].strip() if ";" in rest else ""
        equ.append(f".equ {name}, 0x{n:08X}" + (f"   # {note}" if note else ""))

    hdr = [f"; {args.title}",
           f"; Ported from {os.path.basename(args.in_sym)} by tools/port_symbols.py: every",
           "; address below is translated into the new build; addresses quoted inside",
           "; the trailing comments are still the OLD build's coordinates.",
           ";"]
    open(args.out_sym, "w").write("\n".join(hdr + out) + "\n")
    if args.inc:
        os.makedirs(os.path.dirname(args.inc) or ".", exist_ok=True)
        open(args.inc, "w").write(
            f"# {args.title} (generated by tools/port_symbols.py -- do not edit)\n\n"
            + "\n".join(equ) + "\n")

    print(f"port_symbols: {args.in_sym} -> {args.out_sym}")
    print(f"  library image: old file 0x{OLD_LIB_FILE_BASE:06X} -> new file 0x{P.new_lib_base:06X}")
    print(f"  RAM references voted: {len(P.ram)} addresses, deltas "
          f"{dict(collections.Counter(P.ram.values()).most_common(6))}")
    for k in sorted(stats):
        print(f"  {k:22s} {stats[k]}")
    for a, name, why in unported[:20]:
        print(f"  UNPORTED 0x{a:08X} {name}: {why}")



if __name__ == "__main__":
    main()
