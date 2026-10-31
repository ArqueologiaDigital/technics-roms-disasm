#!/usr/bin/env python3
"""What are Voice_ApplyParamChange_Dispatch's target codes 29, 30 and 37?  (N-b85f7365)

CPU 2 (prom_c) dispatches on a 6-bit code, `ld L,(XIX+0x01) / and L,0x3f` (0xFAF041/0xFAF044),
index = code - 1 into the 49-entry table at 0xFAF08F.  CPU 1 (prom_b) draws a controller's
destination from ControllerDestinationNames (0xF33022), 64 entries of 13 bytes, indexed by the
same field with mask 0x3F.  This probe asserts, from the ROM bytes and the sources:
  * entries 29, 30, 37 of the prom_b table read POSITION, POS.DEPTH, SUB GAIN;
  * table entries 28, 29, 36 of prom_c's dispatcher reach CtrlDest29_Position_Apply,
    CtrlDest30_PosDepth_Apply and CtrlDest37_SubGain_Apply;
  * those three call PartRec_SetPositionOffset_0003, _0005 and PartRec_SetSubGainOffset_000F;
  * the factory tone census of the controller-assignment slots MidiCtrl_CC01/CC02/CC04 hand the
    dispatcher (tone record +0x17/+0x1A, +0x1D/+0x20, +0x25/+0x28; the code is byte +1 & 0x3F),
    over prom_d's non-drum tones: code 29 in 119 CC02-first and 33 CC02-second slots; codes 30
    and 37 in none.
Exit 0 = PASS.  Run: python3 notes/open4-a-probes/ctrl_dest_names.py
"""
import collections, os, re, struct, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prom_c_callgraph as g

ROOT = g.ROOT
b = open(os.path.join(ROOT, 'original_ROMs/wsa1_prom_b.ic13'), 'rb').read()
d = open(os.path.join(ROOT, 'original_ROMs/wsa1_prom_d.bin'), 'rb').read()
fail = 0
names = [b[0x33022 + 13 * k:0x33022 + 13 * k + 13].decode('latin1').rstrip() for k in range(64)]
for k, want in ((29, 'POSITION'), (30, 'POS.DEPTH'), (37, 'SUB GAIN'), (0, '-------------'), (49, 'REV DYNAMIC')):
    ok = names[k] == want
    fail += not ok
    print('prom_b ControllerDestinationNames[%2d] = %-15r %s' % (k, names[k], 'ok' if ok else 'FAIL want %r' % want))
src = open(os.path.join(ROOT, 'prom_c/midi/midi_controllers.s'), 'rb').read().decode('latin1')
if not re.search(r'ld\tl, \(xix\+1\)\s+; FAF041.*\n\tand\tl, 63\s+; FAF044', src):
    fail += 1
    print('FAIL: the 6-bit code fetch at 0xFAF041/0xFAF044')
for entry, arm, routine, setter in ((28, 'FAF246', 'CtrlDest29_Position_Apply', 'PartRec_SetPositionOffset_0003'),
                                    (29, 'FAF254', 'CtrlDest30_PosDepth_Apply', 'PartRec_SetPositionOffset_0005'),
                                    (36, 'FAF29A', 'CtrlDest37_SubGain_Apply', 'PartRec_SetSubGainOffset_000F')):
    t = re.search(r'Voice_ApplyParamChange_Dispatch__%s\t; 0x[0-9A-F]+  entry %d ' % (arm, entry), src)
    body = src[src.index('Voice_ApplyParamChange_Dispatch__%s:' % arm):][:400]
    rb = src[src.index('\n%s:' % routine):][:1600]
    ok = bool(t) and ('calr %s' % routine) in body and ('call\t%s' % setter) in rb
    fail += not ok
    print('dispatcher entry %2d (code %2d) -> 0x%s -> %-26s -> %-31s %s' % (entry, entry + 1, arm, routine, setter, 'ok' if ok else 'FAIL'))
offs = [struct.unpack_from('<I', d, 0xB80 + 4 * i)[0] for i in range(274)]
c = collections.Counter()
for o in offs:
    if d[o + 0x10] & 0xC0 == 0x80:
        continue
    for slot, off in (('CC01a', 0x17), ('CC01b', 0x1A), ('CC02a', 0x1D), ('CC02b', 0x20), ('CC04a', 0x25), ('CC04b', 0x28)):
        c[(slot, d[o + off + 1] & 0x3F)] += 1
for code in (29, 30, 37):
    print('code %d (%s): %s' % (code, names[code], {s: n for (s, k), n in c.items() if k == code} or 'no factory tone'))
want = {('CC02a', 29): 119, ('CC02b', 29): 33}
got = {k: n for k, n in c.items() if k[1] in (29, 30, 37)}
if got != want:
    fail += 1
    print('FAIL: census', got)
print('FAILURES:', fail)
sys.exit(1 if fail else 0)
