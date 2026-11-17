/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_10b.c (2026-11-16-90-sub-r10)
   sha256 bc5b281dceb985f114d364502d6740cad1d24883855d2a547d3ff9990aa72ca9 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41399[];
extern unsigned char DSP_AlgoChannel_SelectorByte5[];
extern unsigned char DSP_ChanFreq_CurvePool[];
void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned char t;
    unsigned char s;
    int r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        s = DSP_AlgoChannel_SelectorByte5[(int)t * 6];
        r = ((int *)(DSP_ChanFreq_CurvePool + (int)s * 0x66))[(*(unsigned char **)&ram_4136e[part * 0x11f])[95]];
        break;
    default:
        r = 0;
        break;
    }
    *(int *)&ram_41399[part * 0x11f] = r;
}
