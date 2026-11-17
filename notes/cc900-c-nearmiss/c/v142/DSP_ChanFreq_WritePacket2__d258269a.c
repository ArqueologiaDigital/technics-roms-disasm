/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_11c.c (2026-11-16-94-sub-r11)
   sha256 d258269aa950011b51ef3adeeec84d2896b595c4ed0a11aa7290611a3714545f (name+funcs); compiled at -Xr */
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
        r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 0x66)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[95]];
        break;
    default:
        r = 0;
        break;
    }
    *(int *)&ram_41399[part * 0x11f] = r;
}
