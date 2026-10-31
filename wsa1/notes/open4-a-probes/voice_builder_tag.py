#!/usr/bin/env python3
"""What does the Z test at 0xFB3946 test?  (N-75855f8f)

MidiNote_OnByPartMode's mode-0x00 loop reads WA = word (0x3BCF + 68*v + 1), the voice record's
word +0x01, and `and DE,0x0002 / jr Z` picks VoiceRegs_Stage_A (bit clear) or _C (bit set).

Byte +0x01 is written when the record is BUILT, in the staging copy at 0x5A53 + 68*element that
VoiceParams_Compute_* then copies over the voice record with MemCopyWords(68 bytes).  This probe
lists every such build-time store (staging +0x01 / +0x45 / +0x89 / +0xCD, i.e. element 0..3) and
the instruction that forms its low byte, and asserts the four builder TAGS:

    builder (and its orphan twin)        byte +0x01
    VoiceParams_Compute_A / sub_FB0B95   (layer << 6) | 0x04    layer = VelSplit_LayerFromVelocity
    VoiceParams_Compute_B / sub_FB1FB1   0x08                    (then `or 0x0800`: byte +0x02 bit 3)
    VoiceParams_Compute_C / sub_FB289A   (layer << 6) | 0x10
    VoiceParams_Compute_D / sub_FB2F74   (layer << 6) | 0x12    <- bit 1 set by D only

and that the only test of bit 1 of a voice record's word +0x01 anywhere in prom_c is 0xFB393A.
Exit 0 = PASS.  Run: python3 notes/open4-a-probes/voice_builder_tag.py
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prom_c_callgraph as g

# address of the store -> (routine, the low-byte-forming instruction text, tag)
EXPECT = {
    0xFB0CAF: ('sub_FB0B95', 'set\t2, c', 0x04),
    0xFB0F53: ('VoiceParams_Compute_A', 'set\t2, w', 0x04),
    0xFB1162: ('VoiceParams_Compute_A', 'set\t2, w', 0x04),
    0xFB139E: ('VoiceParams_Compute_A', 'set\t2, w', 0x04),
    0xFB1638: ('VoiceParams_Compute_A', 'set\t2, w', 0x04),
    0xFB18E6: ('VoiceParams_Compute_A', 'set\t2, w', 0x04),
    0xFB1BB8: ('VoiceParams_Compute_A', 'set\t2, w', 0x04),
    0xFB2093: ('sub_FB1FB1', 'ldw\t(xhl+1), 0x0008', 0x08),
    0xFB224F: ('VoiceParams_Compute_B', 'ldw\t(xhl+1), 0x0008', 0x08),
    0xFB23C6: ('VoiceParams_Compute_B', 'ldw\t(xbc+69), 0x0008', 0x08),
    0xFB253D: ('VoiceParams_Compute_B', 'ldw\t(xbc+137), 0x0008', 0x08),
    0xFB26CF: ('VoiceParams_Compute_B', 'ldw\t(xbc+205), 0x0008', 0x08),
    0xFB2CFE: ('VoiceParams_Compute_C', 'set\t4, w', 0x10),
    0xFB34BF: ('VoiceParams_Compute_D', 'or\tw, 18', 0x12),
    0xFB293C: ('sub_FB289A', 'set\t4, c', 0x10),
    0xFB2B3E: ('VoiceParams_Compute_C', 'set\t4, w', 0x10),
    0xFB307A: ('sub_FB2F74', 'or\tc, 18', 0x12),
    0xFB32B4: ('VoiceParams_Compute_D', 'or\tw, 18', 0x12),
}
ADDR = re.compile(rb';\s*([0-9A-F]{6})\b')
rows = []
cur = None
for raw, code in g.lines():
    m = g.LABEL.match(code)
    if m and not g.is_local(m.group(1)):
        cur = m.group(1).decode()
    a = ADDR.search(raw)
    rows.append((cur, int(a.group(1), 16) if a else None, code.strip().decode('latin1')))
fail = 0
found = {}
for i, (r, a, c) in enumerate(rows):
    if a is None or not r or not r.startswith(('VoiceParams_Compute_', 'sub_FB0B95', 'sub_FB1FB1', 'sub_FB289A', 'sub_FB2F74')):
        continue
    if re.match(r'ldw?\s+\(x[a-z]{2}\+(1|69|0x89|137|0xCD|205)\),', c):
        win = [rows[j][2] for j in range(max(0, i - 6), i + 1)]
        found[a] = (r, win)
for a, (r, win) in sorted(found.items()):
    exp = EXPECT.get(a)
    ok = exp and exp[0] == r and any(w.startswith(exp[1]) for w in win)
    print('%06X  %-24s %-28s %s' % (a, r, (exp[1].replace('\t', ' ') if exp else '?'),
                                    ('tag 0x%02X' % exp[2]) if ok else 'FAIL'))
    fail += not ok
missing = set(EXPECT) - set(found)
if missing:
    fail += 1
    print('FAIL: expected stores not found:', sorted(hex(m) for m in missing))
# readers: every `and rr,2` within 3 lines of a load from (xRR+0x3BCF)
readers = []
for i, (r, a, c) in enumerate(rows):
    if re.match(r'and\s+[a-z]{2},\s*2$', c):
        back = ' '.join(rows[j][2] for j in range(max(0, i - 3), i))
        if '0x3BCF' in back:
            readers.append(a)
print('voice +0x01 bit-1 tests:', [hex(x) for x in readers])
if readers != [0xFB393A]:
    fail += 1
    print('FAIL: expected exactly one test, at 0xFB393A')
# the voices the test visits are exactly the ones Compute_A just rebuilt:
# Compute_A copies staging element k-10 over voice list[k], k = 10..13 (0xFB1DA9 / 0xFB1DB4),
# and the arm walks the same list[10..13] (0xFB38D1 / 0xFB395A) of the same request buffer
at = {a: c for _, a, c in rows if a}
for a, txt in ((0xFB1DA5, 'call\tChanAlloc_ForNoteRequest'), (0xFB1DA9, 'ld\txbc, 10'),
               (0xFB1DB4, 'ld\t(xiz-1), 4'), (0xFB1DE7, 'call\tMemCopyWords'),
               (0xFB38D1, 'ld\txwa, 10'), (0xFB395A, 'cp\tl, 4:i3'), (0xFB393A, 'and\tde, 2')):
    if not at.get(a, '').startswith(txt):
        fail += 1
        print('FAIL at %06X: expected %r, have %r' % (a, txt, at.get(a)))
# nothing called between the copy and the test names the voice records or their staging copy
owner, edges = g.graph()
between = g.closure({b'Pack104_SetInputs_PartRecord', b'Pack104_SetInputs_SubRecordPair',
                     b'Dev104_WriteChanReg0'}, edges)
for r, a, c in rows:
    if r and r.encode() in between and re.search(r'3bcf|15311|5a53|23123', c, re.I):
        fail += 1
        print('FAIL: %s names a voice record base at %06X: %s' % (r, a, c))
print('callees between copy and test:', sorted(b.decode() for b in between))
print('FAILURES:', fail)
sys.exit(1 if fail else 0)
