#!/usr/bin/env python3
"""names_choice_func_lists: KN2400 FilePriorityFunc has the same relocation-masked body as the
KN7000's SdcPanelSwAsFunc (the sibling-name audit's one `wrong` pick, N-89cedbdb).  Which name is
right?

Both are MILK choice-parameter *Func handlers of one template: MT_GetRamString (0x60044) copies
choice number (obj+0x10) out of a table of string pointers, MT_GetMax (0x60040) returns the last
choice number, the other MT_Get* ids constants.  The masked comparison hides the one thing that
tells them apart: the string table.  This probe decodes each handler (MAME unidasm), takes the
table address of its `mov 0x........, a0; asl2 d0` and its MT_GetMax value, and prints the
choices.  Expected (2026-11-06): KN7000 FilePriorityFunc {TECHNICS, SMF, CUSTOM STYLE} max 2;
KN7000 SdcPanelSwAsFunc {SD-AUDIO, SD-SOUND} max 1; KN2400 FilePriorityFunc {TECHNICS, SMF}
max 1 (the KN2400 has no CUSTOM STYLE); KN2400 SdcLoadDispFunc {FOLDER LIST, ALPHABET SORT,
LOAD BY NUMBER, SD-SOUND LOAD} max 3; KN2400 SdcPanelSwAsFunc is `clr d0; retf` (no choices).
So each image's name is right for its own routine; the bodies are equal only because both lists
have two entries.

usage (from the repo root):
  UNIDASM=/path/to/unidasm python3 -I kn7000/notes/kn7000-names-probes/names_choice_func_lists.py
"""
import os
import re
import struct
import subprocess

U = os.environ.get("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm")
SCRATCH = os.environ.get("TMPDIR", os.path.expanduser("~/compartilhado/tmp"))
IMAGES = {"KN7000": "kn7000/baserom/kn7000_program.rom", "KN2400": "kn2400/baserom/kn2400_program.rom"}
BASE = 0x48400000


def sym(path, name):
    for ln in open(path):
        p = ln.split()
        if len(p) >= 2 and p[1] == name and p[0].startswith("0x"):
            return int(p[0], 16)


def decode(img, cpu, n=0x80):
    tmp = os.path.join(SCRATCH, "names_choice_func_lists.bin")
    open(tmp, "wb").write(img[cpu - BASE:cpu - BASE + n])
    out = subprocess.run([U, tmp, "-arch", "mn10300", "-basepc", hex(cpu)], capture_output=True,
                         text=True).stdout
    ins = []
    for ln in out.splitlines():
        m = re.match(r"([0-9a-f]+): (?:[0-9a-f]{2} )+\s+(\S+)\s*(.*)", ln)
        if m:
            ins.append((int(m.group(1), 16), m.group(2), m.group(3)))
            if m.group(2) in ("ret", "retf", "rets"):
                break
    return ins


def cstr(img, a):
    o = a - BASE
    return img[o:img.index(b"\0", o)].decode("latin-1")


for model, name in [("KN7000", "FilePriorityFunc"), ("KN7000", "SdcPanelSwAsFunc"),
                    ("KN2400", "FilePriorityFunc"), ("KN2400", "SdcLoadDispFunc"),
                    ("KN2400", "SdcPanelSwAsFunc")]:
    img = open(IMAGES[model], "rb").read()
    cpu = sym({"KN7000": "kn7000/kn7000.sym", "KN2400": "kn2400/kn2400.sym"}[model], name)
    ins = decode(img, cpu)
    table = next((int(ops.split(",")[0], 16) for (_a, mn, ops), (_b, mn2, _o) in zip(ins, ins[1:])
                  if mn == "mov" and ops.endswith(", a0") and mn2 == "asl2"), None)
    # MT_GetMax: `cmp 0x60040, d1; beq L` then at L `mov N, d0` (or `clr d0`)
    mx = None
    for i, (_a, mn, ops) in enumerate(ins):
        if mn == "cmp" and ops == "0x60040, d1":
            tgt = int(ins[i + 1][2], 16)
            t = next(x for x in ins if x[0] == tgt)
            mx = 0 if t[1] == "clr" else int(t[2].split(",")[0], 0)
    if table is None:
        print(f"{model} {name} 0x{cpu:08X}: {len(ins)} insns, no string table:",
              "; ".join(f"{m} {o}" for _a, m, o in ins))
        continue
    choices = []
    for k in range(mx + 1):
        choices.append(cstr(img, struct.unpack_from("<I", img, table - BASE + 4 * k)[0]).strip())
    print(f"{model} {name} 0x{cpu:08X}: table 0x{table:08X}, MT_GetMax {mx}, choices {choices}")
