/* lane_sub helper M, round 16, form c (KN5000 sub-CPU payload v1.42): the five near misses of round 15 plus
   Voice_InitVoiceState, each its best earlier file changed only at the first difference.
   - EGEnv_Compute_A / _B (sub_G_15c, +129): the ROM loads the mode-bits word into WA first, then narrows x through
     BC into HL and ORs WA in.  Form c: no temporary, the table word as the LEFT operand, `T[..] | (unsigned int)x`.
   - Voice_PortamentoTarget_ComputePitch (sub_J_15c, +99): the ROM computes the slot record straight into XBC and
     stores through (XBC+8); the struct-pointer cast cost a copy through XWA.  Form c: s is a byte pointer, the store `((unsigned long *)s)[2]`.
   - CustomTone_CopyToneRecord (sub_H_15b, +37: only the offset, 19112 for 19111, because the struct member array
     was aligned): the record address from a byte pointer.  Form c: `(unsigned char *)(unsigned long)(ram_4531c + (e * 80 + 19111))` (conversion through a long).
   - Voice_Build_OutputLevel (sub_H_15c, +36) and Voice_InitVoiceState (sub_B_9b, +167): the ROM doubles the table
     word with `add r,r`; `* 2` and `<< 1` give shifts.  Form c: `w = w + w; b = w;` (an int local, `ram_451d0 = t + t`).

   cc900-module: EnvDepth_Cap BlockCopy_Words_BC_to_HL Voice_Clamp_Byte_WA */

/* cc900-module: EnvDepth_Cap */
/* cc900-module: BlockCopy_Words_BC_to_HL */
/* cc900-module: Voice_Clamp_Byte_WA */

#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

struct pslot3 { unsigned char *src; unsigned char *tone; unsigned long pitch; };
struct crec { unsigned char b[80]; };

extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned long ram_45310;                 /* ToneDB_RelBase */
extern unsigned char *ram_45314;                /* ToneDB_RootPtr */
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned int ram_451d0;
extern unsigned char Voice_OutputLevel_Table[];
extern unsigned int Voice_Reg080_NoteField_Table[];
extern int ram_41360;
extern int ram_41362;
extern int ram_41364;
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451ce;
extern unsigned int ram_451d2;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451d8;
extern unsigned int ram_451da;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_451e0;
extern unsigned int ram_451e2;
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451ea;
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;

unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
int Voice_Clamp_Byte_WA(int a);

unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = ram_4424e + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_A[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;
}

unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = ram_44257 + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_B[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;
}

void Voice_PortamentoTarget_ComputePitch(unsigned char part, unsigned char slot)
{
    unsigned int k;
    unsigned long l;
    unsigned char *s;
    unsigned int w;
    k = ((*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e])[3]
         & 0x30) >> 4;
    l = *(unsigned long *)(ram_45314 + 112);
    w = *(unsigned int *)(ram_45314 + 236);
    s = &((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e];
    ((unsigned long *)s)[2] = (unsigned long)w * k + l + ram_45310;
}

void CustomTone_CopyToneRecord(unsigned char a, unsigned char b, unsigned char e)
{
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255), (unsigned char *)(unsigned long)(ram_4531c + ((int)e * 80 + 19111)),
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}

void Voice_Build_OutputLevel(unsigned char *v, int b)
{
    unsigned int w;
    b += SW(P(v, 35), 12);
    b += SW(P(v, 35), 16);
    b += SW(v, 51);
    b = Voice_Clamp_Byte_WA(b);
    w = W(Voice_OutputLevel_Table, b * 2);
    w = w + w;
    b = w;
    if (P(v, 15)[2] & 0x80) w = ((unsigned int)P(v, 15)[2] & 0x70) << 8;
    else w = Voice_Reg080_NoteField_Table[W(v, 6) >> 8];
    b |= w;
    b |= 0x8000;
    ram_451d0 = b;
}

void Voice_InitVoiceState(unsigned char slot)
{
    int t;
    ram_451ce = 0;
    ram_451da = ram_41360;
    ram_451ec = 0;
    ram_451ee = 0;
    ram_451f0 = 0;
    ram_451d4 = 0x17f;
    ram_451d6 = 0x7f7f;
    ram_451f2 = 0;
    ram_451f4 = 0;
    ram_451f6 = 0;
    ram_451e2 = 0;
    ram_451ea = 0;
    ram_451dc = 0;
    ram_451de = 0;
    ram_451d8 = 0x40;
    ram_451e0 = 0;
    ram_451d2 = 0;
    ram_451e4 = 0xff7f;
    ram_451e6 = ram_41362;
    ram_451e8 = ram_41362;
    t = *(int *)&Voice_OutputLevel_Table[(int)((unsigned int)ram_41364 << 1)];
    ram_451d0 = t + t;
    *(unsigned int *)&ram_4308e[slot][0x2d] = 0xf000;
}
