#!/usr/bin/env python3
"""Which v10 instructions read or write the Composer style image's header, section records and the
area after the directory (RHYTHM_PATTERN_BUF_A = 0x94800, one IC19-format bank)?

Two kinds of access are listed, per bank offset:
  ABS  an absolute operand 0x94800 + off (off < 0x1400), in hex or decimal, in any v10 .s or .c file;
  IMG  a displacement (xRR + d), d < 0x60, within WINDOW lines after an instruction that loads a style-image base:
       RHYTHM_PATTERN_BUF_A / _PTR, STYLE_SRC/DST/WORK_IMAGE_PTR, 0x69800 (the work image) or a Custom Data Flash
       section base (0x300000, 0x319800, 0x330000, 0x349800, 0x360000, 0x379800, 0x390000);
  REC  a displacement (xRR + d) / (xRR + d:8) within WINDOW lines after an instruction that forms a section
       record pointer: the constant 0x94860, RhythmTiming_OffsetTable, RHYTHM_SECTION_PTR (0x3560) or a call of
       AccPatch_GetCurrentSlotAddr.  These are CANDIDATES: the register may have been reloaded in between, so
       every row the notes quote was read by eye.
usage: style_bank_readers.py [REPO] [--window N] [--off LO HI]  (REPO defaults to this checkout)
Output: one line per hit, "ABS +0x00e  file:line  routine  instruction" / "REC +0x0c ...", then counts."""
import pathlib, re, sys, collections

args = sys.argv[1:]
win = 40
lo, hi = 0, 0x1400
if '--window' in args:
    i = args.index('--window'); win = int(args[i + 1]); del args[i:i + 2]
if '--off' in args:
    i = args.index('--off'); lo, hi = int(args[i + 1], 0), int(args[i + 2], 0); del args[i:i + 3]
repo = pathlib.Path(args[0]) if args else pathlib.Path(__file__).resolve().parents[3]
src = repo / 'v10' / 'maincpu'
BASE = 0x94800
num = re.compile(rb'(?<![\w.])(0x[0-9a-fA-F]+|\d+)(?![\w])')
label = re.compile(rb'^([A-Za-z_.$][\w.$]*):')
recptr = re.compile(rb'0x94860\b|RhythmTiming_OffsetTable|RHYTHM_SECTION_PTR|\(0x3560(:16)?\)|AccPatch_GetCurrentSlotAddr\b')
imgptr = re.compile(rb'RHYTHM_PATTERN_BUF_(A|PTR)\b|STYLE_(SRC|DST|WORK)_IMAGE_PTR|\b0x0?69800\b|\b0x0?(300000|319800|330000|349800|360000|379800|390000)\b')
disp = re.compile(rb'\((x[a-z]{2,3})\s*\+\s*(0x[0-9a-fA-F]+|\d+)(?::8|:16)?\)')
hits = collections.defaultdict(list)
for f in sorted(list(src.rglob('*.s')) + list(src.rglob('*.c'))):
    lines = f.read_bytes().split(b'\n')
    rel = f.relative_to(repo).as_posix()
    rout = '?'
    left = 0
    ileft = 0
    for n, l in enumerate(lines, 1):
        code = l.split(b';')[0] if f.suffix == '.s' else l.split(b'//')[0]
        m = label.match(l)
        if m and not m.group(1).startswith(b'.'):
            rout = m.group(1).decode()
        for t in num.findall(code):
            v = int(t, 16) if t[:2] in (b"0x", b"0X") else int(t)
            if BASE + lo <= v < BASE + hi:
                hits[('ABS', v - BASE)].append((rel, n, rout, l.strip().decode('latin-1')))
        if imgptr.search(code):
            ileft = win
        elif ileft:
            ileft -= 1
            for reg, d in disp.findall(code):
                d = int(d, 16) if d[:2] == b"0x" else int(d)
                if d < 0x60:
                    hits[('IMG', d)].append((rel, n, rout, l.strip().decode('latin-1')))
        if recptr.search(code):
            left = win
            continue
        if left:
            left -= 1
            for reg, d in disp.findall(code):
                d = int(d, 16) if d[:2] == b"0x" else int(d)
                if d < 0x60:
                    hits[('REC', d)].append((rel, n, rout, l.strip().decode('latin-1')))
for (kind, off) in sorted(hits, key=lambda k: (k[0], k[1])):
    if kind in ('REC', 'IMG') or lo <= off < hi:
        for rel, n, rout, txt in hits[(kind, off)]:
            print(f'{kind} +0x{off:03x}  {rel}:{n}  {rout}  {txt}')
print('counts:', ' '.join(f'{k}+0x{o:x}={len(v)}' for (k, o), v in sorted(hits.items())))
