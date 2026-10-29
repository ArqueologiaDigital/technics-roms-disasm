#!/usr/bin/env python3
"""gui_var_writers.py -- for every RAM address a display record still spells as a number, who writes it, who reads it.

QUESTION IT ANSWERS
  "The display records draw `var=0x26b0` and `table=0x00002300`: what is in those cells?"  A name has to come from
  the routine that WRITES the cell (a display record only says where it is shown), so for each address this
  lists every converted instruction in prom_a / prom_b whose memory operand is that address -- prom_a spells it
  `(0x26b0:16)`, prom_b in decimal `(9904:16)` -- split into writes and reads, with the routine (the nearest
  label above that is not a `.L` / `_Skip`-style local) and the record lines that draw it, with the texts of
  the list each one sits in.

RUN (inside wsa1/)
  python3 notes/gui-data-2026-10-29-probes/gui_var_writers.py              # every address, summary
  python3 notes/gui-data-2026-10-29-probes/gui_var_writers.py 0x26b0       # one address, every site
"""
import collections
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FILES = sorted(glob.glob(os.path.join(ROOT, "prom_[ab]", "modules", "*.s"))) + \
    [os.path.join(ROOT, "prom_a", "wsa1_prom_a.s"), os.path.join(ROOT, "prom_b", "wsa1_prom_b.s")]
LOCAL = re.compile(r'(_Skip\d*|_Join\d*|_Loop\d*|_Return\d*|_Next\d*|_Done\d*|_Exit\d*|_Case\d*|_Else\d*|_End\d*)$')
WRITE = re.compile(r'^\s*(ldw?|ld[a-z]*|inc[a-z]*|dec[a-z]*|set|res|chg|or[bw]?|and[bw]?|xor[bw]?|add[bw]?|sub[bw]?|'
                   r'ex|tset|stcf|pop[w]?|m_st\w*|m_ld_m\w*|m_inc|m_dec|m_set|m_res|m_or\w*|m_and\w*|m_add_m\w*)\s+'
                   r'(?:\d+\s*,\s*)?\(\s*([^)]*)\)\s*,', re.I)


def addr_forms(a):
    return {"0x%x" % a, "0x%04x" % a, "%d" % a, "0x%x" % a, "0x%06x" % a}


def operand_addr(text):
    m = re.match(r'^(0x[0-9a-fA-F]+|\d+)(?::(?:8|16|24))?$', text.strip())
    return int(m.group(1), 0) if m else None


def scan(targets):
    sites = collections.defaultdict(lambda: {"w": [], "r": [], "dl": []})
    for f in FILES:
        L = open(f, "rb").read().decode("latin-1").split("\n")
        routine, dlname, texts = "?", "?", []
        for i, l in enumerate(L):
            m = re.match(r'^([A-Za-z_]\w*):', l)
            if m and not LOCAL.search(m.group(1)):
                routine = m.group(1)
                dlname, texts = m.group(1), []
            code = l.split(";", 1)[0]
            tm = re.search(r'text="((?:[^"\\]|\\.)*)"', l)
            if tm:
                texts.append(tm.group(1))
            if re.match(r'^\s*dlb?_\w+\s', code):
                for k in ("var", "table"):
                    mm = re.search(r'\b%s=(0x[0-9a-fA-F]+)' % k, code)
                    if mm and int(mm.group(1), 16) in targets:
                        sites[int(mm.group(1), 16)]["dl"].append((os.path.basename(f), i + 1, dlname, k,
                                                                   code.strip()[:110], list(texts[-4:])))
                continue
            for mm in re.finditer(r'\(\s*([0-9a-fA-Fx]+(?::(?:8|16|24))?)\s*\)', code):
                a = operand_addr(mm.group(1))
                if a in targets:
                    w = WRITE.match(code)
                    kind = "w" if w and operand_addr(w.group(2)) == a else "r"
                    sites[a][kind].append((os.path.basename(f), i + 1, routine, code.strip()[:90]))
            for mm in re.finditer(r'\b0x00([0-9a-fA-F]{4})\b', code):     # 24-bit immediates (ld XIY,0x0000xxxx)
                a = int(mm.group(1), 16)
                if a in targets and re.match(r'^\s*(ld|lda)\s+x', code, re.I):
                    sites[a]["r"].append((os.path.basename(f), i + 1, routine, code.strip()[:90]))
    return sites


def numeric_targets():
    t = set()
    for f in FILES:
        for m in re.finditer(r'\b(?:var|table)=(0x[0-9a-fA-F]+)', open(f, "rb").read().decode("latin-1")):
            v = int(m.group(1), 16)
            if v < 0x100000 and v != 0:
                t.add(v)
    return t


def main():
    if len(sys.argv) > 1:
        targets = {int(x, 0) for x in sys.argv[1:]}
        full = True
    else:
        targets = numeric_targets()
        full = False
    s = scan(targets)
    for a in sorted(targets):
        d = s[a]
        wr = collections.Counter(x[2] for x in d["w"])
        rd = collections.Counter(x[2] for x in d["r"])
        print("0x%04X  drawn %d  written %d by %s  read %d by %s" % (
            a, len(d["dl"]), len(d["w"]), dict(wr.most_common(4)), len(d["r"]), dict(rd.most_common(3))))
        if full:
            for x in d["w"]:
                print("    W %s:%d  %-36s %s" % x)
            for x in d["r"][:30]:
                print("    R %s:%d  %-36s %s" % x)
            for x in d["dl"]:
                print("    D %s:%d  %-36s %s  %s  %s" % x)


if __name__ == "__main__":
    main()
