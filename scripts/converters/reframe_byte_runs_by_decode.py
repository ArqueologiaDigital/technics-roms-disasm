#!/usr/bin/env python3
r"""reframe_byte_runs_by_decode.py -- re-frame `.byte` runs inside code where the decode re-converges.

QUESTION ANSWERED / JOB IT DOES
    doc_quality_census.py row (d) counts `.byte` runs whose previous and next statements are both
    instructions.  After a fall-through instruction such a run is most likely an instruction spelled as
    bytes, and the "instructions" right after it are often the tail of the real one re-read at the wrong
    offset (the earlier toolchain resumed decoding one byte later).  Two cases dominate in v7:
      * the register-indexed operand (xrr+rr) -- `ld c, (xde+wa)`, `ld (xbc+wa), 0x20`, `cp (xhl+wa), 0x7f`
        -- which the assembler spells since TOOLCHAIN_VERSION UPDATE 21 but llvm-objdump still prints as
        `<unknown>`, so every decode-based re-framer refused it;
      * a one-byte memory prefix left as `.byte 0x87` / `0x8f` / `0xc1, 0x88, 0x89` in front of the
        misread tail (`cp (xsp), 0` spelled `.byte 0x87 / push xsp / nop`).
    For every such run after a fall-through instruction (or after a terminator, with --after-terminator):
      1. the run's address and the addresses of the following source lines come from a line-address map
         (scripts/analysis/v10_line_address_map.py --image <tree>);
      2. the bytes from the run's start are decoded with llvm-objdump, the register-indexed forms by trial
         encoding (v7_byte_region_to_insns.indexed_candidate);
      3. the decode must reach, within --max-lines source lines after the run, the address of an existing
         instruction line (re-converge on the tree's framing), with no `<unknown>` and no instruction real
         code here never holds (halt, swi, ldf, incf, decf, normal, max, min, two nops in a row);
      4. every decoded instruction must assemble on its own to exactly the dump's bytes;
      5. every label in the replaced lines must fall on a decoded instruction start (it is kept, in front of
         that instruction); a label inside a decoded instruction refuses the run;
      6. call / jp targets and relative branch targets that are a label's address are written as the label;
         others stay numeric for symbolize_numeric_branches.py.
    Comment lines inside the replaced lines are kept, in front of the first instruction.  A trailing
    comment on a `.byte` line that only says what the bytes decode to, or that the backend cannot spell
    them, is dropped with the bytes.  `make gate` is the proof that no byte moved.

RUN
    make all
    python3 scripts/analysis/v10_line_address_map.py --image v7 FILES --out LM.json
    python3 scripts/converters/reframe_byte_runs_by_decode.py --image v7 --linemap LM.json FILES [--apply]
"""
import argparse
import json
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, "scripts", "converters"))
import v7_byte_region_to_insns as R  # noqa: E402

LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):\s*(.*)$')
BYTES = re.compile(r'^\s*\.byte\s+([^;]*?)\s*(;.*)?$')
INSN = re.compile(r'^\s+[a-z_][a-z0-9_]*\b')
TERM = re.compile(r'^\s*(ret|reti|retd|jp|jr|jrl)\b(?!\s+(?!t\b)[a-z]+\s*,)')
ABSURD = re.compile(r'^(halt|swi|ldf|incf|decf|normal|max|min)\b')
NOTE = re.compile(r'cannot spell|backend|^;\s*[a-z_0-9]+\s+[^;]*$', re.I)


MACROS = set()      # filled in main(): a macro use is never taken for an instruction (aligned_string, naka_header)


def kind(line):
    s = line.split(";")[0].rstrip()
    m = LABEL.match(s)
    if m:
        if not m.group(2).strip():
            return "label"
        s = "\t" + m.group(2)
    if not s.strip():
        return "comment" if line.strip().startswith(";") else "blank"
    if BYTES.match(s):
        return "byte"
    if re.match(r'^\s+\.', s):
        return "dir"
    m = INSN.match(s)
    if m and s.split()[0] not in MACROS:
        return "ins"
    return "other"


