/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AR_40b.c (2026-11-19-90-sub-r40r)
   sha256 f43cf96ed8642db57e76409117a0b5cd845442a2e528062b3f38c9864ad994d2 (name+funcs); compiled at -Xr */
/* lane_sub helper AR, round 40, form b (KN5000 sub-CPU payload v1.42).  FORM B differs from form a only in:
   - DiffAllAndFlag: the index as a comma expression, `WT(int, ram_4600, (0, i * 56 + 8))`.
   - TVF_Lookup_Depth_Amount: only n at function scope; hi and lo both in the inner block.
   - DSP1_ResolveStreamPtr: `v = *((unsigned long *)(base + off) + n);`.
   - Debug_Print_Word: an unsigned int local, `lo = (unsigned char)w;` (byte into an int variable in WA).
   - Keybed_Read_Event: inner block declared d, hi, lo (reverse order).
   - Voice_TickNoteDecay: ram_4135f declared volatile, the decrement as in sub_AG_22c (`x = x - 1`).
   - ToneDB_Find_PatchRecord: the two table sums `(unsigned long)p + b + ToneDB_RelBase` (no pointer + integer
     reassociation).
   Form a's notes follow.  Seven older near misses, each started
   from its best earlier file (idiff_full.py on that listing) and changed only where the difference calls for it.
   ToneDB_Find_SubToneRecord, also on the round-40 list, is not here: it is already built
   (v142/subcpu/cc900/dsp_voice_params_d_10a.c).
   - DSP_EFFParam_DiffAllAndFlag (sub_AE_21c, run 2026-11-18-21: +6, the only difference): the ram_4600 index
     `i * 56 + 8` lost its +8 into the base (lda 0x4608) where the ROM adds it to the index (inc 8,bc; lda 0x4600).
     Form a: a unary plus around the whole index, `WT(int, ram_4600, +(i * 56 + 8))` (round 39's folding lesson).
   - TVF_Lookup_Depth_Amount (sub_AE_21c / sub_U_18c: +5): the ROM has the index n in DE and the low byte lo in IX;
     every declaration order gave n IX, lo DE.  AE_21c's inner-block n kept the outer lo first in DE, so scope seems
     to order the choice.  Form a: n and hi at function scope, lo in an inner block that holds the if and the return.
   - DSP1_ResolveStreamPtr (sub_AE_21c / sub_T_18c: +14): ROM off XBC, tbl XDE, v XWA, the dead copy into XBC; ours
     always had off XDE, tbl XBC.  Form a: no tbl variable, `v = ((unsigned long *)(base + off))[n];` (the sum is a
     temporary, so off is the only scratch variable live there), then AE_21c's `off = (unsigned long)base;`.
   - Debug_Print_Word (sub_N_17c / sub_T_18c: +16..+18): the second byte goes through C (`ld c,izl; extz bc;
     ld wa,bc`) where the ROM loads it straight into A (`ld a,izl; extz wa`).  Form a: an unsigned char local,
     `lo = w; BootROM_HEX_BYTE_TO_ASCII(lo);`, the boot routine prototyped int.
   - Keybed_Read_Event (sub_S_17c: +11): ROM st BC, lo L, hi E; ours st DE, lo C, hi A, in every declaration order.
     Form a: st alone at function scope, lo, hi, d in the `if (st & 1)` block (outer scope chosen first?).
   - Voice_TickNoteDecay (sub_AG_22c, run 2026-11-18-29: +13, the only difference): the ROM compares the counter
     again after the decrement (`dec 1,(0x4135f); cp (0x4135f),0`); `--x == 0` and `x = x - 1` used dec's flags.
     Form a: `ram_4135f--;` as its own statement, then `if (ram_4135f == 0)`.
   - ToneDB_Find_PatchRecord (sub_W_18c: +21): today's lessons: the three `+((unsigned long)a * K + C) + global`
     with ram_4531c / ram_45318 `unsigned long` (add xhl,0x10; add xhl,(mem)); `ToneDB_RootPtr[1] + 0x80` in
     unsigned long (add xhl,0x80, not lda); the RelBase additions with RelBase on the left
     (`(unsigned char *)(ToneDB_RelBase + (unsigned long)p)`: ld xwa,(mem); add xwa,xhl; ld xhl,xwa); the word
     index shifted in 16 bits, `(b << 2) + p + ToneDB_RelBase`.  Form a: the two table sums as `b + p + RelBase`.
   cc900-options: -Xr
*/

