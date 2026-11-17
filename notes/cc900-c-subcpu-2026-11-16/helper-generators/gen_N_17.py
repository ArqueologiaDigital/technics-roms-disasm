#!/usr/bin/env python3
"""Write lane_sub helper N's round-17 files sub_N_17a.c, sub_N_17b.c, sub_N_17c.c (KN5000 sub-CPU payload v1.42).

QUESTION ANSWERED: which C spelling makes V4.23 (-Xr) give the ROM's code at the first difference of the functions
still open after round 16 and of pool D's near misses.  Each function's text is taken from its best earlier file
of the corpus and changed only where the form says (every replacement is asserted to have happened).

    python3 -B gen_N_17.py /home/fsanches/compartilhado/disasm-lanes/csub
"""
import os
import re
import sys

ROOT = sys.argv[1]
FW = os.path.join(ROOT, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')


def get(stem, name):
    """The definition of function `name` in corpus file `stem`.c (signature line(s) up to the closing brace)."""
    t = open(os.path.join(FW, stem + '.c'), encoding='latin-1').read()
    m = re.search(r'^[A-Za-z_][^\n;{]*\b' + re.escape(name) + r'\([^;{]*\)\n\{\n.*?^\}\n', t, re.S | re.M)
    assert m, (stem, name)
    return m.group(0)


def rep(t, old, new, count=None):
    n = t.count(old)
    assert n and (count is None or n == count), (old, n)
    return t.replace(old, new)


SLOTI = '((struct slot *)(p + ((unsigned long)i * 56 + 8)))'
SLOTS = '((struct slot *)(p + ((unsigned long)slot * 56 + 8)))'

# ---------------------------------------------------------------- per-form choices
FORMS = {
    'a': dict(
        search='extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out);',
        lastparm='unsigned int len', lenarg='len',
        algo_decl='    int k;\n    unsigned char *p;\n\n    p = tbl;\n    k = 0x78;\n',
        modebits='extern int EGEnv_ModeBits_Table[];',
        eg_a=('', '    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];\n'),
        eg_b=('', '    return EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;\n'),
        tone='    unsigned int o = idx;\n    ram_44fce[(int)o + 472] = v;\n',
        route_reloc=('', '    tbl = (unsigned char *)(long)(ToneDB_RelBase + (unsigned long)tbl);\n'),
        route_13='    ram_45210[n + 6] = ((struct r16 *)tbl)[d].b[13];\n',
        hexproto='extern void BootROM_HEX_BYTE_TO_ASCII(unsigned char);',
        dbg=('w >> 8', 'w'),
        ring_a=('    unsigned int u;\n', '        u = *(unsigned char *)(((unsigned long)i + 6) + (unsigned long)r);\n        c = u;\n'),
        ring_b=('    unsigned char b;\n', '        b = *(unsigned char *)(((unsigned long)i + 6) + (unsigned long)r);\n        c = b;\n'),
        resolve=('', '    tbl += n;\n    return base + *tbl;\n'),
        count='    for (s = 0; n != 0; n--)\n        s += *p++;\n',
        tg='    {\n        int t;\n\n        t = ToneGen_Semitone_Pitch_Table[note % 12];\n        ram_3b1e = t;\n    }\n',
        volupd='switch',
        e50='struct e50 { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; char pad[10]; };',
        macros=('#define JT unsigned int\n#define N17 17\n#define N1 1\n'
                '#define FLG(i, j) ram_4940[i].flags[j]\n#define FLA(i, j) ram_4940[i].a[j]\n'
                '#define FLQ(i, j) ram_4940[i].q[j]\n#define FLGI(i, x) ram_4940[i].flags[x]\n'
                '#define FLGQ(i, c) ram_4940[i].flags[c]\n'
                '#define KT unsigned int\n#define KSET(k) EFF_SlotActiveFlags.active[(k) + 10] = 1\n'),
        seclink='    unsigned int m;\n    int i;\n',
        why=('DSP_AlgoDescriptor_Emit / DSP_OscAlgoSelect: sub_L_16d with the last parameter an unsigned int (no conversion at\n'
             '     the call, so its load comes after the push as in DSP_TuneOffset) and the sum written (*p & 0xff) + sub * 3.\n'
             '   EGEnv_Compute_A / _B: the mode-bits table an int array; A `(unsigned int)x | T[..]`, B `T[..] | (unsigned int)x`.\n'
             '   VoiceParam_Set_Tone_Option: `unsigned int o = idx;` indexed with `(int)o + 472` (idiom (i)).\n'
             '   DSP_VoiceCoeffRoute2: sub_K_16c with `s = sel; s &= 15;`, the table relocation through `(long)`, entry 13 as\n'
             '     a member of a 16-byte struct, the low / high byte as (unsigned char)(d & 0xff) / (unsigned char)(d >> 8).\n'
             '   Debug_Print_Word: the boot ROM routine prototyped with an unsigned char parameter, no casts.\n'
             '   RingBuf_ReadByte: the byte through an unsigned int local; DSP_RingBuf_Read: through an unsigned char local;\n'
             '     both with the index as the left operand of the address sum.\n'
             '   DSP1_ResolveStreamPtr: `tbl += n; return base + *tbl;`.\n'
             '   DSP_WriteCount_Compute: `for (s = 0; n != 0; n--) s += *p++;`.\n'
             '   ToneGen_SetupPolyVoice: the pitch word through an int temporary (idiom (f)).\n'
             '   EFF_VolumeUpdate_WithDebug: the on-flag test a switch with default first.\n'
             '   EFF_* flag arrays: members of the 50-byte record array at 0x4940 (ram_4940[i].flags[j] ...), unsigned\n'
             '     indices; InitFlags\' k an index of the word array, EFF_SlotActiveFlags.active[k + 10].\n'
             '   EFF_SecondaryLinkPath: sub_D_6c with m declared before i.'),
    ),
    'b': dict(
        search='extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);',
        lastparm='unsigned int len', lenarg='len',
        algo_decl='    unsigned char *p = tbl;\n    unsigned int k = 0x78;\n\n',
        modebits='extern unsigned int EGEnv_ModeBits_Table[];',
        eg_a=('', '    return (unsigned int)x | (unsigned int)(int)EGEnv_ModeBits_Table[p[0] & 3];\n'),
        eg_b=('    register unsigned int m;\n', '    m = EGEnv_ModeBits_Table[p[0] & 3];\n    return (unsigned int)x | m;\n'),
        tone='    int o = idx;\n    ram_44fce[(unsigned int)o + 472] = v;\n',
        route_reloc=('    unsigned long t;\n', '    t = ToneDB_RelBase + (unsigned long)tbl;\n    tbl = (unsigned char *)t;\n'),
        route_13='    ram_45210[n + 6] = (&tbl[(unsigned long)d * 16])[13];\n',
        hexproto='extern void BootROM_HEX_BYTE_TO_ASCII();',
        dbg=('(unsigned char)(w >> 8)', '(unsigned char)w'),
        ring_a=('', '        c = (int)(unsigned int)*(unsigned char *)(((unsigned long)i + 6) + (unsigned long)r);\n'),
        ring_b=('    unsigned char b;\n', '        b = r->buf[i];\n        c = b;\n'),
        resolve=('    unsigned long v;\n    unsigned char *q;\n',
                 '    tbl += n;\n    v = *tbl;\n    q = base;\n    base += v;\n    return base;\n'),
        count='    s = 0;\n    while (n != 0) {\n        s += *p++;\n        n--;\n    }\n',
        tg='    {\n        unsigned int t;\n\n        t = ToneGen_Semitone_Pitch_Table[note % 12];\n        ram_3b1e = t;\n    }\n',
        volupd='cast',
        e50='struct e50 { unsigned int f0; char pad[48]; };',
        macros=('#define JT int\n#define N17 17u\n#define N1 1u\n'
                '#define FLG(i, j) ram_4944[i][j]\n#define FLA(i, j) ram_4942[i][j]\n'
                '#define FLQ(i, j) ram_4966[i][j]\n'
                '#define FLGI(i, x) (*(unsigned int *)&((unsigned char (*)[50])ram_4944)[i][(x) * 2])\n'
                '#define FLGQ(i, c) (*((c) + ram_4944[i]))\n'
                '#define KT int\n#define KSET(k) EFF_SlotActiveFlags.active[(k) + 10] = 1\n'),
        seclink='    register unsigned int m;\n    int i;\n',
        why=('DSP_AlgoDescriptor_Emit / DSP_OscAlgoSelect: sub_L_16a (p and k initialised, k unsigned, void * prototype) with\n'
             '     the last parameter an unsigned int and the sum written (*p & 0xff) + sub * 3.\n'
             '   EGEnv_Compute_A: `(unsigned int)x | (unsigned int)(int)T[..]`; _B: the table word in a register local.\n'
             '   VoiceParam_Set_Tone_Option: `int o = idx;` indexed with `(unsigned int)o + 472`.\n'
             '   DSP_VoiceCoeffRoute2: form a with the relocation through an unsigned long local and entry 13 as\n'
             '     (&tbl[d * 16])[13].\n'
             '   Debug_Print_Word: the boot ROM routine without a prototype, the bytes cast to unsigned char.\n'
             '   RingBuf_ReadByte: `(int)(unsigned int)` on the byte; DSP_RingBuf_Read: the struct\'s buf member through an\n'
             '     unsigned char local.\n'
             '   DSP1_ResolveStreamPtr: `v = *tbl; q = base; base += v; return base;` (the ROM copies base to XBC, unused).\n'
             '   DSP_WriteCount_Compute: a while loop with n-- at its end.\n'
             '   ToneGen_SetupPolyVoice: the pitch word through an unsigned int temporary.\n'
             '   EFF_VolumeUpdate_WithDebug: the on flag cast to unsigned int in the test.\n'
             '   EFF_* flag arrays: round 8\'s word arrays with int column indices (bounds 17u / 1u); the idx column through a\n'
             '     byte view of the rows, [i][idx * 2]; the order-table column as *(*q + row).\n'
             '   EFF_SecondaryLinkPath: m a register local declared before i.'),
    ),
    'c': dict(
        search='extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, int len, int *out);',
        lastparm='int unused', lenarg='unused',
        algo_decl='    int k;\n    unsigned char *p;\n\n    p = tbl;\n    k = 0x78;\n',
        modebits='extern unsigned int EGEnv_ModeBits_Table[];',
        eg_a=('', '    return (int)x | EGEnv_ModeBits_Table[p[0] & 3];\n'),
        eg_b=('    unsigned int m;\n', '    m = EGEnv_ModeBits_Table[p[0] & 3];\n    return (unsigned int)x | m;\n'),
        tone='    ram_44fce[(int)(unsigned int)idx + 472] = v;\n',
        route_reloc=('', '    tbl = *(unsigned char **)&ToneDB_RelBase + (unsigned long)tbl;\n'),
        route_13='    ram_45210[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];\n',
        hexproto='extern void BootROM_HEX_BYTE_TO_ASCII(unsigned int);',
        dbg=('(unsigned char)(w >> 8)', '(unsigned char)w'),
        ring_a=('    unsigned char b;\n', '        b = *((unsigned char *)r + ((unsigned long)i + 6));\n        c = b;\n'),
        ring_b=('', '        c = *(unsigned char *)(((unsigned long)i + 6) + (unsigned long)r);\n'),
        resolve=('', '    tbl += n;\n    return (unsigned char *)((unsigned long)base + *tbl);\n'),
        count='    s = 0;\n    if (n != 0) {\n        do {\n            s += *p++;\n        } while (--n != 0);\n    }\n',
        tg='    ram_3b1e = (unsigned int)(long)ToneGen_Semitone_Pitch_Table[note % 12];\n',
        volupd='not',
        e50='struct e50 { unsigned int f0; char pad[48]; };',
        macros=('#define JT unsigned int\n#define N17 17\n#define N1 1\n'
                '#define FLG(i, j) (*(ram_4944[i] + (j)))\n#define FLA(i, j) (*(ram_4942[i] + (j)))\n'
                '#define FLQ(i, j) (*(ram_4966[i] + (j)))\n'
                '#define FLGI(i, x) (*(unsigned int *)&((unsigned char (*)[50])ram_4944)[i][(x) << 1])\n'
                '#define FLGQ(i, c) ram_4944[i][(int)(c)]\n'
                '#define KT unsigned int\n'
                '#define KSET(k) *(unsigned int *)((unsigned long)&EFF_SlotActiveFlags + ((k) * 2 + 0x14)) = 1\n'),
        seclink='    unsigned int m;\n    int i;\n',
        why=('DSP_AlgoDescriptor_Emit / DSP_OscAlgoSelect: sub_L_16d with the callee\'s length parameter prototyped int (the\n'
             '     int last parameter passed without a conversion) and the sum written (*p & 0xff) + sub * 3.\n'
             '   EGEnv_Compute_A: `(int)x | T[..]`; _B: the table word in a local declared first.\n'
             '   VoiceParam_Set_Tone_Option: no local, `(int)(unsigned int)idx + 472`.\n'
             '   DSP_VoiceCoeffRoute2: form a with the relocation as pointer + offset and entry 13 as a struct member of\n'
             '     (tbl + d * 16).\n'
             '   Debug_Print_Word: the boot ROM routine prototyped unsigned int, the bytes cast to unsigned char.\n'
             '   RingBuf_ReadByte: round 4\'s operand order with an unsigned char local; DSP_RingBuf_Read: only the operand\n'
             '     order swapped (index + 6 first).\n'
             '   DSP1_ResolveStreamPtr: the result as (unsigned char *)((unsigned long)base + *tbl).\n'
             '   DSP_WriteCount_Compute: a guarded do / while (--n != 0).\n'
             '   ToneGen_SetupPolyVoice: the pitch word converted through long.\n'
             '   EFF_VolumeUpdate_WithDebug: the test written !(on == 0).\n'
             '   EFF_* flag arrays: round 8\'s word arrays as *(row + j); the idx column through a byte view, [i][idx << 1];\n'
             '     the order-table column cast to int; InitFlags\' k as in round 8.\n'
             '   EFF_SecondaryLinkPath: as form a.'),
    ),
}

HEAD = """/* lane_sub helper N, round 17, form %(form)s (KN5000 sub-CPU payload v1.42); written by gen_N_17.py (lane_sub's
   scratch N/).  The four functions open after round 16, DSP_OscAlgoSelect (the twin of DSP_AlgoDescriptor_Emit)
   and pool D's near misses, each its best earlier file changed only where said (DSP_FlushAllSlots and
   DSP_WriteCount_Compute are new: FlushAllSlots as a 295-byte image struct at offset 0x4980 of the buffer in
   forms a / c, as byte-pointer arithmetic in form b):
   %(why)s */

/* cc900-module: EnvDepth_Cap */
/* cc900-module: VoiceAlloc_Apply_Algo_Group0 */
/* cc900-module: DSP_VelocityToVolume */
/* cc900-module: DSP_GetEffectRouting */
/* cc900-module: Unsigned_Max_Select */
/* cc900-module: DSP_InitChannelSlot */
/* cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE */

#define PART(p) ((unsigned char *)(unsigned long)(ram_41368 + (p) * 0x11f))
#define ROUTE(p, s) (*(unsigned char **)((unsigned long)&PART(p)[(int)(s) * 37 + 110] + 4))
%(macros)s
struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
%(e50)s
struct sv56 { char pad[8]; int on; char pad2[46]; };
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
struct tgparams { int w[0x22]; };
struct r16 { unsigned char b[16]; };
struct e2 { unsigned char b0, b1; };
struct img295 { unsigned char hdr[16]; unsigned char x[23]; struct e2 slots[128]; };
struct g7800 { unsigned char pad[0x4980]; struct img295 img; };
#define G7800 ((struct g7800 *)ram_4531c)

extern unsigned int __near ram_45d4[][28];
extern int __near ram_45d6[][28];
extern int __near ram_45fa[][28];
extern struct sv56 __near ram_4600[];
extern struct fxflags __near EFF_SlotActiveFlags;
extern struct e50 __near ram_4940[];
extern unsigned int __near ram_4942[][25];
extern unsigned int __near ram_4944[][25];
extern unsigned int __near ram_4966[][25];
extern unsigned int __near DSP_AlgoChangedFlag;
extern unsigned int __near ram_3b1c;
extern unsigned int __near ram_3b1e;
extern unsigned int __near ram_3b20;
extern unsigned int __near ram_3b22;
extern unsigned int __near ram_3b2a;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_44fce[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned char *ram_4531c;
extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_BaseCurve_B[];
%(modebits)s

extern char Str_EffVolume_Prefix[], Str_EffVolume_Suffix[];
extern unsigned char EFF_VolumeReduction_Steps[];
extern unsigned char EFF_ParamIter_OrderTable[];
extern unsigned char EFF_SlotSettleTime_Table[];
extern unsigned char Audio_DSP_StateTable_Packed[];
extern unsigned char ToneGen_VoiceType_Default_Level[];
extern int ToneGen_Semitone_Pitch_Table[];

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
%(search)s
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
%(hexproto)s
extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void DSP_WriteParameter(unsigned int, unsigned int, unsigned int, unsigned long);
extern void EFF_ParamEdit_WithDebug(unsigned int, unsigned int, unsigned int, unsigned long);
extern void EFF_Disconnect(unsigned int, unsigned int);
extern void DSP_ScheduleDelay(int);
extern unsigned int Unsigned_Max_Select(unsigned int, unsigned int);
extern unsigned int DSP_GetEffectRouting(void);
extern unsigned int DSP_VelocityToVolume(unsigned int);
extern void ToneGen_WriteVoiceParams(int, unsigned int *);
extern void ToneGen_WriteSingleReg(int, unsigned int);
extern void Voice_ActiveFlag_CheckAndLoad();
extern void Voice_Part_ResetSlotRouting();
extern void DSP_SlotParam_Write_Slot0();
extern void DSP_SlotParam_Write_Slot1();
extern void DSP_SlotParam_Write_Slot2();
extern void DSP_SlotParam_Write_Slot3();
extern void DSP_SlotParam_Write_Slot4();
extern void VoiceAlloc_Apply_Algo_Group0();
extern unsigned char *Voice_AllocateForSustain();
extern void Voice_AllNotes_SustainRetrigger(unsigned char *v, unsigned int n);
extern unsigned char ram_7800[];
extern unsigned char DSP1_ImageHeader_UserKit[];
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern void DSP_InitChannelSlot();
extern void InterCPU_E1_DMA_Transfer(unsigned char *p, unsigned int n, unsigned long dst);
void Debug_Print_Word(unsigned int w);
void EFF_VolumeUpdate_WithDebug(unsigned int slot, unsigned int b, unsigned int idx, unsigned long p);

"""

RING = """int %(name)s(struct %(st)s *r)
{
    unsigned int i;
    int c;
%(decl)s
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
    unsigned char *base;
    unsigned long *tbl;
%s
    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    tbl = (unsigned long *)(base + *(unsigned long *)(base + 8));
%s}

"""

COUNT = """unsigned int DSP_WriteCount_Compute(void)
{
    unsigned int n;
    unsigned int *p;
    unsigned int s;

    n = 0x4970;
    n >>= 1;
    p = (unsigned int *)(ram_4531c + 16);
%s    return ~s;
}

"""

DEBUG = """void Debug_Print_Word(unsigned int w)
{
    BootROM_HEX_BYTE_TO_ASCII(%s);
    __WA = 0;
    BootROM_HEX_BYTE_TO_ASCII(%s);
    __WA = 0;
}

"""


def algo(f, src):
    """DSP_AlgoDescriptor_Emit from sub_L_16d, DSP_OscAlgoSelect's body from sub_E_5a under the same head."""
    emit = get('sub_L_16d', 'DSP_AlgoDescriptor_Emit')
    emit = rep(emit, 'int unused)', f['lastparm'] + ')', 1)
    emit = rep(emit, '    int k;\n    unsigned char *p;\n\n    p = tbl;\n    k = 0x78;\n', f['algo_decl'], 1)
    emit = rep(emit, '    p = DSP_TableWalk_Search(p, k, unused, &st);\n    v = sub * 3 + (*p & 0xff);\n',
               '    p = DSP_TableWalk_Search(p, k, %s, &st);\n    v = (*p & 0xff) + sub * 3;\n' % f['lenarg'], 1)
    osc = get('sub_E_5a', 'DSP_OscAlgoSelect')
    osc = rep(osc, 'int unused)', f['lastparm'] + ')', 1)
    osc = rep(osc, '    int st;\n    unsigned int v;\n\n'
              '    v = sub * 3 + (*DSP_TableWalk_Search(tbl, (unsigned int)0x78, type, &st) & 0xff);\n',
              '    int st;\n    unsigned int v;\n' + f['algo_decl'] +
              '    p = DSP_TableWalk_Search(p, k, %s, &st);\n    v = (*p & 0xff) + sub * 3;\n' % f['lenarg'], 1)
    return emit + '\n' + osc + '\n'


def egenv(f):
    out = ''
    for name, key in (('EGEnv_Compute_A', 'eg_a'), ('EGEnv_Compute_B', 'eg_b')):
        t = get('sub_M_16c', name)
        decl, ret = f[key]
        t = rep(t, '{\n    unsigned int w;\n', '{\n' + decl + '    unsigned int w;\n', 1)
        t = rep(t, '    return EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;\n', ret, 1)
        out += t + '\n'
    return out


def tone(f):
    t = get('sub_K_16a', 'VoiceParam_Set_Tone_Option')
    t = rep(t, '    int t = idx;\n    unsigned int o = t;\n    o += 472;\n    ram_44fce[(int)o] = v;\n', f['tone'], 1)
    return t + '\n'


def route(f):
    t = get('sub_K_16c', 'DSP_VoiceCoeffRoute2')
    decl, reloc = f['route_reloc']
    t = rep(t, '    unsigned int i;\n\n', '    unsigned int i;\n' + decl + '\n', 1)
    t = rep(t, '    s = sel & 15;\n', '    s = sel;\n    s &= 15;\n', 1)
    t = rep(t, '    tbl = (unsigned char *)(ToneDB_RelBase + (unsigned long)tbl);\n', reloc, 1)
    t = rep(t, '    ram_45210[n + 6] = (tbl + (unsigned long)d * 16)[13];\n', f['route_13'], 1)
    t = rep(t, '(int)d & 0xff;', '(unsigned char)(d & 0xff);', 1)
    t = rep(t, '(int)(d >> 8);', '(unsigned char)(d >> 8);', 1)
    return t + '\n'


def eff(f):
    out = ''
    t = get('sub_D_8c', 'EFF_VolumeUpdate_WithDebug')
    on = SLOTS + '->on'
    old = ('        if (' + on + ' != 0)\n            DSP_WriteParameter(slot, b, idx, p);\n        else {\n')
    if f['volupd'] == 'switch':
        new = ('        switch (' + on + ') {\n        default:\n            DSP_WriteParameter(slot, b, idx, p);\n'
               '            break;\n        case 0:\n')
    elif f['volupd'] == 'cast':
        new = old.replace('if (' + on, 'if ((unsigned int)' + on)
    else:
        new = old.replace('if (' + on + ' != 0)', 'if (!(' + on + ' == 0))')
    out += rep(t, old, new, 1) + '\n'

    t = get('sub_D_8c', 'EFF_VolumeLoop')
    t = rep(t, 'ram_4944[i][' + SLOTI + '->idx]', 'FLGI(i, ' + SLOTI + '->idx)', 1)
    out += t + '\n'

    t = get('sub_D_8c', 'EFF_SlotActive_UpdateFlags')
    t = rep(t, 'ram_4944[i][' + SLOTI + '->idx]', 'FLGI(i, ' + SLOTI + '->idx)', 1)
    out += t + '\n'

    t = get('sub_D_8c', 'EFF_ParamIterator_Process')
    t = rep(t, '    unsigned int i;\n', '    JT i;\n', 1)
    t = rep(t, 'ram_4944[slot][i]', 'FLG(slot, i)', 1)
    t = rep(t, 'ram_4944[slot][*q]', 'FLGQ(slot, *q)', 1)
    out += t + '\n'

    t = get('sub_D_8c', 'DSP_EFFParam_DiffAllAndFlag')
    t = rep(t, '    unsigned int j;\n', '    JT j;\n', 1)
    t = rep(t, 'j < 17;', 'j < N17;')
    t = rep(t, 'j < 1;', 'j < N1;')
    t = rep(t, 'ram_4944[i][j]', 'FLG(i, j)')
    t = rep(t, 'ram_4942[i][j]', 'FLA(i, j)')
    t = rep(t, 'ram_4966[i][j]', 'FLQ(i, j)')
    t = rep(t, 'if (*(int *)((unsigned long)&ram_4600 + (i * 56 + 8)) != ' + SLOTI + '->on) {',
            'if (' + SLOTI + '->on != ram_4600[i].on) {', 1)
    out += t + '\n'

    t = get('sub_D_8c', 'EFF_DspChannel_InitFlags')
    t = rep(t, '    unsigned int j;\n', '    JT j;\n', 1)
    t = rep(t, '    unsigned int k;\n', '    KT k;\n', 1)
    t = rep(t, 'j < 17;', 'j < N17;')
    t = rep(t, 'j < 1;', 'j < N1;')
    t = rep(t, 'ram_4944[i][j]', 'FLG(i, j)')
    t = rep(t, 'ram_4942[i][j]', 'FLA(i, j)')
    t = rep(t, 'ram_4966[i][j]', 'FLQ(i, j)')
    t = rep(t, '*(unsigned int *)((unsigned long)&EFF_SlotActiveFlags + (k * 2 + 0x14)) = 1;', 'KSET(k);', 2)
    t = rep(t, 'ram_4944[i][' + SLOTI + '->idx]', 'FLGI(i, ' + SLOTI + '->idx)', 1)
    out += t + '\n'

    t = get('sub_D_6c', 'EFF_SecondaryLinkPath')
    t = rep(t, '    int i;\n    unsigned int m;\n', f['seclink'], 1)
    out += t + '\n'
    return out


FLUSH_HEAD = """void DSP_FlushAllSlots(unsigned char a, unsigned char b)
{
    %(rect)s *rec;
    unsigned int i;

    rec = (%(rect)s *)ToneDB_Find_ToneRecord(a, b);
"""

FLUSH_TAIL = """    InterCPU_E1_DMA_Transfer(ram_7800, 0x72aa, 0x1e0000L);
}

"""

FLUSH = {
    # the 295-byte image as a member of a struct the buffer pointer points to
    'a': ('struct img295',
          '    G7800->img = *rec;\n'
          '    for (i = 0; i < 0x80; i++) {\n        G7800->img.slots[i].b1 &= ~0x20;\n'
          '        G7800->img.slots[i].b1 |= 0x20;\n    }\n'
          '    for (i = 0; i < 0x80; i++)\n        DSP_InitChannelSlot(rec, i);\n'
          '    for (i = 0; i < 0x10; i++)\n        G7800->img.hdr[i] = DSP1_ImageHeader_UserKit[i];\n'),
    # byte-pointer arithmetic, the index as the left operand
    'b': ('struct img295',
          '    *(struct img295 *)(ram_4531c + 0x4980) = *rec;\n'
          '    for (i = 0; i < 0x80; i++) {\n'
          '        ((struct e2 *)(((unsigned long)i + (unsigned long)i + 0x49a7) + (unsigned long)ram_4531c))->b1 &= ~0x20;\n'
          '        ((struct e2 *)(((unsigned long)i + (unsigned long)i + 0x49a7) + (unsigned long)ram_4531c))->b1 |= 0x20;\n'
          '    }\n'
          '    for (i = 0; i < 0x80; i++)\n        DSP_InitChannelSlot(rec, i);\n'
          '    for (i = 0; i < 0x10; i++)\n'
          '        *(unsigned char *)(((unsigned long)i + 0x4980) + (unsigned long)ram_4531c) = DSP1_ImageHeader_UserKit[i];\n'),
    # form a with the record pointer a byte pointer
    'c': ('unsigned char',
          '    G7800->img = *(struct img295 *)rec;\n'
          '    for (i = 0; i < 0x80; i++) {\n        G7800->img.slots[i].b1 &= ~0x20;\n'
          '        G7800->img.slots[i].b1 |= 0x20;\n    }\n'
          '    for (i = 0; i < 0x80; i++)\n        DSP_InitChannelSlot(rec, i);\n'
          '    for (i = 0; i < 0x10; i++)\n        G7800->img.hdr[i] = DSP1_ImageHeader_UserKit[i];\n'),
}


def flush(form):
    rect, body = FLUSH[form]
    return FLUSH_HEAD % dict(rect=rect) + body + FLUSH_TAIL


def tonegen(f):
    t = get('sub_D_9c', 'ToneGen_SetupPolyVoice')
    t = rep(t, '    ram_3b1e = ToneGen_Semitone_Pitch_Table[note % 12];\n', f['tg'], 1)
    return t + '\n'


def main():
    for form, f in FORMS.items():
        d = dict(f)
        d['form'] = form
        body = HEAD % d
        body += algo(f, None)
        body += egenv(f)
        body += tone(f)
        body += route(f)
        body += DEBUG % f['dbg']
        da, ra = f['ring_a']
        db, rb = f['ring_b']
        body += RING % dict(name='RingBuf_ReadByte', st='ring4k', mask='0xfff', decl=da, read=ra)
        body += RING % dict(name='DSP_RingBuf_Read', st='ring2k', mask='0x7ff', decl=db, read=rb)
        body += RESOLVE % f['resolve']
        body += COUNT % f['count']
        body += tonegen(f)
        body += flush(form)
        body += eff(f)
        path = os.path.join(FW, 'sub_N_17%s.c' % form)
        with open(path, 'w', encoding='latin-1') as fh:
            fh.write(body.rstrip('\n') + '\n')
        print(path, body.count('\n'))


if __name__ == '__main__':
    main()
