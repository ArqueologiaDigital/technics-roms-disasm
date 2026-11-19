#!/usr/bin/env python3
"""Helper AO, round 23: write sub_AO_23a/b/c.c (tone-generator writers + Voice_Poly_NoteOn) for lane_sub.

Usage: python3 gen_ao23.py OUTDIR      (writes OUTDIR/sub_AO_23{a,b,c}.c)
"""
import os
import sys

OUT = sys.argv[1]


def W(addr, val, ind='    '):
    return (ind + 'ram_18 &= ~0x80; ram_100000 = (%s); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (%s); '
            '__asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");' % (addr, val))


HEADER = {
    'a': """/* lane_sub helper AO, round 23, form a (KN5000 sub-CPU payload v1.42, core/08_voice_noteon_and_tonegen.s and
   core/11_ringbuf_and_midi_dispatch.s).  Every tone-generator write in the matched writers' spelling (staged
   voice_noteon_and_tonegen_lane_23w2a.c): P6 as ram_18, latch / data port ram_100000 / ram_100002, inline assembly
   as the LOWER-CASE `__asm(" nop")` / `__asm(" jr $+2")`, so a value live across it stays in XIZ / IZ / QIZx.
   Form a: the plain spellings.
   - frame-style writers (`dec 4,xsp; pushw iz; ld (xsp+2),xbc; ld iz,wa`): plain (unsigned int reg, unsigned int *p),
     as ToneGen_WriteExtParams_56 matched.  ToneGen_WriteExtParams_15 / _56b / _15_Alt / _15_Banked / _TypeDispatch
     are ToneGen_WriteExtParams_56 / ToneGen_Write_ExtParam_05C0_Strobe / TG_WriteExtParam_TypeDisp_One with other
     register numbers and words; ToneGen_WriteLevelPair is a copy of ToneGen_WriteNote2ch, ToneGen_WriteLevelBurst of
     ToneGen_WriteVoice_6Words (same registers, same words).
   - _Ext / _Ext2 read a word at the ODD byte offset 45 of the second record: *(unsigned int *)((unsigned char *)p + 45).
   - ToneGen_WriteVoiceParams starts with a dead `ld wa,0`: an unused local, `unsigned int i = 0;`.
   - ToneGen_ReadPitch_AndScale: the data port written through the cast constant *(unsigned int *)0x100002 (the ROM
     loads 0x100002 with `ld xwa,imm` and keeps it in a frame slot across Math_Multiply32); the record is 71 bytes,
     so the index is a long product on a byte array, ram_430bb = Payload_Bss_Start+0x4245.
   - Voice_Poly_NoteOn: byte locals ch, note, vel declared in that order (the ROM keeps them in QIZH, QIZL, IZH), the
     status byte through a byte temporary s (the ROM tests the loaded E after taking the channel from it), ch reused
     as the release loop's counter (QIZH again), break out of the loop.
   - Also the dead routines that sit inside the pool rows' spans (pool sizes 194 / 591 B include them):
     ToneGen_WriteReg0840_Shadow2E, ToneGen_Write_Reg0180 / _0440 / _0480 / _04C0 (`push xiz; ld xiz,xbc`: a
     register pointer, as ToneGen_WriteVoice_EnvLevel matched), ToneGen_WriteVoice_TvfRegs_Dup and
     ToneGen_WriteReg0440_0480 (frame style).
   cc900-options: -Xr
*/
""",
    'b': """/* lane_sub helper AO, round 23, form b (same functions as sub_AO_23a.c; read its header first).
   Form b changes:
   - frame-style writers in staged voice_envelopes_and_channels_lane_23w1a.c's spelling: (register unsigned int reg,
     unsigned int *volatile p) (ToneGen_WriteNote2ch / _6Words / _TvfPair matched so); the register-pointer dead
     routines plain (unsigned int ch, unsigned int *p);
   - _Ext / _Ext2: the record pointer declared unsigned char *, each word read through a cast at its byte offset;
   - ToneGen_WriteVoiceParams: the unused local assigned by a statement, `unsigned int i; i = 0;`;
   - ToneGen_ReadPitch_AndScale: a pointer local q = (unsigned int *)0x100002 assigned right after the second
     `set 7,(P6)`, then *q = ...;
   - Voice_Poly_NoteOn: no temporary for the status byte (msg[1] read twice);
   - ToneGen_WriteGlobalConfig: register unsigned int *p.
   cc900-options: -Xr
*/
""",
    'c': """/* lane_sub helper AO, round 23, form c (same functions as sub_AO_23a.c; read its header first).
   Form c changes:
   - every record as struct tgv { unsigned int w[36]; } * (p->w[N]); frame-style writers plain parameters,
     register-pointer dead routines `register struct tgv *p`;
   - _Ext / _Ext2: the odd word as ((unsigned int *)((char *)p + 45))[0];
   - ToneGen_WriteVoiceParams: the dead `ld wa,0` as an expression statement `0;`;
   - ToneGen_ReadPitch_AndScale: pointer local q as in form b, the product signed ((long)reg * 71) and the mask
     written & 0x7fff;
   - Voice_Poly_NoteOn: byte locals declared vel, note, ch, s (reverse order), `return` instead of `break` in the
     release loop.
   cc900-options: -Xr
*/
""",
}

