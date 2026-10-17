#!/usr/bin/env python3
"""gen_sndparam_desc_names_r3.py -- round 3: name the sound-parameter descriptors that rounds 1 and 2 left positional.

QUESTION IT ANSWERS / WHAT IT DOES
  After round 2 (gen_sndparam_desc_names_r2.py) 259 descriptors per tree still carried the positional aliases
  ExtPartParam_Entry_NNN / SeqMixParam_Entry_NNN / MidiChParam_Entry_NNN / VoiceCtrlR1_Entry_NNN / PartParam_Entry_NNN /
  VoiceParamEx_Entry_NNN.  A read-only research pass (2026-10-17) found firmware evidence for 204 of them: the screens
  and grids that edit each key (CONTROL MESSAGES, COMMON SETTING, REALTIME MESSAGES, the panel memory EXPAND MODE
  FILTER, the MIDI PART SETTING grid ...), the ApFunctions that answer EVT_GET_LSW_ADDRESS with it, the panel LED each
  one drives, and the MIDI message SndPart_SetParam sends for the per-part numbers.  Its records, with file:line
  citations machine-checked against the snapshot it was read from, are
  analysis/disk-format-probes/sndparam-r3/proposals.json (README.md there); this script turns them into rename rules:
    - a global proposal names the descriptor whose u32 key equals its key: SndParam_<Name>;
    - a part proposal names every descriptor whose key SndParam_KeyToLswPartNumber decodes to (T, number):
      SndParam_Part<TT>_<Field>.
  Every rule is CHECKED against the descriptor's own bytes in that tree's ROM: the record (bank_index), byte
  (bank_offset) and mask must be the ones the proposal states, or the script stops.  Part fields: record = T (the
  part's own record) for 0x403 / 0x404, record = 0x44 + T for the drawbar switches 0x2C0 / 0x2C1, and record 0xAE /
  0xB1 / 0xB4 with byte = T for 0x078 / 0x1B0 / 0x1B2 (one byte per part).
  v9 and v7 hold the same aliases; a rule is taken there only when it is the rule v10 makes for the same alias.

  Two round-2 names are corrected by the same evidence (analysis/disk-format-probes/sndparam-r3/observations.json):
    - SndParam_Part<TT>_MidiChannelOn (Lsw 0x402) -> SndParam_Part<TT>_MidiTransmitOn: it is the part's TRANSMIT gate
      (+13 bit 6, tested by the MIDI senders), and 0x403 is the RECEIVE gate; the UI sets the two together.
    - SndParam_DigitalEffectOnOff (0x4003) -> SndParam_RotarySpeedSwitch: it reaches the sub CPU as COMM 0x23,
      DSP_Set_RotarySpeed (v142), which applies it only to the rotary-speaker algorithms, and the DIGITAL DRAWBAR
      screen shows it on its TREMOLO (SLOW/FAST) view; SndParam_ApplySystemParam's case for it is renamed with it.

  --weak takes the same pass's proposals_weak_names.json: five descriptors OUTSIDE the 259 whose names restated an
  index (NakaInst_Param_IdxA0_00 ...), renamed from the COMMON SETTING grid and the panel LEDs; each rule asserts
  the key at the old name's address.  --markdown prints the README / technics-docs tables (v10).

RUN (repository root, built tree)
  python3 scripts/renaming/gen_sndparam_desc_names_r3.py            # dry run: counts per tree, the rest by record
  python3 scripts/renaming/gen_sndparam_desc_names_r3.py --write    # writes rename_sndparam_desc_r3_<tree>.sed
  python3 scripts/renaming/gen_sndparam_desc_names_r3.py --weak [--write]   # rename_sndparam_desc_r3_weak_<tree>.sed
  python3 scripts/renaming/gen_sndparam_desc_names_r3.py --markdown
  then per tree: sed -i -f scripts/renaming/rename_sndparam_desc_r3_<tree>.sed <the files that use the names>
  (--write refuses to replace an existing .sed with fewer rules: after the renames are applied a rerun finds
  nothing left to rename, and the committed rules are the record.)
"""
import collections
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_sndparam_desc_names_r2 as R2  # noqa: E402

