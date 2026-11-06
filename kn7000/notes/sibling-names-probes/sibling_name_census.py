#!/usr/bin/env python3
"""sibling_name_census: how many routine entries of each MN10300 sibling source are
still placeholders, and how many RAM operands are still numbers?

Question it answers (register items N-02383279 / N-a6b3dca1 / N-391deec6 and
N-8fce01b1 / N-cccf0416 / N-dc17693c): the before / after figures of lane
open11/sibling-names, measured the same way on every tree.

Signals read, from the committed generated sources only (no image, no unidasm):
  * <model>/notes/conversion-stats.txt, line "entries": gen_image_s.py's own count of
    entries, named, derived <name>_entry and func_ (that last figure counts the
    func_<ADDR> routine starts AND their func_<ADDR>_entry register-save entries:
    it is the figure the register items quote);
  * <model>/src/program.s: labels `func_<ADDR>:` (routine starts still unnamed) and
    `func_<ADDR>_entry:`;
  * <model>/src/program.s instruction lines (tab-led, not a directive or comment;
    the comment after ';' is dropped): every 8-digit hex literal is an operand
    written as a number.  Counted by region:
        work RAM   0x50000000..0x50FFFFFF (the cached view)
        uncached   0x90000000..0x90FFFFFF (the same RAM through the uncached view)
        backup     0x84000000..0x84FFFFFF (the battery SRAM, KN6000 / KN6500)
    with the number of distinct addresses.  The KN2400's RAM-linked code (0x50120000..
    0x5018DFFA and the 3-byte stub at 0x5018FFF0, RamSectionsCopy) is code, not
    variables: its numbers are counted apart ("RAM code").  A name (any symbol, symbol+offset) is
    not a number and is not counted.  The 2026-11-02 figures in the READMEs
    (19,019 / 19,055 / 22,483) were counted by a script that was not committed and
    cannot be reproduced exactly; this probe is the instrument from 2026-11-06 on.

usage (from the repo root):
  python3 -I kn7000/notes/sibling-names-probes/sibling_name_census.py [MODEL ...]
  MODEL = kn6000 kn6500 kn2400 hdsx3 (default: all four)
"""
import re
import sys

MODELS = sys.argv[1:] or ["kn6000", "kn6500", "kn2400", "hdsx3"]
HEX = re.compile(rb"(?<![\w.])0x([0-9a-fA-F]{8})\b")
REGIONS = (("work RAM 0x50", 0x50), ("uncached 0x90", 0x90), ("backup 0x84", 0x84), ("RAM code", None))
RAM_CODE = {"kn2400": ((0x50120000, 0x5018DFFA), (0x5018FFF0, 0x5018FFF3))}


def census(m):
    st = open(f"{m}/notes/conversion-stats.txt").read()
    ent = re.search(r"^entries\s+(\d+) \((\d+) named, (\d+) derived <name>_entry, (\d+) func_\)", st, re.M)
    src = open(f"{m}/src/program.s", "rb").read()
    starts = len(re.findall(rb"^func_[0-9A-F]{8}:", src, re.M))
    entries = len(re.findall(rb"^func_[0-9A-F]{8}_entry:", src, re.M))
    cnt = {k: 0 for k, _t in REGIONS}
    dist = {k: set() for k, _t in REGIONS}
    for ln in src.split(b"\n"):
        if not ln.startswith(b"\t"):
            continue
        s = ln.lstrip()
        if s.startswith((b".", b";", b"#")):
            continue
        code = ln.split(b";", 1)[0]
        for h in HEX.findall(code):
            v = int(h, 16)
            if any(lo <= v < hi for lo, hi in RAM_CODE.get(m, ())):
                cnt["RAM code"] += 1
                dist["RAM code"].add(v)
                continue
            for k, top in REGIONS:
                if v >> 24 == top:
                    cnt[k] += 1
                    dist[k].add(v)
    return ent, starts, entries, cnt, dist


def main():
    head = ["model", "entries", "named", "derived", "func_ (stats)", "func_ starts", "func_ _entry"] + \
        [f"{k} ops / addrs" for k, _t in REGIONS]
    rows = []
    for m in MODELS:
        ent, starts, entries, cnt, dist = census(m)
        rows.append([m] + [f"{int(x):,}" for x in ent.groups()] + [f"{starts:,}", f"{entries:,}"]
                    + [f"{cnt[k]:,} / {len(dist[k]):,}" for k, _t in REGIONS])
    w = [max(len(r[i]) for r in rows + [head]) for i in range(len(head))]
    print("| " + " | ".join(h.ljust(w[i]) for i, h in enumerate(head)) + " |")
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in rows:
        print("| " + " | ".join(c.ljust(w[i]) for i, c in enumerate(r)) + " |")


if __name__ == "__main__":
    main()