NAMES = """/* cc900-name: TG_WriteExtParams_15_Banked=ToneGen_WriteExtParams_15_Banked */
/* cc900-name: TG_WriteExtParams_TypeDispatch=ToneGen_WriteExtParams_TypeDispatch */
/* cc900-name: TG_WriteVoice_TvfRegs_Dup=ToneGen_WriteVoice_TvfRegs_Dup */
"""


def frame_params(form):
    if form == 'b':
        return 'register unsigned int reg, unsigned int *volatile p'
    if form == 'c':
        return 'unsigned int reg, struct tgv *p'
    return 'unsigned int reg, unsigned int *p'


def regp_params(form):
    if form == 'a':
        return 'unsigned int reg, register unsigned int *p'
    if form == 'c':
        return 'unsigned int reg, register struct tgv *p'
    return 'unsigned int reg, unsigned int *p'


def w(form, n, pv='p'):
    return '%s->w[%d]' % (pv, n) if form == 'c' else '%s[%d]' % (pv, n)


def func(name, params, body):
    return 'void %s(%s)\n{\n%s\n}\n' % (name, params, '\n'.join(body))


def bitpair(form, base, n):
    """if (p[n] & 0x8000) W(reg+base, p[n]); ... caller adds the middle; returns (head, tail)"""
    x = w(form, n)
    head = ['    if (%s & 0x8000) {' % x, W('reg + 0x%x' % base, x, '        '), '    }']
    tail = [W('reg + 0x%x' % base, '%s & ~0x8000' % x)]
    return head, tail


