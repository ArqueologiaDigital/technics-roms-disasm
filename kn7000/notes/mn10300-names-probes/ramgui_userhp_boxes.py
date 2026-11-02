#!/usr/bin/env python3
"""ramgui_userhp_boxes: what is the true width x height of each USER HP preview picture
(table segment 57), from the view each HOME PAGE part names?

The code (build 941):
  AcHpPreviewProc 0x48495F73.. / 0x48495FD8..: for part k, view = TtNormal_Table[k].view
      (0x485F921C, 51 x HomePagePart {u32 view, part_no, name}); func_48493ECC(view, x, y)
      does GetBox(view) and moves the box to (0, 0) (y == -1) or to (0x28*x, 0x1A*y+0x1E):
      both corners move together, so the size is the view's own; func_484968E2 then halves
      all four corners (LibDiv32 by 2) and adds the preview's client-box origin;
  func_48496B28(k, mode, box): W = x2 - x1 + 1, H = y2 - y1 + 1 (the rect is inclusive),
      pixels = segment 57 + offset[k] (TableRomDirectory entry 57 = *(0x480000E4)),
      DrawBitmapSPFast4(box, W, H, pixels, ...): 2 bpp, rows of (W + 3) / 4 bytes.
  With the moved corner even, halving gives W' = ceil(W / 2), H' = ceil(H / 2).

This probe reads the view records' rects (x1, y1, x2, y2 at record +0x0E) from the
program ROM through tools/milk_model.py, the offset table from the table ROM, and checks
that every picture's byte size equals ((W' + 3) // 4) * H'.  Prints one row per part.

usage (from kn7000/, ~30 s):
  python3 -I notes/mn10300-names-probes/ramgui_userhp_boxes.py
"""
import os, struct, sys
sys.path.insert(0, "tools")
import milk_model as M

prog = open("baserom/kn7000_program.rom", "rb").read()
table = open("baserom/kn7000_table.rom", "rb").read()
u32p = lambda a: struct.unpack_from("<I", prog, a - 0x48400000)[0]
u32t = lambda o: struct.unpack_from("<I", table, o)[0]

PARTS, NPARTS = 0x485F921C, 51
seg = u32t(57 * 4)                         # *(0x480000E4): segment 57's offset in the table ROM
offs = [u32t(seg + 4 * k) for k in range(NPARTS)]
starts = sorted(set(o for o in offs if o))
seg_end = u32t(58 * 4)

m = M.Model()
byid = {}
for slot, b in m.blocks.items():
    for o in b["objects"]:
        byid[(slot << 16) | o.index] = o

print("part  view      object                              W    H  ->  W'   H'  row  bytes  item  check")
ok = bad = 0
seen = {}
for k in range(NPARTS):
    view = u32p(PARTS + 12 * k)
    o = byid.get(view)
    off = offs[k]
    if o is None or not off:
        print(f"{k:4d}  {view:#08x}  {'(no object)' if o is None else o.name:34s}  offset {off:#x}")
        continue
    x1, y1, x2, y2 = struct.unpack_from("<4h", prog, o.addr - 0x48400000 + 0x0E)
    W, H = x2 - x1 + 1, y2 - y1 + 1
    Wp, Hp = -(-W // 2), -(-H // 2)
    stride = (Wp + 3) // 4
    nxt = next((s for s in starts if s > off), seg_end - seg)
    size = nxt - off
    first = seen.setdefault(off, k)
    good = stride * Hp == size
    ok += good
    bad += not good
    print(f"{k:4d}  {view:#08x}  {o.name[:34]:34s} {W:4d} {H:4d}  -> {Wp:4d} {Hp:4d}  {stride:3d}  {size:5d}  {first:4d}  "
          f"{'ok' if good else 'MISMATCH'}")
print(f"{ok} parts match ((W'+3)//4)*H' == item bytes, {bad} do not")
