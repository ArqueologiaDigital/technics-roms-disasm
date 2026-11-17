/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18b.c (2026-11-17-7-sub-r18)
   sha256 2b9b067aa3f5d6c5692fafb23e49ef5089f738ea67d405a1f19b2166fe4e7881 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_413c9[];
extern unsigned char DSP_AlgoChannel_SelectorByte5[][6];
extern unsigned char DSP_ChanFreq_CurvePool[];
#define PATCH(p) (*(unsigned char **)&ram_4136e[(p) * 0x11f])
void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned int r;
    unsigned char sel;
    unsigned char t;

    t = PATCH(part)[93] & 0xf;
    switch (t) {
    case 6:
    case 7:
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = PATCH(part)[95];
        r += r;
        r = *(unsigned int *)((DSP_ChanFreq_CurvePool + (int)sel * 0x66) + (int)r);
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c9 + part * 0x11f) = r;
}