def gen(form):
    fp = frame_params(form)
    rp = regp_params(form)
    protos, funcs = [], []

    def add(name, params, body, cname=None):
        protos.append('void %s(%s);' % (cname or name, params))
        funcs.append(func(cname or name, params, body))

    # ToneGen_WriteVoiceParams (794 B)
    regs = [(0x40, 1, ''), (0x80, 2, ' | 0x8000'), (0xc0, 3, ''), (0x100, 4, ''), (0x140, 5, ''), (0x180, 6, ''),
            (0x400, 7, ''), (0x440, 8, ''), (0x480, 9, ''), (0x4c0, 10, ''), (0x500, 11, ''), (0x800, 12, ''),
            (0, None, ''), (0x840, 13, ''), (0x880, 14, ''), (0x8c0, 15, ''), (0x900, 16, ''), (0x940, 17, ''),
            (0x980, 18, ''), (0x9c0, 19, ''), (0xa00, 20, ''), (0xa40, 21, ''), (0x80, 2, ' & ~0x8000')]
    body = []
    if form == 'a':
        body += ['    unsigned int i = 0;', '']
    elif form == 'b':
        body += ['    unsigned int i;', '', '    i = 0;']
    else:
        body += ['    0;']
    for base, n, op in regs:
        if n is None:
            body.append(W('reg', '0x8100'))
        else:
            body.append(W('reg + 0x%x' % base, w(form, n) + op))
    add('ToneGen_WriteVoiceParams', fp, body)

    # ToneGen_WriteGlobalConfig (233 instructions of its own, then dead routines)
    gp = {'a': 'unsigned int *p', 'b': 'register unsigned int *p', 'c': 'struct tgv *p'}[form]
    body = ['    if (ram_41343 & 8) %s &= ~8;' % w(form, 0), '    else %s |= 8;' % w(form, 0)]
    for i, a in enumerate([0x200, 0x201, 0x202, 0x203, 0x204, 0x205, 0xc00, 0xc01, 0xc02, 0xc03, 0xc04, 0xc05,
                           0xe00]):
        body.append(W('0x%x' % a, w(form, i)))
    add('ToneGen_WriteGlobalConfig', gp, body)
    add('ToneGen_WriteReg0440_0480', fp, [W('reg + 1088', w(form, 8)), W('reg + 1152', w(form, 9))])
    add('ToneGen_Write_Reg0180', rp, [W('reg + 384', w(form, 6))])
    add('ToneGen_Write_Reg0440', rp, [W('reg + 1088', w(form, 8))])
    add('ToneGen_Write_Reg0480', rp, [W('reg + 1152', w(form, 9))])
    add('ToneGen_Write_Reg04C0', rp, [W('reg + 1216', w(form, 10))])

    # ToneGen_WriteExtParams_15_Banked
    h1, t1 = bitpair(form, 1344, 29)
    h2, t2 = bitpair(form, 1408, 31)
    body = ['    if (reg < 64) {'] + ['    ' + l for l in h1] + ['    ' + W('reg + 448', w(form, 28))] + \
           ['    ' + l for l in t1] + ['    } else {'] + ['    ' + l for l in h2] + \
           ['    ' + W('reg + 1536', w(form, 33))] + ['    ' + l for l in t2] + ['    }']
    add('ToneGen_WriteExtParams_15_Banked', fp, body, 'TG_WriteExtParams_15_Banked')

    # ToneGen_WriteLevelBurst (= ToneGen_WriteVoice_6Words) and ToneGen_WriteLevelPair (= ToneGen_WriteNote2ch)
    add('ToneGen_WriteLevelBurst', fp, [W('reg + 0x840', w(form, 23)), W('reg + 0x940', w(form, 25)),
                                        W('reg + 0xa00', w(form, 27)), W('reg + 0x800', w(form, 22)),
                                        W('reg + 0x900', w(form, 24)), W('reg + 0x9c0', w(form, 26))])
    add('ToneGen_WriteLevelPair', fp, [W('reg + 0x840', w(form, 23)), W('reg + 0x800', w(form, 22))])
    add('ToneGen_WriteReg0840_Shadow2E', rp, [W('reg + 2112', w(form, 23))])
    add('ToneGen_WriteVoice_TvfRegs_Dup', fp, [W('reg + 256', w(form, 4)), W('reg + 320', w(form, 5))],
        'TG_WriteVoice_TvfRegs_Dup')

    # ToneGen_WriteExtParams_TypeDispatch
    h1, t1 = bitpair(form, 0x540, 29)
    h2, t2 = bitpair(form, 0x580, 31)
    body = ['    if (reg < 0x40) {'] + ['    ' + l for l in h1 + t1] + ['    } else {'] + \
           ['    ' + l for l in h2 + t2] + ['    }']
    add('ToneGen_WriteExtParams_TypeDispatch', fp, body, 'TG_WriteExtParams_TypeDispatch')

    # _Ext (reg, p2 in XBC, p3 in XDE) and _Ext2 (reg, p)
    def odd(pv):
        if form == 'a':
            return '*(unsigned int *)((unsigned char *)%s + 45)' % pv
        if form == 'b':
            return '*(unsigned int *)(%s + 45)' % pv
        return '((unsigned int *)((char *)%s + 45))[0]' % pv

    def word(pv, n):
        if form == 'b' and pv != 'p2':
            return '*(unsigned int *)(%s + %d)' % (pv, n * 2)
        return w(form, n, pv)

    if form == 'b':
        ep = 'register unsigned int reg, unsigned int *volatile p2, unsigned char *volatile p3'
        ep2 = 'register unsigned int reg, unsigned char *volatile p'
    elif form == 'c':
        ep = 'unsigned int reg, struct tgv *p2, struct tgv *p3'
        ep2 = 'unsigned int reg, struct tgv *p'
    else:
        ep = 'unsigned int reg, unsigned int *p2, unsigned int *p3'
        ep2 = 'unsigned int reg, unsigned int *p'
    add('ToneGen_WriteVoiceParams_Ext', ep,
        [W('reg + 0x800', word('p3', 30)), W('reg', '0x8100'), W('reg + 0x840', word('p3', 31)),
         W('reg + 0x80', '%s & ~0x8000' % word('p2', 2)), W('reg', odd('p3'))])
    add('ToneGen_WriteVoiceParams_Ext2', ep2,
        [W('reg + 0x800', word('p', 30)), W('reg', '0x8100'), W('reg + 0x840', word('p', 31)),
         W('reg', odd('p'))])

    # ToneGen_ReadPitch_AndScale (calls Math_Multiply32 absolutely: a long product)
    if form == 'a':
        rv = ['    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80;',
              '    *(unsigned int *)0x100002 = *(unsigned int *)(ram_430bb + (unsigned long)reg * 71) & ~0x8000;']
        decl = []
    else:
        prod = '(unsigned long)reg * 71' if form == 'b' else '(long)reg * 71'
        mask = '~0x8000' if form == 'b' else '0x7fff'
        rv = ['    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80;',
              '    q = (unsigned int *)0x100002;',
              '    *q = *(unsigned int *)(ram_430bb + %s) & %s;' % (prod, mask)]
        decl = ['    unsigned int *q;', '']
    rv += ['    __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");']
    add('ToneGen_ReadPitch_AndScale', 'unsigned int reg, %s' % ('struct tgv *p' if form == 'c' else
                                                                'unsigned int *p'),
        decl + [W('reg + 0xc0', w(form, 3))] + rv)

    # the three small ones
    h, t = bitpair(form, 0x540, 29)
    add('ToneGen_WriteExtParams_15', fp, h + [W('reg + 0x1c0', w(form, 28))] + t)
    h, t = bitpair(form, 0x5c0, 31)
    add('ToneGen_WriteExtParams_56b', fp, h + [W('reg + 0x640', w(form, 33))] + t)
    h, t = bitpair(form, 0x540, 29)
    add('ToneGen_WriteExtParams_15_Alt', fp, h + t)

    # Voice_Poly_NoteOn
    if form == 'c':
        decl = ['    unsigned char vel;', '    unsigned char note;', '    unsigned char ch;', '    unsigned char s;']
    elif form == 'b':
        decl = ['    unsigned char ch;', '    unsigned char note;', '    unsigned char vel;']
    else:
        decl = ['    unsigned char ch;', '    unsigned char note;', '    unsigned char vel;', '    unsigned char s;']
    if form == 'b':
        head = ['    ch = msg[1] & 0x0f;', '    if (msg[1] < 0xf0) return;']
    else:
        head = ['    s = msg[1];', '    ch = s & 0x0f;', '    if (s < 0xf0) return;']
    leave = 'return;' if form == 'c' else 'break;'
    body = decl + [''] + head + [
        '    if (ch > 5) ch = 0;',
        '    ram_3b13 = (ram_3b13 + 1) & 7;',
        '    vel = msg[3] & 0x7f;',
        '    note = msg[2] & 0x7f;',
        '    if (vel != 0) {',
        W('ram_3b13 + 0x840', '0xff00', '        '),
        W('ram_3b13 + 0x800', '0xff80', '        '),
        '        Voice_PolyNoteOn_Setup_PtrTable[ch](ram_3b13, ch, note, vel);',
        '        ram_3b14[ram_3b13] = note | 0x80;',
        '    } else {',
        '        note |= 0x80;',
        '        for (ch = 0; ch < 8; ch++) {',
        '            if (ram_3b14[ch] == note) {',
        W('ch + 0x840', '0xa200', '                '),
        W('ch + 0x800', '0xa280', '                '),
        '                ram_3b14[ch] &= ~0x80;',
        '                ' + leave,
        '            }',
        '        }',
        '    }']
    protos.append('void Voice_Poly_NoteOn(unsigned char *msg);')
    funcs.append(func('Voice_Poly_NoteOn', 'unsigned char *msg', body))

    ext = ['extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */',
           'extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */',
           'extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */',
           'extern unsigned int ram_41343;                  /* Voice_GlobalFlags */',
           'extern unsigned char ram_430bb[];               /* Payload_Bss_Start+0x4245: 71-byte records */',
           'extern unsigned char __near ram_3b13;           /* the poly round-robin slot, 0..7 */',
           'extern unsigned char __near ram_3b14[];         /* per slot: note | 0x80 while sounding */',
           'extern void (*Voice_PolyNoteOn_Setup_PtrTable[])(int, int, int, int);']
    if form == 'c':
        ext.append('struct tgv { unsigned int w[36]; };')
    return HEADER[form] + '\n' + '\n'.join(ext) + '\n' + '\n'.join(protos) + '\n\n' + NAMES + '\n'.join(funcs)


for f in 'abc':
    path = os.path.join(OUT, 'sub_AO_23%s.c' % f)
    with open(path, 'w') as fh:
        fh.write(gen(f))
    print('wrote', path)