REPO = R2.REPO
PROPOSALS = os.path.join(REPO, "analysis/disk-format-probes/sndparam-r3/proposals.json")
WEAK = os.path.join(REPO, "analysis/disk-format-probes/sndparam-r3/proposals_weak_names.json")
UNRESOLVED = os.path.join(REPO, "analysis/disk-format-probes/sndparam-r3/unresolved.json")
INFERRED = os.path.join(REPO, "analysis/disk-format-probes/sndparam-r3/inferred.json")
CORRECTIONS = {   # round-2 names that the round-3 evidence corrects (applied in every tree that has them)
    "SndParam_DigitalEffectOnOff": "SndParam_RotarySpeedSwitch",
    "SndParam_ApplySystemParam_QueueDigitalEffectSwitch": "SndParam_ApplySystemParam_QueueRotarySpeed",
}
CORRECT_PART_FIELD = ("MidiChannelOn", "MidiTransmitOn")


def load():
    glob_, part = {}, {}
    for r in json.load(open(PROPOSALS))[1:]:
        mask = int(r["mask"], 16)
        if r["kind"] == "global":
            k = int(r["key"].split()[0], 16)
            glob_[k] = (r["name"], int(r["record"], 16), int(r["byte"]), mask)
        else:
            num = int(r["number"], 16)
            rec, byte = r["record"], r["byte"]
            if rec == "part (= T)":
                rule = ("part", int(byte))
            elif rec == "0x44 + T":
                rule = ("drawbar", int(byte))
            else:
                assert byte == "part (= T)", r
                rule = ("perpart", int(rec, 16))
            part[num] = (r["name"], rule, mask)
    return glob_, part


def plan(tree, glob_, part):
    rom = open(os.path.join(REPO, "original_ROMs/kn5000_%s_program.rom" % tree), "rb").read()
    syms = R2.elf_symbols(tree)
    targets = set(R2.registry(rom, syms))
    taken = set(syms)
    rules, rest = {}, collections.defaultdict(list)
    for name, addr in sorted(syms.items(), key=lambda x: x[1]):
        if not R2.ALIAS.match(name) or addr not in targets:
            continue
        key, bank, off, mask, lo, hi = R2.descriptor(rom, addr)
        d = R2.decode(key)
        new = None
        if key in glob_:
            nm, b_, o_, m_ = glob_[key]
            assert (bank, off, mask) == (b_, o_, m_), (tree, name, hex(key), bank, off, mask)
            new = nm
        elif d and d[1] in part:
            T, num = d
            fld, (kind, x), m_ = part[num]
            if kind == "part":
                assert (bank, off) == (T, x), (tree, name, hex(key), bank, off)
            elif kind == "drawbar":
                assert T in (0, 1, 2) and (bank, off) == (0x44 + T, x), (tree, name, hex(key), bank, off)
            else:
                assert (bank, off) == (x, T), (tree, name, hex(key), bank, off)
            assert mask == m_, (tree, name, hex(key), mask)
            new = "SndParam_Part%02X_%s" % (T, fld)
        if new is None:
            rest[bank].append((key, name))
            continue
        assert new not in taken, (tree, new)
        taken.add(new)
        rules[name] = (new, key)
    for old, new in CORRECTIONS.items():
        if old in syms:
            assert new not in taken, (tree, new)
            rules[old] = (new, None)
    for name in syms:
        m = re.match(r'^SndParam_Part([0-9A-F]{2})_%s$' % CORRECT_PART_FIELD[0], name)
        if m:
            new = "SndParam_Part%s_%s" % (m.group(1), CORRECT_PART_FIELD[1])
            assert new not in taken, (tree, new)
            rules[name] = (new, None)
    return rules, rest


def weak(tree):
    rom = open(os.path.join(REPO, "original_ROMs/kn5000_%s_program.rom" % tree), "rb").read()
    syms = R2.elf_symbols(tree)
    rules = {}
    for r in json.load(open(WEAK))[1:]:
        old, new, key = r["current_name"], r["name"], int(r["key"], 16)
        if old not in syms:
            continue
        k, bank, off, mask, lo, hi = R2.descriptor(rom, syms[old])
        assert (k, bank, off, mask) == (key, int(r["record"], 16), int(r["byte"]), int(r["mask"], 16)), (tree, old)
        assert new not in syms, (tree, new)
        rules[old] = (new, key)
    return rules


