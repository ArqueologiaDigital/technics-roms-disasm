#!/usr/bin/env python3
"""Write lane_sub helper T's round-18 files sub_T_18a.c, sub_T_18b.c, sub_T_18c.c (KN5000 sub-CPU payload v1.42).

QUESTION ANSWERED: which C spelling makes V4.23 (-Xr) give the ROM's code for the functions round 17 left open with
a sub_N_17* best attempt, and for DSP_InitChannelSlot / DSP_WriteAlgoBuffer of pool D.  Each function's text is
taken from its best earlier corpus file (sub_N_17c, sub_D_8c, sub_D_6c) and changed only where the form says; every
replacement is asserted to have happened.  New functions are written here.

    python3 -B gen_T_18.py /home/fsanches/compartilhado/disasm-lanes/csub
"""
import os
import re
import sys

ROOT = sys.argv[1]
FW = os.path.join(ROOT, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')


def text(stem):
    return open(os.path.join(FW, stem + '.c'), encoding='latin-1').read()


def get(stem, name):
    """The definition of function `name` in corpus file `stem`.c."""
    m = re.search(r'^[A-Za-z_][^\n;{]*\b' + re.escape(name) + r'\([^;{]*\)\n\{\n.*?^\}\n', text(stem), re.S | re.M)
    assert m, (stem, name)
    return m.group(0)


def rep(t, old, new, count=None):
    n = t.count(old)
    assert n and (count is None or n == count), (old, n)
    return t.replace(old, new)


SLOTI = '((struct slot *)(p + ((unsigned long)i * 56 + 8)))'

WHY = {
    'a': """Flag arrays (0x4930.., 0x45d4.., 0x4600): byte arrays indexed by an explicit 16-bit byte offset,
     W(base, i * 50 + j * 2) (round 8 showed a native [i][j] loads the index into a second register first; an
     explicit unsigned `* 2` copies once and doubles by add).  The idx column is `<< 1` of an unsigned member
     (the ROM shifts), the order-table column is the LEFT term, (unsigned int)*q * 2 + slot * 50.
   DiffAllAndFlag: the on-flag test is slot->on != word at ram_4600[i * 56 + 8] (the ROM builds that address first).
   InitFlags: k declared in the `if (i == 1)` block.
   EFF_SecondaryLinkPath: m an int (the ROM converts it before the table byte is read), declared after i.
   EGEnv_Compute_B: EGEnv_Compute_A's matching spelling, (unsigned int)x | T[..] with an int table.
   VoiceParam_Set_Tone_Option: int o = (int)(unsigned int)idx + 472 in one assignment, then ram_44fce[o].
   DSP_VoiceCoeffRoute2: form c of round 17 with the relocation written integer + pointer, RelBase + tbl.
   Debug_Print_Word: the low byte as (unsigned char)(w & 0xff), unsigned int prototype.
   RingBuf_ReadByte / DSP_RingBuf_Read: r->buf[(unsigned long)i] through an unsigned int local.
   DSP1_ResolveStreamPtr: the table offset, the entry and a copy of the base each a local.
   DSP_FlushAllSlots: the buffer pointer a byte pointer, every address index-first (index + pointer); the image a
     295-byte char-array struct; the slot pair addressed as &((struct e2 *)0x49a7)[i] + buffer.
   DSP_InitChannelSlot (new): reload-after-store idiom for the record address (u, then t = u, q = u + 16).
   DSP_WriteAlgoBuffer (new): byte locals, the 426-byte image and the 11-byte routes as struct copies.""",
    'b': """Flag arrays: as form a with the column doubled by add, (j + j).
   InitFlags: k a register local of the `if (i == 1)` block.
   EFF_SecondaryLinkPath: m an int declared before i.
   EGEnv_Compute_B: (unsigned int)x | (unsigned int)(int)T[..] with an unsigned table (A's second match).
   VoiceParam_Set_Tone_Option: int o; o = (unsigned int)idx; o += 472.
   DSP_VoiceCoeffRoute2: the relocation as (long)RelBase + tbl.
   Debug_Print_Word: as form a with the boot ROM routine unprototyped.
   RingBuf_ReadByte / DSP_RingBuf_Read: *(((unsigned long)i + 6) + (unsigned char *)r) through an unsigned int local.
   DSP1_ResolveStreamPtr: as form a with the locals declared in the reverse order.
   DSP_FlushAllSlots / DSP_InitChannelSlot: the buffer pointer cell an unsigned long (no pointer cast to copy it);
     InitChannelSlot without the second local.
   DSP_WriteAlgoBuffer: the loop counter an unsigned int assigned to nothing else; destination through a pointer local.""",
    'c': """Flag arrays: round 8's 2-D word arrays kept, read through W(base, s) = byte pointer + (unsigned int)s.
   InitFlags: k a function-level local declared first.
   EFF_SecondaryLinkPath: m an int, i a register int.
   EGEnv_Compute_B: (unsigned int)x | T[..] with an unsigned table.
   VoiceParam_Set_Tone_Option: int o = (int)(unsigned int)idx; o += 472.
   DSP_VoiceCoeffRoute2: the relocation through an unsigned long local, t = RelBase; t += tbl.
   Debug_Print_Word: (unsigned char)(w & 255), int prototype.
   RingBuf_ReadByte / DSP_RingBuf_Read: ((unsigned long)i + 6)[(unsigned char *)r] through an unsigned int local.
   DSP1_ResolveStreamPtr: v declared first.
   DSP_FlushAllSlots: form a with the slot pair address written (unsigned long)i * 2 + 0x49a7.
   DSP_InitChannelSlot: form a with the 11-byte destinations as pointer + 58 / + 69 instead of members.
   DSP_WriteAlgoBuffer: form a with the range test as two ifs.""",
}

FORMS = {
    'a': dict(
        bytearrays=True, j2='(j) * 2', q2='(unsigned int)(c) * 2',
        w='#define WT(type, base, s) (*(type *)&(base)[s])\n#define B4930 ram_4930\n',
        kdecl='block', seclink='    int i;\n    int m;\n',
        modebits='extern int EGEnv_ModeBits_Table[];',
        eg_b='    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];\n',
        tone='    int o;\n\n    o = (int)(unsigned int)idx + 472;\n    ram_44fce[o] = v;\n',
        reloc=('', '    tbl = ToneDB_RelBase + tbl;\n'),
        hexproto='extern void BootROM_HEX_BYTE_TO_ASCII(unsigned int);',
        dbg='(unsigned char)(w & 0xff)',
        ring='        u = r->buf[(unsigned long)i];\n        c = u;\n',
        resolve='    unsigned char *base;\n    unsigned long *tbl;\n    unsigned long off;\n    unsigned long v;\n    unsigned char *q;\n',
        bufptr=True, img='struct img295 { unsigned char b[295]; };',
        pair='((struct e2 *)((unsigned long)&((struct e2 *)0x49a7)[i] + ram_4531c))->b1',
        second=True, member=True, wab='a',
    ),
    'b': dict(
        bytearrays=True, j2='((j) + (j))', q2='(c) * 2u',
        w='#define WT(type, base, s) (*(type *)&(base)[s])\n#define B4930 ram_4930\n',
        kdecl='register', seclink='    int m;\n    int i;\n',
        modebits='extern unsigned int EGEnv_ModeBits_Table[];',
        eg_b='    return (unsigned int)x | (unsigned int)(int)EGEnv_ModeBits_Table[p[0] & 3];\n',
        tone='    int o;\n\n    o = (unsigned int)idx;\n    o += 472;\n    ram_44fce[o] = v;\n',
        reloc=('', '    tbl = (long)ToneDB_RelBase + tbl;\n'),
        hexproto='extern void BootROM_HEX_BYTE_TO_ASCII();',
        dbg='(unsigned char)(w & 0xff)',
        ring='        u = *(((unsigned long)i + 6) + (unsigned char *)r);\n        c = u;\n',
        resolve='    unsigned char *q;\n    unsigned long v;\n    unsigned long off;\n    unsigned long *tbl;\n    unsigned char *base;\n',
        bufptr=False, img='struct img295 { unsigned char b[294]; unsigned char last; };',
        pair='((struct e2 *)((unsigned long)&((struct e2 *)0x49a7)[i] + ram_4531c))->b1',
        second=False, member=True, wab='b',
    ),
    'c': dict(
        bytearrays=False, j2='(j) * 2', q2='(unsigned int)(c) * 2',
        w=('#define WT(type, base, s) (*(type *)((unsigned char *)(base) + (unsigned int)(s)))\n'
           '#define B4930 &EFF_SlotActiveFlags\n'),
        kdecl='first', seclink='    register int i;\n    int m;\n',
        modebits='extern unsigned int EGEnv_ModeBits_Table[];',
        eg_b='    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];\n',
        tone='    int o = (int)(unsigned int)idx;\n\n    o += 472;\n    ram_44fce[o] = v;\n',
        reloc=('    unsigned long t;\n', '    t = ToneDB_RelBase;\n    t += (unsigned long)tbl;\n    tbl = (unsigned char *)t;\n'),
        hexproto='extern void BootROM_HEX_BYTE_TO_ASCII(int);',
        dbg='(unsigned char)(w & 255)',
        ring='        u = ((unsigned long)i + 6)[(unsigned char *)r];\n        c = u;\n',
        resolve='    unsigned long v;\n    unsigned char *base;\n    unsigned long *tbl;\n    unsigned long off;\n    unsigned char *q;\n',
        bufptr=True, img='struct img295 { unsigned char b[295]; };',
        pair='((struct e2 *)(((unsigned long)i * 2 + 0x49a7) + ram_4531c))->b1',
        second=True, member=False, wab='c',
    ),
}

TOP = """/* lane_sub helper T, round 18, form %(form)s (KN5000 sub-CPU payload v1.42); written by gen_T_18.py (lane_sub's
   scratch T/).  The functions round 17 left open with a sub_N_17* best attempt, each its best earlier file
   (sub_N_17c, sub_D_8c, sub_D_6c) changed only where said, and two new ones of pool D:
   %(why)s */

/* cc900-module: DSP_WriteCount_Compute */
"""

MACROS = """#define FL(base, i, j) WT(unsigned int, base, (i) * 50 + %(j2)s)
#define FL56(type, base, i, j) WT(type, base, (i) * 56 + %(j2)s)
#define FLI(i, x) WT(unsigned int, ram_4944, (i) * 50 + ((x) << 1))
#define FLGQ(slot, c) WT(unsigned int, ram_4944, %(q2)s + (slot) * 50)
"""

EXTRA = """
struct b58 { unsigned char b[58]; };
struct b11 { unsigned char b[11]; };
struct b426 { unsigned char b[426]; };
struct e80 { unsigned char a[58]; unsigned char x[11]; unsigned char y[11]; };
struct p442 { unsigned char pad[442]; unsigned char x[11]; };
struct p121 { unsigned char pad[121]; unsigned char f[1]; };
extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
unsigned int DSP_WriteCount_Compute(void);
void DSP_InitChannelSlot(unsigned char *rec, unsigned int n);

"""


def header(form, f):
    t = text('sub_N_17c')
    t = t[:t.index('int DSP_AlgoDescriptor_Emit(')]
    c0 = t.index('/* cc900-module:')
    t = TOP % dict(form=form, why=WHY[form]) + t[c0:]
    a = t.index('#define JT ')
    b = t.index('\n', t.index('#define KSET')) + 1
    t = t[:a] + f['w'] + MACROS % f + t[b:]
    t = rep(t, 'int param[17]; int idx;', 'int param[17]; unsigned int idx;', 1)
    t = rep(t, 'extern struct sv56 __near ram_4600[];', 'extern unsigned char __near ram_4600[];', 1)
    a = t.index('struct img295 {')
    b = t.index('\n', t.index('#define G7800')) + 1
    t = t[:a] + f['img'] + '\n' + t[b:]
    if f['bytearrays']:
        for old in ('extern unsigned int __near ram_45d4[][28];', 'extern int __near ram_45d6[][28];',
                    'extern int __near ram_45fa[][28];', 'extern unsigned int __near ram_4942[][25];',
                    'extern unsigned int __near ram_4944[][25];', 'extern unsigned int __near ram_4966[][25];'):
            name = re.search(r'ram_[0-9a-f]+', old).group(0)
            t = rep(t, old, 'extern unsigned char __near %s[];' % name, 1)
        t = rep(t, 'extern struct fxflags __near EFF_SlotActiveFlags;',
                'extern struct fxflags __near EFF_SlotActiveFlags;\nextern unsigned char __near ram_4930[];', 1)
    if not f['bufptr']:
        t = rep(t, 'extern unsigned char *ram_4531c;', 'extern unsigned long ram_4531c;', 1)
    t = rep(t, 'extern unsigned int EGEnv_ModeBits_Table[];', f['modebits'], 1)
    t = rep(t, 'extern void BootROM_HEX_BYTE_TO_ASCII(unsigned int);', f['hexproto'], 1)
    t = rep(t, 'extern void DSP_InitChannelSlot();\n', '', 1)
    return t.rstrip('\n') + '\n' + EXTRA


def egenv(f):
    t = get('sub_N_17c', 'EGEnv_Compute_B')
    t = rep(t, '{\n    unsigned int m;\n', '{\n', 1)
    t = rep(t, '    m = EGEnv_ModeBits_Table[p[0] & 3];\n    return (unsigned int)x | m;\n', f['eg_b'], 1)
    return t + '\n'


def tone(f):
    t = get('sub_N_17c', 'VoiceParam_Set_Tone_Option')
    t = rep(t, '    ram_44fce[(int)(unsigned int)idx + 472] = v;\n', f['tone'], 1)
    return t + '\n'


def route(f):
    t = get('sub_N_17c', 'DSP_VoiceCoeffRoute2')
    decl, reloc = f['reloc']
    t = rep(t, '    unsigned int i;\n\n    s = sel;\n', '    unsigned int i;\n' + decl + '\n    s = sel;\n', 1)
    t = rep(t, '    tbl = *(unsigned char **)&ToneDB_RelBase + (unsigned long)tbl;\n', reloc, 1)
    return t + '\n'


DEBUG = """void Debug_Print_Word(unsigned int w)
{
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(w >> 8));
    __WA = 0;
    BootROM_HEX_BYTE_TO_ASCII(%s);
    __WA = 0;
}

"""

RING = """int %(name)s(struct %(st)s *r)
{
    unsigned int i;
    int c;
    unsigned int u;

    if (r->n != 0) {
        i = r->r++ & %(mask)s;
%(read)s        r->n--;
    } else
        c = -1;
    return c;
}

"""

RESOLVE = """unsigned char *DSP1_ResolveStreamPtr(unsigned int n)
{
%s
    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    off = *(unsigned long *)(base + 8);
    tbl = (unsigned long *)(base + off);
    tbl += n;
    v = *tbl;
    q = base;
    base += v;
    return base;
}

"""


def flush(f):
    if f['bufptr']:
        copy = '    *(struct img295 *)(ram_4531c + 0x4980) = *(struct img295 *)rec;\n'
        hdr = '        *(((unsigned long)i + 0x4980) + ram_4531c) = DSP1_ImageHeader_UserKit[i];\n'
    else:
        copy = '    *(struct img295 *)(ram_4531c + 0x4980) = *(struct img295 *)rec;\n'
        hdr = '        *(unsigned char *)(((unsigned long)i + 0x4980) + ram_4531c) = DSP1_ImageHeader_UserKit[i];\n'
    return ('void DSP_FlushAllSlots(unsigned char a, unsigned char b)\n{\n    unsigned char *rec;\n    unsigned int i;\n\n'
            '    rec = (unsigned char *)ToneDB_Find_ToneRecord(a, b);\n' + copy +
            '    for (i = 0; i < 0x80; i++) {\n        %s &= ~0x20;\n        %s |= 0x20;\n    }\n' % (f['pair'], f['pair']) +
            '    for (i = 0; i < 0x80; i++)\n        DSP_InitChannelSlot(rec, i);\n'
            '    for (i = 0; i < 0x10; i++)\n' + hdr +
            '    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, 0x1e0000L);\n}\n\n')


def initslot(f):
    e80 = '(((unsigned long)n * 80 + 0x4aa7) + ram_4531c)'
    if f['member']:
        dx = '*(struct b11 *)((struct e80 *)%s)->x' % e80
        dy = '*(struct b11 *)((struct e80 *)%s)->y' % e80
    else:
        dx = '*(struct b11 *)((unsigned char *)%s + 58)' % e80
        dy = '*(struct b11 *)((unsigned char *)%s + 69)' % e80
    if f['second']:
        decl = '    unsigned char *t;\n    unsigned char *q;\n    unsigned char *u;\n'
        addr = '    u = (unsigned char *)%s;\n    t = u;\n    q = u + 16;\n' % e80
    else:
        decl = '    unsigned char *t;\n    unsigned char *q;\n'
        addr = '    t = (unsigned char *)%s;\n    q = t + 16;\n' % e80
    return ('void DSP_InitChannelSlot(unsigned char *rec, unsigned int n)\n{\n' + decl + '\n'
            '    t = ToneDB_Find_SubToneRecord(rec, (unsigned char)n, 0xff);\n'
            '    *(struct b58 *)%s = *(struct b58 *)t;\n' % e80 + addr +
            '    %s = *(struct b11 *)WaveSel_StageA1_FromToneSlot(0, q, (unsigned char)n, 0xff);\n' % dx +
            '    q[2] &= 0xcf;\n    q[2] |= 0x10;\n'
            '    q = t + 37;\n'
            '    %s = *(struct b11 *)WaveSel_StageA1_FromToneSlot(1, q, (unsigned char)n, 0xff);\n' % dy +
            '    q[2] &= 0xcf;\n    q[2] |= 0x10;\n}\n\n')


def algobuf(f):
    buf = 'ram_4531c' if f['bufptr'] else '((unsigned char *)ram_4531c)'
    if f['wab'] == 'c':
        test = '    if (part >= 0x1a)\n        return 2;\n    if (slot >= 0x28)\n        return 2;\n'
    else:
        test = '    if (part >= 0x1a || slot >= 0x28)\n        return 2;\n'
    if f['wab'] == 'b':
        decl = '    unsigned char i;\n    unsigned char *x;\n    unsigned char *d;\n'
        dst = ('        d = &%s[slot * 0x1d6 + i * 11];\n'
               '        *(struct b11 *)((struct p442 *)d)->x = *(struct b11 *)ROUTE(part, i);\n' % buf)
    else:
        decl = '    unsigned char i;\n    unsigned char *x;\n'
        dst = ('        *(struct b11 *)((struct p442 *)&%s[slot * 0x1d6 + i * 11])->x = *(struct b11 *)ROUTE(part, i);\n' % buf)
    return ('unsigned char DSP_WriteAlgoBuffer(unsigned char part, unsigned char slot)\n{\n' + decl + '\n' + test +
            '    *(struct b426 *)&%s[slot * 0x1d6 + 0x10] = *(struct b426 *)*(unsigned char **)&ram_4136e[part * 0x11f];\n' % buf +
            '    for (i = 0; i < 4; i++) {\n' + dst +
            '        x = ((struct p121 *)&%s[slot * 0x1d6 + i * 81])->f;\n' % buf +
            '        if ((*x & 0xc0) != 0xc0) {\n            *x &= 0xcf;\n            *x |= 0x10;\n        }\n    }\n'
            '    *(unsigned int *)(%s + 0x72a8) = DSP_WriteCount_Compute();\n' % buf +
            '    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, 0x1e0000L);\n    return 0;\n}\n\n')


def eff(f):
    out = ''
    t = get('sub_D_8c', 'EFF_VolumeLoop')
    t = rep(t, 'ram_4944[i][' + SLOTI + '->idx]', 'FLI(i, ' + SLOTI + '->idx)', 1)
    if f['bytearrays']:
        t = rep(t, '    int d;\n', '    unsigned int d;\n', 1)
    out += t + '\n'

    t = get('sub_D_8c', 'EFF_SlotActive_UpdateFlags')
    t = rep(t, 'ram_4944[i][' + SLOTI + '->idx]', 'FLI(i, ' + SLOTI + '->idx)', 1)
    out += t + '\n'

    t = get('sub_D_8c', 'EFF_ParamIterator_Process')
    t = rep(t, 'ram_4944[slot][i]', 'FL(ram_4944, slot, i)', 1)
    t = rep(t, 'ram_4944[slot][*q]', 'FLGQ(slot, *q)', 1)
    out += t + '\n'

    t = get('sub_D_8c', 'DSP_EFFParam_DiffAllAndFlag')
    t = rep(t, 'ram_45d4[i][j]', 'FL56(unsigned int, ram_45d4, i, j)', 1)
    t = rep(t, 'ram_45d6[i][j]', 'FL56(int, ram_45d6, i, j)', 1)
    t = rep(t, 'ram_45fa[i][j]', 'FL56(int, ram_45fa, i, j)', 1)
    for name in ('ram_4942', 'ram_4944', 'ram_4966'):
        t = rep(t, name + '[i][j]', 'FL(%s, i, j)' % name, 2)
    t = rep(t, 'if (*(int *)((unsigned long)&ram_4600 + (i * 56 + 8)) != ' + SLOTI + '->on) {',
            'if (' + SLOTI + '->on != WT(int, ram_4600, i * 56 + 8)) {', 1)
    out += t + '\n'

    t = get('sub_D_8c', 'EFF_DspChannel_InitFlags')
    for name in ('ram_4942', 'ram_4944', 'ram_4966'):
        t = rep(t, name + '[i][j]', 'FL(%s, i, j)' % name, 1)
    t = rep(t, '*(unsigned int *)((unsigned long)&EFF_SlotActiveFlags + (k * 2 + 0x14)) = 1;',
            'WT(unsigned int, B4930, k * 2 + 0x14) = 1;', 2)
    t = rep(t, 'ram_4944[i][' + SLOTI + '->idx]', 'FLI(i, ' + SLOTI + '->idx)', 1)
    head = '    unsigned int i;\n    unsigned int j;\n    unsigned int k;\n'
    blk = '            if (i == 1) {\n'
    if f['kdecl'] == 'first':
        t = rep(t, head, '    unsigned int k;\n    unsigned int i;\n    unsigned int j;\n', 1)
    else:
        t = rep(t, head, '    unsigned int i;\n    unsigned int j;\n', 1)
        kw = 'register unsigned int k;' if f['kdecl'] == 'register' else 'unsigned int k;'
        t = rep(t, blk, blk + '                ' + kw + '\n\n', 1)
    out += t + '\n'

    t = get('sub_D_6c', 'EFF_SecondaryLinkPath')
    t = rep(t, '    int i;\n    unsigned int m;\n', f['seclink'], 1)
    out += t + '\n'
    return out


def main():
    for form, f in FORMS.items():
        body = header(form, f)
        body += egenv(f)
        body += tone(f)
        body += route(f)
        body += DEBUG % f['dbg']
        body += RING % dict(name='RingBuf_ReadByte', st='ring4k', mask='0xfff', read=f['ring'])
        body += RING % dict(name='DSP_RingBuf_Read', st='ring2k', mask='0x7ff', read=f['ring'])
        body += RESOLVE % f['resolve']
        body += initslot(f)
        body += flush(f)
        body += algobuf(f)
        body += eff(f)
        path = os.path.join(FW, 'sub_T_18%s.c' % form)
        with open(path, 'w', encoding='latin-1') as fh:
            fh.write(body.rstrip('\n') + '\n')
        print(path, body.count('\n'))


if __name__ == '__main__':
    main()