def decode(v, rom, pos, end, cache):
    if pos in cache:
        return cache[pos]
    dec = R.objdump(v, pos, min(end, pos + 16))
    text = dec[0][1] if dec and dec[0][0] == pos else "<unknown>"
    if text.startswith("<unknown>"):
        text = R.indexed_candidate(rom[pos - 0xE00000:pos - 0xE00000 + 8]) or text
    cache[pos] = text
    return text


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image", default="v7", choices=("v7", "v9", "v10"))
    ap.add_argument("--linemap", required=True)
    ap.add_argument("--max-lines", type=int, default=8)
    ap.add_argument("--after-terminator", action="store_true")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("files", nargs="+")
    a = ap.parse_args()
    v = a.image
    import glob
    for f in glob.glob(os.path.join(REPO, v, "maincpu", "**", "*.s"), recursive=True):
        MACROS.update(re.findall(r'^\s*\.macro\s+([A-Za-z_][\w]*)', open(f, "rb").read().decode("latin-1"), re.M))
    lm = json.load(open(a.linemap))
    rom = open(os.path.join(REPO, "original_ROMs", "kn5000_%s_program.rom" % v), "rb").read()
    by, at = R.syms(v)

    def name_at(x):
        ns = at.get(x)
        return sorted(ns, key=lambda q: (bool(R.STRUCT.search(q)), len(q), q))[0] if ns else None

    total = {"converted": 0, "bytes": 0, "refused": 0}
    for rel in a.files:
        path = os.path.join(REPO, rel)
        key = rel if rel in lm else os.path.relpath(path, os.path.join(REPO, v, "maincpu"))
        amap = {int(k): val for k, val in lm.get(key, lm.get(rel, {})).items()}
        L = open(path, "rb").read().decode("latin-1").split("\n")
        K = [kind(l) for l in L]
        edits = []
        i = 0
        while i < len(L):
            if K[i] != "byte":
                i += 1
                continue
            p = i - 1
            while p >= 0 and K[p] in ("blank", "comment", "label"):
                p -= 1
            j = i
            while j < len(L) and K[j] in ("byte", "label", "blank", "comment"):
                j += 1
            ok_prev = p >= 0 and K[p] == "ins" and (a.after_terminator or not TERM.match(L[p].split(";")[0]))
            if not ok_prev or j >= len(L) or K[j] != "ins" or (i + 1) not in amap:
                i = j
                continue
            start = amap[i + 1]
            # candidate convergence points: addresses of instruction lines j.. within max-lines
            stops, n_ins, k = {}, 0, j
            while k < len(L) and n_ins <= a.max_lines:
                if K[k] == "ins" and (k + 1) in amap:
                    stops.setdefault(amap[k + 1], k)
                    n_ins += 1
                elif K[k] in ("dir", "other", "byte"):
                    break
                k += 1
            if not stops:
                i = j
                continue
            limit = max(stops)
            pos, out, cache, why = start, [], {}, None
            while True:
                if out and pos in stops:
                    break
                if pos > limit:
                    why = "no re-convergence"
                    break
                text = decode(v, rom, pos, limit + 16, cache)
                if text.startswith("<unknown>"):
                    why = "undecodable at 0x%06x" % pos
                    break
                if ABSURD.match(text) or (text == "nop" and out and out[-1][1] == "nop"):
                    why = "absurd `%s`" % text
                    break
                enc = R.encode(text)
                if enc is None or rom[pos - 0xE00000:pos - 0xE00000 + len(enc)] != enc:
                    why = "`%s` does not re-encode" % text
                    break
                out.append((pos, text, len(enc)))
                pos += len(enc)
            if why:
                total["refused"] += 1
                print("%s:%d refused: %s" % (rel, i + 1, why))
                i = j
                continue
            kend = stops[pos]
            starts = {q for q, _, _ in out}
            labels, comments, bad = {}, [], None
            for t in range(i, kend):
                if K[t] == "label":
                    adr = amap.get(t + 1)
                    if adr not in starts:
                        bad = "label %s inside an instruction" % L[t].split(":")[0]
                    labels.setdefault(adr, []).append(L[t].split(":")[0])
                elif K[t] == "comment":
                    comments.append(L[t])
                elif K[t] == "byte":
                    lm_ = LABEL.match(L[t])
                    body = "\t" + lm_.group(2) if lm_ else L[t]
                    if lm_:
                        adr = amap.get(t + 1)
                        if adr not in starts:
                            bad = "label %s inside an instruction" % lm_.group(1)
                        labels.setdefault(adr, []).append(lm_.group(1))
                    m = BYTES.match(body)
                    if m and m.group(2) and not NOTE.search(m.group(2)):
                        comments.append("\t" + m.group(2))
                else:
                    c = L[t].split(";", 1)
                    if len(c) == 2 and c[1].strip() and not NOTE.search(";" + c[1]):
                        comments.append("\t;" + c[1])
                    lm_ = LABEL.match(L[t].split(";")[0])
                    if lm_ and lm_.group(2).strip():
                        adr = amap.get(t + 1)
                        if adr not in starts:
                            bad = "label %s inside an instruction" % lm_.group(1)
                        labels.setdefault(adr, []).append(lm_.group(1))
            if bad:
                total["refused"] += 1
                print("%s:%d refused: %s" % (rel, i + 1, bad))
                i = j
                continue
            new = list(comments)
            for q, text, ln in out:
                for nm in labels.get(q, []):
                    new.append("%s:" % nm)
                mn, _, ops = text.partition(" ")
                if mn in R.REL:
                    parts = ops.rsplit(",", 1) if "," in ops else ["", ops]
                    disp = int(parts[-1].strip(), 0)
                    if mn in ("jrl", "calr") and disp > 0x7FFF:
                        disp -= 0x10000
                    nm = name_at(q + ln + disp)
                    if nm:
                        ops = (parts[0].strip() + ", " if parts[0].strip() else "") + nm
                else:
                    def sub(m):
                        val = int(m.group(1), 0)
                        nm = name_at(val) if 0xE00000 <= val <= 0xFFFFFF else None
                        return m.group(0).replace(m.group(1), nm) if nm else m.group(0)
                    ops = re.sub(r'(?<![\w+-])(\d{8}|0x[0-9a-f]{6})(?=(:24)?\)|$|\s*,)', sub, ops)
                new.append("\t%s\t%s" % (mn, ops) if ops else "\t%s" % mn)
            edits.append((i, kend, new))
            nbytes = pos - start
            total["converted"] += 1
            total["bytes"] += nbytes
            print("%s:%d converted %d bytes: %s" % (rel, i + 1, nbytes, " / ".join(t for _, t, _ in out)))
            i = kend
        if a.apply and edits:
            for s, e, new in sorted(edits, reverse=True):
                L[s:e] = new
            open(path, "wb").write("\n".join(L).encode("latin-1"))
    print("converted %(converted)d runs (%(bytes)d bytes from the run start to re-convergence), "
          "refused %(refused)d" % total)
    return 0


if __name__ == "__main__":
    sys.exit(main())
