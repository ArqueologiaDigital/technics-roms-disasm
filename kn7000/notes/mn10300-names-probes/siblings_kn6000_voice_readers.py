#!/usr/bin/env python3
"""siblings_kn6000_voice_readers.py -- which of voice_record.inc's field readers exist in the KN6000 as the same code?

Question it answers: kn7000/src/include/voice_record.inc names the sound-record fields after the KN7000
routines that read them (TgNoteOn, TgElemLevelBaseCalc, VoiceSubRecFetch ...).  For each routine it
cites, does the KN6000 (v7.1) program hold the same routine?  A routine is "the same" when
kn6000/kn6000_ported.sym carried its name by code (kn7000/tools/port_names_by_code.py: the instruction
stream with every number below 0x10000 -- every (dN, aN) displacement, i.e. every field offset -- kept;
"whole body exact" / "skeleton" / "fuzzy" rows are fn_similarity.py's classes), or kn6000.sym /
kn6000_manual.sym name it.  An exact or signature match means the KN6000 reads the same offsets.

Run (from the repo root):  python3 kn7000/notes/mn10300-names-probes/siblings_kn6000_voice_readers.py
Read-only; prints one row per routine name and a summary.
"""
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
INC = os.path.join(ROOT, "kn7000", "src", "include", "voice_record.inc")
K6 = os.path.join(ROOT, "kn6000")


def syms(path):
    out = {}
    if not os.path.exists(path):
        return out
    for line in open(path, encoding="latin-1"):
        m = re.match(r"\s*0x([0-9A-Fa-f]{8})\s+(\w+)\s*(?:;\s*(.*))?", line)
        if m:
            out.setdefault(m.group(2), (int(m.group(1), 16), (m.group(3) or "").strip()))
    return out


def main():
    text = open(INC, encoding="latin-1").read()
    comments = "\n".join(l for l in text.split("\n") if l.lstrip().startswith("#"))
    names = []
    # whole names only: a name the text abbreviates ("TgPartAuxMod28/2A/2C/2EGet/Set") is expanded below
    for n in re.findall(r"\b((?:Tg|Voice|CustomSound)[A-Z]\w+)\b(?![/\w])", comments):
        if n not in names:
            names.append(n)
    # "TgPartAuxHdr46/47Get/Set" style ranges: expand the ones the text abbreviates
    extra = []
    for m in re.finditer(r"\b(TgPartAux(?:Hdr|Mod))((?:[0-9A-F]{2}/)*[0-9A-F]{2})(Get|Set)?(?:/(Get|Set))?", comments):
        for k in m.group(2).split("/"):
            for gs in [g for g in (m.group(3), m.group(4)) if g] or [""]:
                extra.append(f"{m.group(1)}{k}{gs}")
    for n in extra:
        if n not in names:
            names.append(n)
    ported = syms(os.path.join(K6, "kn6000_ported.sym"))
    own = {**syms(os.path.join(K6, "kn6000.sym")), **syms(os.path.join(K6, "kn6000_manual.sym"))}
    counts = {}
    for n in names:
        if n in ported:
            a, c = ported[n]
            cls = "whole body " + re.search(r"whole body \d+ insns, (\w+)", c).group(1) if "whole body" in c \
                else "signature " + re.search(r"(\d+) insns", c).group(1) + " insns"
            kind = "ported"
        elif n in own:
            a, c = own[n]
            cls, kind = "named in kn6000(.sym|_manual.sym)", "named"
        else:
            a, cls, kind = None, "-", "absent"
        counts[kind] = counts.get(kind, 0) + 1
        print(f"{n:32} {('0x%08X' % a) if a else '-':12} {kind:7} {cls}")
    print("summary:", ", ".join(f"{k} {v}" for k, v in sorted(counts.items())), f"of {len(names)} names")


if __name__ == "__main__":
    sys.exit(main())
