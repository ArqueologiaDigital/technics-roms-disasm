#!/usr/bin/env python3
"""siblings_kn6000_compconn_bitmaps.py -- which pictures do the KN6000's four func_<ADDR> bitmap procedures answer, and who draws them?

Question it answers: kn6000/notes/data-region.md listed four of the KN6000's 13 bitmap procedures as unnamed
(func_4C0A0012 / 4C0A004D / 4C0A0087 / 4C0A00C1).  This script finds, in kn6000/src/program.s and
kn6500/src/program.s, every `call <proc>` whose preceding `mov MT_GetBitmapData, d1` makes it a bitmap fetch,
the routine and the mode branch (the string strcpy'd just before: NORMAL / KN as master / KN as slave) it sits
in, and the size each procedure answers (MT_GetBitmapWidth / Height); then it checks, on the two reference
images, that the KN6000's and KN6500's pixels are the same bytes.  With --png DIR it also writes
compconn_modes_<model>.png: the three modes composed at their screen positions (ComputerConnection_Table_*).

Run (from the repo root):
    python3 kn7000/notes/mn10300-names-probes/siblings_kn6000_compconn_bitmaps.py [--png DIR]
Read-only on the sources and ROMs.  Expected: on both models ComputerConnection calls the 296x108 diagram in
all three modes, the 17x19 piece only after "KN as master", the 10x12 arrow and the 253x24 wire only after
"KN as slave"; the four pixel blocks equal on both models.
"""
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
MODELS = {"kn6000": "kn6000_program.rom", "kn6500": "kn6500_program.rom"}


def scan(model):
    lines = open(os.path.join(ROOT, model, "src", "program.s"), "rb").read().decode("latin-1").split("\n")
    equ = {}
    for line in open(os.path.join(ROOT, model, "src", "labels.inc"), encoding="latin-1"):
        m = re.match(r"\.equ\s+(\w+),\s*(0x[0-9a-fA-F]+)", line)
        if m:
            equ[m.group(1)] = int(m.group(2), 16)
    # bitmap procedures: name -> {data label, width, height, bits}
    procs, cur, body = {}, None, []

    def close():
        if not cur:
            return
        txt = "\n".join(body)
        r = {}
        for c, lab in re.findall(r"cmp\s+(MT_GetBitmap\w+|MT_GetBitCount), d1\n\s+beq\s+(\w+)", txt):
            m = re.search(rf"^{lab}:\n\s+mov\s+(\S+), d0", txt, re.M)
            if m:
                r[c] = m.group(1)
        if "MT_GetBitmapData" in r:
            procs[cur] = r
    for line in lines:
        m = re.match(r"^([A-Za-z_]\w*):", line)
        if m and not re.search(r"_L[0-9a-f]+$|_entry$", m.group(1)):
            close()
            cur, body = m.group(1), []
        body.append(line)
    close()
    # callers of the four (or any func_) bitmap procedures, with the mode string before them
    calls, routine, mode = [], None, None
    for i, line in enumerate(lines):
        m = re.match(r"^([A-Za-z_]\w*):", line)
        if m and not re.search(r"_L[0-9a-f]+$|_entry$", m.group(1)):
            routine, mode = m.group(1), None
        m = re.match(r"\s+mov\s+(Str_\w+), a1$", line)
        if m:
            mode = m.group(1)
        m = re.match(r"\s+call\s+(\w+), 0, 0$", line)
        if m and m.group(1) in procs and "MT_GetBitmapData" in lines[i - 1]:
            calls.append((routine, mode, m.group(1)))
    return procs, calls, equ


def main():
    png_dir = sys.argv[sys.argv.index("--png") + 1] if "--png" in sys.argv else None
    pix = {}
    for model, rom in MODELS.items():
        procs, calls, equ = scan(model)
        d = open(os.path.join(ROOT, model, "baserom", rom), "rb").read()
        print(f"== {model}")
        seen = []
        for routine, mode, p in calls:
            if routine != "ComputerConnection":
                continue
            r = procs[p]
            w, h = int(r["MT_GetBitmapWidth"], 0), int(r["MT_GetBitmapHeight"], 0)
            n = ((w + 15) // 16) * 2 * h            # 1 bit a pixel, rows of whole 16-bit words
            a = equ[r["MT_GetBitmapData"]]
            print(f"  {routine:20} {mode or '-':18} {p:16} {w:3} x {h:3}, {r.get('MT_GetBitCount')} bit, "
                  f"pixels {r['MT_GetBitmapData']} 0x{a:08X} ({n} bytes)")
            if p not in seen:
                seen.append(p)
        pix[model] = [d[equ[procs[p]["MT_GetBitmapData"]] - 0x4C000000:][:((int(procs[p]["MT_GetBitmapWidth"], 0) + 15)
                      // 16) * 2 * int(procs[p]["MT_GetBitmapHeight"], 0)] for p in seen]
        if png_dir:
            try:
                from PIL import Image
            except ImportError:
                print("  (no PIL: --png skipped)")
                continue
            sizes = [(int(procs[p]["MT_GetBitmapWidth"], 0), int(procs[p]["MT_GetBitmapHeight"], 0)) for p in seen]
            imgs = []
            for (w, h), raw in zip(sizes, pix[model]):
                im = Image.new("L", (w, h))
                stride = ((w + 15) // 16) * 2
                for y in range(h):
                    for x in range(w):
                        im.putpixel((x, y), 255 if raw[y * stride + x // 8] & (0x80 >> (x % 8)) else 0)
                imgs.append(im)
            # positions: ComputerConnection_Table (diagram), _4 (master piece), _3 (arrow), _5 (wire)
            pos = [(170, 88), (170, 160), (304, 120), (171, 155)]
            out = Image.new("L", (296, 3 * 112), 128)
            for k, extra in enumerate(([], [1], [2, 3])):
                base = imgs[0].copy()
                for j in extra:
                    base.paste(imgs[j], (pos[j][0] - 170, pos[j][1] - 88))
                out.paste(base, (0, 112 * k))
            os.makedirs(png_dir, exist_ok=True)
            out.save(os.path.join(png_dir, f"compconn_modes_{model}.png"))
    same = pix["kn6000"] == pix["kn6500"]
    print("the four pixel blocks are the same bytes on both models:", same)


if __name__ == "__main__":
    sys.exit(main())
