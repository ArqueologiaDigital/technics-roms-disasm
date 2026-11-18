/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/dsp_voice_params_af_20b.c (2026-11-18-9-sub-r20c-staged)
   sha256 9da57e32329b86917fa651919f9655c0b61d4e29548057bf9a35fcd377c8087d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4131c[];
extern unsigned char ram_41322[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoChannel_SelectorRecords[];
extern unsigned char DSP_ChanFreq_CurvePool[];
struct sel2 { unsigned char a; unsigned char b; };
struct algorec { unsigned char b[40]; };
struct b3 { unsigned char f0; unsigned char f1; unsigned char f2; };
struct coef { unsigned int c1; unsigned int c2; };
struct prb { unsigned char b[0x60]; };
unsigned int DSP_AlgoType_Dispatch2(unsigned char part, unsigned char ch)
{
    unsigned int r;
    unsigned char t;
    unsigned char s;
    r = 0;
    t = (*(unsigned char **)&ram_41322[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].b;
        r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[(*(unsigned char **)&ram_41322[(part) * 0x11f])[95]];
        break;
    case 4: case 5: case 7:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].b;
        if (ch == 0)
            r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[(*(unsigned char **)&ram_41322[(part) * 0x11f])[95]];
        else if (ch == 1)
            r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[(*(unsigned char **)&ram_41322[(part) * 0x11f])[97]];
        break;
    case 10: case 11:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].b;
        if (s != 0xff)
            r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)s * 102))[((struct b3 *)((unsigned long)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)t * 39))->b[(int)ch * 3]))->f1];
        break;
    }
    ((struct coef *)((unsigned long)&((struct prb *)(ram_4131c + (int)part * 0x11f))->b[(int)ch * 4 + 0x57]))->c2 = r;
    return r;
}
