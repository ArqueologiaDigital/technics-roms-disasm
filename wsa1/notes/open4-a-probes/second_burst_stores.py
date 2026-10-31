#!/usr/bin/env python3
"""Does the second full 19-register burst at note-on repeat the first's values?  (N-de8d3a35)

VoiceRegs_Stage_D packs the struct at 0x00D7A2 (Dev104_PackStagingStruct, 0xFB2F3B), sends it
(Dev104_WriteAllChanRegs, 0xFB2F4B), then calls Voice_ComputeLevelBase_CD, SlotRec_AddToArgField_000E,
Voice_StageLevel_Reg0080_CD and Dev10C_WriteAllChanRegs, returns, and MidiNote_OnTail sends the
SAME struct again (0xFB3708).  MidiNote_OffTail has the same shape (0xFB3810 / its second burst).

This probe lists EVERY memory store in the forward call closure of what runs between the two
bursts -- the first burst's own writer included, in case it mutated its input -- and classifies
the address operand:
  frame    (xiz+-d)                         a local
  abs      an absolute address              must lie outside 0x00D7A2..0x00D7C7 (19 words)
  reg      (xRR+d) / (xRR)                  must be listed in REG_BASES with where xRR comes from
A struct write would have to be an `abs` inside the window or an unexplained `reg`.
Exit 0 = no such store.  Run: python3 notes/open4-a-probes/second_burst_stores.py
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prom_c_callgraph as g

BETWEEN = [b'Dev104_WriteAllChanRegs', b'Voice_ComputeLevelBase_CD', b'SlotRec_AddToArgField_000E',
           b'Voice_StageLevel_Reg0080_CD', b'Dev10C_WriteAllChanRegs']
WIN = (0xD7A2, 0xD7A2 + 2 * 19)
# routine -> (expected number of register-based stores, where every base comes from)
REG_BASES = {
    'Dev104_WriteAllChanRegs': (None, 'the port pair: XBC/XWA reloaded from (XIZ-4)/(XIZ-8) = 0x00104000 / 0x00104002'),
    'Dev10C_WriteAllChanRegs': (None, 'the port pair: XBC/XWA reloaded from (XIZ-4)/(XIZ-8) = 0x0010C000 / 0x0010C002'),
    'Voice_ComputeLevelBase_CD': (None, 'XDE = (XIZ+0x08), the voice record 0x3BCF + 68*v that Stage_D pushes (pushw de)'),
    'SlotRec_AddToArgField_000E': (None, 'XHL = (XIZ+0x08), the same voice record pointer'),
    'Dev10C_ChanPlus2_SetRegs_09xx': (None, '(XBC+0x3BCF) = voice record of chan+2; XBC/XIX/XWA = the literal 0x0010C000 (+2)'),
    'Dev10C_ChanMinus2_SetReg_0080_Bit15': (None, 'XBC = the literal 0x0010C000 (+2)'),
    'Dev10C_ChanMinus2_ClrReg_0080_Bit15': (None, 'XBC = the literal 0x0010C000 (+2)'),
}
owner, edges = g.graph()
cl = g.closure(set(BETWEEN), edges)
STORE = re.compile(rb'^\s*(ld|ldw|add|adc|sub|sbc|and|andw|or|orw|xor|inc|dec|incw|decw|set|res|chg|tset|ex|rlc|rrc|sla|sra|srl|sll)\s+(?:[0-9]+,\s*)?(\([^)]*\))\s*,', re.I)
STORE1 = re.compile(rb'^\s*(inc|dec|incw|decw|set|res|chg|tset)\s+[0-9]+,\s*(\([^)]*\))\s*$', re.I)
cur, fail = None, 0
counts = {}
for raw, code in g.lines():
    m = g.LABEL.match(code)
    if m:
        if not g.is_local(m.group(1)):
            cur = m.group(1)
        code = code[m.end():]
    if cur not in cl:
        continue
    s = STORE.match(code) or STORE1.match(code)
    if not s:
        continue
    op = s.group(2)[1:-1].replace(b' ', b'').lower()
    if op.startswith(b'xiz'):
        kind = 'frame'
    elif re.fullmatch(rb'(0x)?[0-9a-f]+(:\d+)?', op):
        a = int(op.split(b':')[0], 16)
        kind = 'abs'
        if WIN[0] <= a < WIN[1]:
            fail += 1
            print('FAIL abs store into the struct:', cur.decode(), code.strip().decode())
    else:
        kind = 'reg'
        if cur.decode() not in REG_BASES:
            fail += 1
            print('FAIL unexplained register store:', cur.decode(), code.strip().decode())
    counts.setdefault(cur.decode(), {}).setdefault(kind, 0)
    counts[cur.decode()][kind] += 1
# both tails hand the second burst XIX, loaded once in their prologue, and Stage_D never names XIX
ne = open(os.path.join(g.ROOT, 'prom_c/voice/note_engine.s'), 'rb').read()
for tail in (b'MidiNote_OnTail', b'MidiNote_OffTail'):
    if not re.search(tail + rb':\n(?:\t[^\n]*\n){4}\tlda\txix, \(0xD7A2:24\)', ne):
        fail += 1
        print('FAIL:', tail.decode(), 'prologue is not `lda xix,0x00D7A2`')
sd = ne[ne.index(b'\nVoiceRegs_Stage_D:'):]
sd = sd[:sd.index(b'FB2F73')]
if re.search(rb'^\t[a-z]+\t[^;]*\bxix\b', sd, re.M):
    fail += 1
    print('FAIL: VoiceRegs_Stage_D names XIX')
print('closure:', sorted(c.decode() for c in cl))
for r in sorted(counts):
    print('  %-30s %s   %s' % (r, counts[r], REG_BASES.get(r, (0, ''))[1]))
print('FAILURES:', fail)
sys.exit(1 if fail else 0)
