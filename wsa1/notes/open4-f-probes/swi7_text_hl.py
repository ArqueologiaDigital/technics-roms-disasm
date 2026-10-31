#!/usr/bin/env python3
"""swi7_text_hl.py -- what is the HL argument of the twelve SWI7 text services? (N-b8a6a194)

FINDINGS-fonts.md 8 said HL "is multiplied by BC once into IZ and never used again".  HL is
not used again, but IZ is: every service reads its characters as `ld A,(XIY+IZ)`.  So
IZ = HL*BC is the offset of the string drawn, and HL is a ROW NUMBER in a table of
BC-character strings at XIY.  This script checks, from prom_a's bytes:

 1. the prologue `ld WA,HL / mul XWA,BC / ld IZ,WA` (db 88 d9 40 d8 8e) occurs exactly 12
    times, once inside each of the 12 text services (entry addresses from the ELF symbol
    table, so run `make gate-wsa1` first);
 2. each service reads its characters through `ld r,(XIY+IZ)` = c3 07 f4 f8 2r (A in the
    fixed-width ones, L in the 16-pixel ones, deeper in the two packed ones);
 3. the source call sites that pass a non-zero HL name a row: listed with their BC.

    python3 notes/open4-f-probes/swi7_text_hl.py       (exits 1 on any failed check)
"""
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
ROM = (ROOT / 'original_ROMs/wsa1_prom_a.ic12').read_bytes()
NM = pathlib.Path.home() / 'compartilhado/llvm-project/build/bin/llvm-nm'
ELF = ROOT / 'rebuilt_ROMs/wsa1_prom_a.llvm.elf'
TEXT = ('06', '07', '08', '16', '17', '19', '1A', '1C', '1D', '1F', '20', '21')
FAIL = []


def check(ok, what):
    print(('ok    ' if ok else 'FAIL  ') + what)
    if not ok:
        FAIL.append(what)


syms = {}
for ln in subprocess.run([str(NM), str(ELF)], capture_output=True, text=True).stdout.split('\n'):
    p = ln.split()
    if len(p) == 3 and p[1] == 't':
        syms[p[2]] = int(p[0], 16)
starts = sorted(syms.values())
svc = {n[8:10]: a for n, a in syms.items() if re.match(r'LCD_Svc_[0-9A-F]{2}_', n) and n[8:10] in TEXT}
check(len(svc) == 12, 'twelve text services in the symbol table: %d' % len(svc))
hits = [m.start() + 0xF80000 for m in re.finditer(bytes.fromhex('db88d940d88e'), ROM)]
check(len(hits) == 12, 'HL*BC -> IZ prologue occurs 12 times: %d' % len(hits))
for code, a in sorted(svc.items()):
    nxt = min(x for x in starts if x > a)
    inside = [h for h in hits if a <= h < nxt]
    body = ROM[a - 0xF80000: nxt - 0xF80000]
    reads = re.findall(bytes.fromhex('c307f4f8') + b'[\x20-\x27]', body)
    check(len(inside) == 1 and len(reads) >= 1,
          'service 0x%s (0x%06X): one prologue, and %d character read(s) ld r,(XIY+IZ)'
          % (code, a, len(reads)))

sites = {
    'StepRecord_DrawNibbleAsStars': ('ldw bc, 0x04', 'svc 6'),
    'SysexProgressBar_FillCells': ('ldw hl, 0x01', 'ldw bc, 0x01'),
    'LCD_DrawVar272ENumberTag_SaveRegs': ('ld HL,(XIZ+0x0a)', 'ldw bc, 0x04'),
}
src = b''.join(p.read_bytes() for p in (ROOT / 'prom_a/modules').glob('*.s')).decode('latin-1')
for name, needles in sites.items():
    i = src.find('\n' + name + ':')
    body = src[i - 600:i + 2400]
    check(i >= 0 and all(nd in body for nd in needles), 'call site %s: %s' % (name, ' / '.join(needles)))
print('FAILURES: %d' % len(FAIL))
sys.exit(1 if FAIL else 0)