/* cc900-module: Keybed_Decode_Event Keybed_Read_Event */
/* cc900-module: Voice_InitVoiceState Voice_TickNoteDecay */

#define WT(type, base, s) (*(type *)&(base)[(unsigned int)(s)])
#define FL(base, i, j) WT(unsigned int, base, (i) * 50 + (j) * 2)
#define FL56(type, base, i, j) WT(type, base, (i) * 56 + (j) * 2)

struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };

#ifdef __GNUC__
extern int __wa;                /* only for syntax_check.sh, which maps the cc900 register variable __WA to __wa */
#endif

extern unsigned char __tiny ram_18;                           /* P6 */
extern unsigned int ram_110000;
extern unsigned int ram_110002;
extern int __near ram_2940;
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
extern unsigned char __near ram_45d4[];
extern unsigned char __near ram_45d6[];
extern unsigned char __near ram_45fa[];
extern unsigned char __near ram_4600[];
extern struct fxflags __near EFF_SlotActiveFlags;
extern unsigned char __near ram_4942[];
extern unsigned char __near ram_4944[];
extern unsigned char __near ram_4966[];
extern unsigned char ram_4135e;
extern volatile unsigned char ram_4135f;
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned long ram_45318;
extern unsigned long ram_4531c;

extern void BootROM_HEX_BYTE_TO_ASCII(int);
extern void Keybed_Decode_Event(unsigned char *ev, char d);
extern void Voice_SetPanning(unsigned char *v);
extern void Voice_InitVoiceState(unsigned char slot);
extern void ToneGen_WriteVoiceParams(int ch, unsigned int *p);
extern void ToneGen_WriteSingleReg(int ch, unsigned int w);

void DSP_EFFParam_DiffAllAndFlag(unsigned long p);
unsigned int TVF_Lookup_Depth_Amount(unsigned char a);
unsigned char *DSP1_ResolveStreamPtr(unsigned int n);
void Debug_Print_Word(unsigned int w);
unsigned int Keybed_Read_Event(unsigned char *ev);
void Voice_TickNoteDecay(void);
unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b);