def write_sed(tree, rules, tag, what):
    out = os.path.join(REPO, "scripts/renaming/rename_sndparam_desc_r3%s_%s.sed" % (tag, tree))
    if os.path.exists(out):
        have = sum(1 for x in open(out) if x.startswith("s/"))
        if have > len(rules):
            print("   %s keeps its %d rules (this run has %d: already applied)" % (os.path.relpath(out, REPO), have, len(rules)))
            return
    with open(out, "w") as f:
        f.write("# %s: %s (gen_sndparam_desc_names_r3.py; evidence: analysis/disk-format-probes/sndparam-r3/).\n" % (tree, what))
        for a, (n, k) in sorted(rules.items(), key=lambda x: -len(x[0])):
            f.write("s/\\b%s\\b/%s/g\n" % (a, n))
    print("   -> %s" % os.path.relpath(out, REPO))


def md_table(head, rows):
    w = [max(len(str(r[i])) for r in [head] + rows) for i in range(len(head))]
    line = lambda r: "| " + " | ".join(str(c).ljust(w[i]) for i, c in enumerate(r)) + " |"
    return "\n".join([line(head), "|" + "|".join("-" * (x + 2) for x in w) + "|"] + [line(r) for r in rows])


def markdown():
    P = json.load(open(PROPOSALS))[1:]
    parts = [("0x%03X" % int(r["number"], 16), r["key"], "`_%s`" % r["name"], r["parts"], r["record"], str(r["byte"]),
              r["mask"], r["meaning"]) for r in P if r["kind"] == "part"]
    print(md_table(("Lsw number", "key", "name suffix", "parts T", "record", "byte", "mask", "meaning"), parts))
    print()
    gl = sorted(((int(r["key"], 16), r) for r in P if r["kind"] == "global"), key=lambda x: x[0])
    rows = [("0x%05X" % k, "`%s`" % r["name"], r["record"], "+%s" % r["byte"], r["mask"], r["range"], r["meaning"])
            for k, r in gl]
    print(md_table(("key", "name", "record", "byte", "mask", "range", "meaning"), rows))
    print()
    W = json.load(open(WEAK))[1:]
    rows = [("0x%05X" % int(r["key"], 16), "`%s`" % r["name"], "`%s`" % r["current_name"], r["meaning"]) for r in W]
    print(md_table(("key", "name", "was", "meaning"), rows))
    print()
    U = json.load(open(UNRESOLVED))[1:]
    print(md_table(("keys", "where", "what is known"), [(r["keys"], r["where"], r["known"]) for r in U]))
    print()
    I = json.load(open(INFERRED))[1:]
    print(md_table(("key", "probable name", "record", "byte", "mask", "why it is not named", "would confirm"),
                   [(r["key"], "`%s`" % r["name"], r["record"], "+%s" % r["byte"], r["mask"], r["meaning"],
                     r["would_confirm"]) for r in I]))


def main():
    write = "--write" in sys.argv
    if "--markdown" in sys.argv:
        return markdown()
    if "--weak" in sys.argv:
        for tree in ("v10", "v9", "v7"):
            rules = weak(tree)
            print("%s: %d weak names replaced" % (tree, len(rules)))
            if write:
                write_sed(tree, rules, "_weak", "five descriptor names that restated an index, replaced")
        return
    glob_, part = load()
    v10 = None
    for tree in ("v10", "v9", "v7"):
        rules, rest = plan(tree, glob_, part)
        if v10 is None:
            v10 = rules
        else:
            for a, (n, k) in rules.items():
                assert v10.get(a, (n, k)) == (n, k), (tree, a, n, v10.get(a))
        nd = sum(1 for _, (n, k) in rules.items() if k is not None)
        print("%s: %d descriptors named, %d round-2 names corrected, %d keep their alias" % (
            tree, nd, len(rules) - nd, sum(len(v) for v in rest.values())))
        if tree == "v10":
            for bank in sorted(rest):
                print("   record 0x%02X: %s" % (bank, " ".join("%X" % k for k, _ in rest[bank][:14])
                                               + (" ..." if len(rest[bank]) > 14 else "")))
        if write:
            write_sed(tree, rules, "", "sound-parameter descriptors named in round 3, and two round-2 names corrected")


if __name__ == "__main__":
    main()
