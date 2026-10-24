#!/usr/bin/env python3
"""issue_triage_measurements.py -- the measurements quoted when open issues are closed as done.

QUESTION ANSWERED: for the open issues in .beads/issues.jsonl whose goal is a property of the
source tree ("no LABEL_ left", "no numeric jump targets", "images/MIDI/fonts extracted", "jump
tables documented"), does the tree meet it today?  Each closing comment quotes one line of this
script's output, so the claim can be re-checked by re-running it.  First used 2026-10-24
(wave1/hygiene, item 9).

RUN
    python3 scripts/analysis/issue_triage_measurements.py

WHAT EACH LINE MEANS
    label_defs       column-0 `LABEL_<hex>:` definitions in the authoritative KN5000 trees
                     (v10, v9, v7 maincpu; v142 subcpu; subcpu/boot; table_data; custom_data;
                     hdae5000).  0 = every placeholder has a semantic name.
    label_refs       any `LABEL_<hex>` token outside comments in the same trees.
    numeric_targets  call/jp/calr/jr/jrl/djnz whose target is a number, not a symbol
                     (comment-stripped, conditional forms included).
    tmp94c241_refs   live (non-archive) .s files and Makefiles that still name tmp94c241.inc.
    images           .bin files in v10/maincpu/images and table_data/images, how many have a
                     sibling .png (the round-trip source), and `.incbin "images/...` lines in v10.
    demo_midi        .mid files in table_data/includes/demo_presets/midi, and how many have a
                     well-formed Standard MIDI File chunk structure (MThd + the declared
                     number of MTrk chunks, filling the file).  Not a playback test.
    fonts_bdf        .bdf files in extracted_fonts/.
    dispatch_census  the newest committed docs/coverage/dispatch-census-*.json: per KN5000
                     image, not-used tables and new targets (both must be 0).

.s files are read as bytes (CLAUDE.md: they carry raw high bytes in .ascii).
"""
import glob
import json
import os
import re

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ["v10/maincpu", "v9/maincpu", "v7/maincpu", "v142/subcpu", "subcpu/boot",
         "table_data", "custom_data", "hdae5000"]
LABEL_DEF = re.compile(rb'^LABEL_[0-9A-Fa-f]+:', re.M)
LABEL_TOK = re.compile(rb'\bLABEL_[0-9A-Fa-f]+\b')
NUM_TARGET = re.compile(rb'^\s*(?:[A-Za-z_.$][\w.$]*:\s*)?(call|jp|calr|jr|jrl|djnz)\s+'
                        rb'(?:[a-z0-9]+\s*,\s*)?(0x[0-9a-fA-F]+|[0-9]+)\s*$', re.I)


def strip_comment(line):
    out, in_str = bytearray(), False
    for ch in line:
        if ch == 0x22:
            in_str = not in_str
        elif ch == 0x3B and not in_str:
            break
        out.append(ch)
    return bytes(out)


def smf_well_formed(b):
    """MThd header, then exactly the header's track count of MTrk chunks filling the file."""
    if b[:4] != b"MThd" or len(b) < 14:
        return False
    hl = int.from_bytes(b[4:8], "big")
    ntrk = int.from_bytes(b[10:12], "big")
    p, n = 8 + hl, 0
    while p < len(b):
        if b[p:p + 4] != b"MTrk":
            return False
        p += 8 + int.from_bytes(b[p + 4:p + 8], "big")
        n += 1
    return p == len(b) and n == ntrk


def s_files():
    for t in TREES:
        for p in sorted(glob.glob(os.path.join(REPO, t, "**", "*.s"), recursive=True)):
            yield p


def main():
    defs = refs = nums = 0
    num_examples = []
    for p in s_files():
        data = open(p, "rb").read()
        defs += len(LABEL_DEF.findall(data))
        for line in data.split(b"\n"):
            c = strip_comment(line)
            refs += len(LABEL_TOK.findall(c))
            if NUM_TARGET.match(c):
                nums += 1
                if len(num_examples) < 5:
                    num_examples.append("%s: %s" % (os.path.relpath(p, REPO), c.strip().decode("latin-1")))
    print("label_defs       %d" % defs)
    print("label_refs       %d" % refs)
    print("numeric_targets  %d%s" % (nums, ("  e.g. " + " | ".join(num_examples)) if num_examples else ""))

    tm = []
    for p in list(s_files()) + glob.glob(os.path.join(REPO, "**", "Makefile"), recursive=True):
        rel = os.path.relpath(p, REPO)
        if rel.startswith("archive/"):
            continue
        if b"tmp94c241.inc" in open(p, "rb").read():
            tm.append(rel)
    print("tmp94c241_refs   %d%s" % (len(tm), ("  " + ", ".join(tm)) if tm else ""))

    for d in ("v10/maincpu/images", "table_data/images"):
        bins = sorted(glob.glob(os.path.join(REPO, d, "*.bin")))
        png = sum(os.path.exists(os.path.splitext(b)[0] + ".png") for b in bins)
        print("images           %-22s %3d .bin, %3d with a .png source" % (d, len(bins), png))
    inc = 0
    for p in glob.glob(os.path.join(REPO, "v10/maincpu", "**", "*.s"), recursive=True):
        for line in open(p, "rb").read().split(b"\n"):
            if re.search(rb'\.incbin\s+"images/', strip_comment(line)):
                inc += 1
    print("images           v10 `.incbin \"images/...` lines: %d" % inc)
    mids = sorted(glob.glob(os.path.join(REPO, "table_data/includes/demo_presets/midi/*.mid")))
    print("demo_midi        %d .mid, %d with a well-formed SMF chunk structure" % (
        len(mids), sum(smf_well_formed(open(m, "rb").read()) for m in mids)))
    print("fonts_bdf        %d" % len(glob.glob(os.path.join(REPO, "extracted_fonts/*.bdf"))))

    snaps = sorted(glob.glob(os.path.join(REPO, "docs/coverage/dispatch-census-*.json")))
    if snaps:
        d = json.load(open(snaps[-1]))
        row = []
        for k in ("v10", "v9", "v7", "v142", "subboot", "tabledata", "customdata", "hdae5000"):
            im = d["images"].get(k)
            if im:
                row.append("%s NOT=%d newT=%d" % (k, im["not_used"], im["new_targets_same_image"]))
        print("dispatch_census  %s: %s" % (os.path.basename(snaps[-1]), ", ".join(row)))


if __name__ == "__main__":
    main()