void DSP_EFFParam_DiffAllAndFlag(unsigned long p)
{
    unsigned int i;
    unsigned int j;

    for (i = 0; i < 5; i++) {
        EFF_SlotActiveFlags.r[i].g[4] = 0;
        for (j = 0; j < 1; j++) {
            if (FL56(unsigned int, ram_45d4, i, j) != ((unsigned int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[5]) {
                FL(ram_4942, i, j) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                FL(ram_4942, i, j) = 0;
        }
        for (j = 0; j < 17; j++) {
            if (FL56(int, ram_45d6, i, j) != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[6]) {
                FL(ram_4944, i, j) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                FL(ram_4944, i, j) = 0;
        }
        for (j = 0; j < 1; j++) {
            if (FL56(int, ram_45fa, i, j) != ((int *)(((unsigned long)i * 56 + (unsigned long)j * 2) + p))[24]) {
                FL(ram_4966, i, j) = 1;
                EFF_SlotActiveFlags.r[i].g[4] = 1;
            } else
                FL(ram_4966, i, j) = 0;
        }
        if (WT(int, ram_4600, (0, i * 56 + 8)) != ((struct slot *)(p + ((unsigned long)i * 56 + 8)))->on) {
            EFF_SlotActiveFlags.r[i].g[3] = 1;
            EFF_SlotActiveFlags.r[i].g[4] = 1;
        } else
            EFF_SlotActiveFlags.r[i].g[3] = 0;
        EFF_SlotActiveFlags.r[i].g[0] = 0;
        EFF_SlotActiveFlags.r[i].g[1] = 0;
        EFF_SlotActiveFlags.r[i].g[2] = 0;
    }
}

unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int n;
    n = a & 0xf;
    {
        unsigned int hi;
        unsigned int lo;
        if (a & 0x80) {
            hi = *(unsigned char *)((unsigned long)&TVF_DepthRecords_B[0][1] + (unsigned long)n * 3);
            hi <<= 8;
            lo = TVF_DepthRecords_B[n][0];
            ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_B[0][2] + (unsigned long)n * 3);
        } else {
            hi = *(unsigned char *)((unsigned long)&TVF_DepthRecords_A[0][1] + (unsigned long)n * 3);
            hi <<= 8;
            lo = TVF_DepthRecords_A[n][0];
            ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_A[0][2] + (unsigned long)n * 3);
        }
        return hi | lo;
    }
}

unsigned char *DSP1_ResolveStreamPtr(unsigned int n)
{
    unsigned char *base;
    unsigned long off;
    unsigned long v;

    base = (unsigned char *)0x50000;
    n += *(unsigned long *)(base + 136);
    off = *(unsigned long *)(base + 8);
    v = *((unsigned long *)(base + off) + n);
    off = (unsigned long)base;
    base += v;
    return base;
}

void Debug_Print_Word(unsigned int w)
{
    unsigned int lo;
    BootROM_HEX_BYTE_TO_ASCII((unsigned char)(w >> 8));
    __WA = 0;
    lo = (unsigned char)w;
    BootROM_HEX_BYTE_TO_ASCII(lo);
    __WA = 0;
}

unsigned int Keybed_Read_Event(unsigned char *ev)
{
    unsigned int st;

    ram_18 |= 0x80;
    __ASM(" nop");
    st = ram_110002;
    if (st & 1) {
        unsigned int d;
        unsigned char hi;
        unsigned char lo;
        ram_18 &= ~0x80;
        __ASM(" nop");
        d = ram_110000;
        lo = d & 0xff;
        hi = (d >> 8) & 0xff;
        if (hi == 0xff || (st & 2)) {
            if (lo & 0x80)
                return 0xffff;
            Keybed_Decode_Event(ev, lo);
            ev[1] = 0;
            return 0;
        } else {
            Keybed_Decode_Event(ev, lo);
            return 0;
        }
    }
    return 0xffff;
}

void Voice_TickNoteDecay(void)
{
    unsigned char i;
    unsigned char buf[14];
    if (ram_4135e != 0) {
        ram_4135f = ram_4135f - 1;
        if (ram_4135f == 0) {
            Voice_SetPanning(buf);
            if (buf[10] < 0x40) {
                Voice_InitVoiceState(i = buf[10]);
                ToneGen_WriteVoiceParams(i, ram_451cc);
                ToneGen_WriteSingleReg(i, *(unsigned int *)(ram_4308e[i] + 45));
            }
            ram_4135e--;
            ram_4135f = 4;
        }
    }
}

unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b)
{
    unsigned char *p;
    unsigned long i;

    if (b <= 7 || b == 0x40 || b == 0x41 || b == 0x70) {
        i = b;
        b = *(unsigned char *)(ToneDB_RootPtr[1] + i + ToneDB_RelBase);
        p = (unsigned char *)(ToneDB_RootPtr[1] + 0x80);
        b = (b << 7) + a;
        b += b;
        b = *(unsigned int *)((unsigned long)p + b + ToneDB_RelBase);
        p = (unsigned char *)ToneDB_RootPtr[2];
        p = *(unsigned char **)((unsigned long)p + (b << 2) + ToneDB_RelBase);
        p = (unsigned char *)(ToneDB_RelBase + (unsigned long)p);
    } else if (b == 0x10)
        p = (unsigned char *)(+((unsigned long)a * 0x1d6 + 0x10) + ram_4531c);
    else if (b == 0x15)
        p = (unsigned char *)(+((unsigned long)a * 0x1d6 + 0x10) + ram_45318);
    else if (b == 0x50)
        p = (unsigned char *)ram_4531c + 0x4980;
    else if (b == 0x55)
        p = (unsigned char *)(+((unsigned long)(a & 3) * 0x2927 + 0x4980) + ram_45318);
    else {
        p = (unsigned char *)ToneDB_RootPtr[2];
        p = *(unsigned char **)(ToneDB_RelBase + (unsigned long)p);
        p = (unsigned char *)(ToneDB_RelBase + (unsigned long)p);
    }
    return p;
}
