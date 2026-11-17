/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3a.c (2026-11-16-58-sub-r3)
   sha256 528c9ccfc8cfe66716d81cade2bea6c2e8912fd14acd603daeff550ed19b8639 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_413c9[];
extern unsigned char DSP_AlgoChannel_SelectorByte5[][6];
extern unsigned int DSP_ChanFreq_CurvePool[][51];
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned char t;
    unsigned char sel;
    unsigned int r;
    t = PART_PATCH(part)[93] & 0xf;
    switch (t) {
    case 6:
    case 7:
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = DSP_ChanFreq_CurvePool[sel][PART_PATCH(part)[95]];
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c9 + part * 0x11f) = r;
}
