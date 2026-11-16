#!/usr/bin/env python3
"""Scratch (lane_p6 helper D, round 9): writes p6_D_9m285.c / p6_D_9m285b.c (DataBuf_CopyBulkBitfields_Large) into the
scratch dir from the generator output gL.c.  Run 72 showed V4.23 adds the pointer first (s + offset) where the ROM adds
it last (offset + s), so the addresses are written as integers with the offset first.  Form a also copies the two
parameters into locals after the loop (the ROM reloads them into XIY / XIX, V4.23 into XWA)."""
import os

D = os.path.dirname(os.path.abspath(__file__))
gl = open(os.path.join(D, 'gL.c')).read()
head = gl[:gl.index('void DataBuf_CopyBulkBitfields_Large(')]
fn = gl[gl.index('void DataBuf_CopyBulkBitfields_Large('):]
sig, rest = fn.split('{', 1)
copies = rest.rsplit('}', 1)[0]

LOOP = """	for (i = 0; i < 2; i++)
		DataBuf_CopyVoiceBlock24((void *)(((unsigned long)i * 32 + 1008) + (unsigned long)s),
		                         (void *)((Math_Multiply32(i, 26) + 992) + (unsigned long)d));
"""
HDR = """/* Phase 6, lane_p6 helper D, round 9, module 285 (v10 midi/midi_dispatch_handlers.s), form %s:
   DataBuf_CopyBulkBitfields_Large.  Its callee DataBuf_CopyVoiceBlock24 is reached with calr (cc900-module line).
   Addresses are integers with the offset first: run 72 had V4.23 add the pointer first.%s
   The 111 copies after the loop are generated from the hand assembly (scratch bfgen.py). */

extern unsigned long Math_Multiply32(unsigned long, unsigned long);
extern void DataBuf_CopyVoiceBlock24(void *, void *);

"""
for form in 'ab':
    if form == 'a':
        body = ("{\n\tunsigned int i;\n\tstruct L_d *dd;\n\tstruct L_s *ss;\n\n" + LOOP + "\tdd = d;\n\tss = s;\n"
                + copies.replace('d->', 'dd->').replace('s->', 'ss->') + "}\n")
        note = '\n   The parameters are copied into locals after the loop (the ROM reloads them into XIY / XIX).'
    else:
        body = "{\n\tunsigned int i;\n\n" + LOOP + copies + "}\n"
        note = ''
    out = HDR % (form, note) + head + sig + body
    name = 'p6_D_9m285.c' if form == 'a' else 'p6_D_9m285b.c'
    open(os.path.join(D, name), 'w').write(out)
    print('wrote', name)
