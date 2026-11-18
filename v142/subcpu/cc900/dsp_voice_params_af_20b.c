/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoChannel_SelectorRecords[];
extern unsigned char DSP_ChanFreq_Dispatch1_Curves[];
extern unsigned char DSP_ChanFreq_CurvePool[];
extern int EGEnv_ModeBits_Table[];
struct sel2 { unsigned char a; unsigned char b; };
struct algorec { unsigned char b[40]; };
struct b3 { unsigned char f0; unsigned char f1; unsigned char f2; };
struct coef { unsigned int c1; unsigned int c2; };
struct prb { unsigned char b[0x60]; };
unsigned int DSP_AlgoType_Dispatch1(unsigned char part, unsigned char ch);
unsigned int DSP_AlgoType_Dispatch2(unsigned char part, unsigned char ch);
unsigned int DSP_AlgoType_Dispatch1(unsigned char part, unsigned char ch);
unsigned int DSP_AlgoType_Dispatch2(unsigned char part, unsigned char ch);

/* cc900-data: DSP_AlgoType_Dispatch1 1 = DSP_AlgoType_Dispatch1_CaseOffsets */
/* cc900-data: DSP_AlgoType_Dispatch2 1 = DSP_AlgoType_Dispatch2_CaseOffsets */
unsigned int DSP_AlgoType_Dispatch1(unsigned char part, unsigned char ch)
{
    unsigned int r;
    unsigned char t;
    unsigned char s;
    r = 0;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].a;
        r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]];
        break;
    case 4: case 5: case 7:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].a;
        if (ch == 0)
            r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]];
        else if (ch == 1)
            r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[96]];
        break;
    case 10: case 11:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].a;
        if (s != 0xff)
            r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[96]];
        r |= EGEnv_ModeBits_Table[(((struct b3 *)((unsigned long)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)t * 39))->b[(int)ch * 3]))->f2 & 0xc0) >> 6];
        break;
    }
    ((struct coef *)((unsigned long)&((struct prb *)(ram_41368 + (int)part * 0x11f))->b[(int)ch * 4 + 0x57]))->c1 = r;
    return r;
}

unsigned int DSP_AlgoType_Dispatch2(unsigned char part, unsigned char ch)
{
    unsigned int r;
    unsigned char t;
    unsigned char s;
    r = 0;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].b;
        r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[95]];
        break;
    case 4: case 5: case 7:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].b;
        if (ch == 0)
            r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[95]];
        else if (ch == 1)
            r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[97]];
        break;
    case 10: case 11:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].b;
        if (s != 0xff)
            r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[((struct b3 *)((unsigned long)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)t * 39))->b[(int)ch * 3]))->f1];
        break;
    }
    ((struct coef *)((unsigned long)&((struct prb *)(ram_41368 + (int)part * 0x11f))->b[(int)ch * 4 + 0x57]))->c2 = r;
    return r;
}
