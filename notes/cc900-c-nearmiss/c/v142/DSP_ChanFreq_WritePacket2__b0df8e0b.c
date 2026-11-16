/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_4b.c (2026-11-16-62-sub-r4)
   sha256 b0df8e0b49e3477310bfbc8eb1db4d0a27fc8cbcb08ab817f13c8569d38158d2 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_413c9[];
extern unsigned char DSP_AlgoChannel_SelectorByte5[][6];
extern unsigned char DSP_ChanFreq_CurvePool[];
void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned char t;
    unsigned int r;
    unsigned char sel;
    t = (*(unsigned char **)(ram_4136e + part * 0x11f))[93] & 0xf;
    switch (t) {
    case 6:
    case 7:
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_CurvePool + (int)sel * 0x66))[(*(unsigned char **)(ram_4136e + part * 0x11f))[95]];
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c9 + part * 0x11f) = r;
}
