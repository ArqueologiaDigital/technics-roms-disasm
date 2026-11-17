/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3b.c (2026-11-16-58-sub-r3)
   sha256 e14e6b6d5c368715cf8ab076373270904387a8c8c479bba7f55ed229322f8ab3 (name+funcs); compiled at -Xr */
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
    if (t == 7 || t == 6) {
        sel = DSP_AlgoChannel_SelectorByte5[t][0];
        r = DSP_ChanFreq_CurvePool[sel][PART_PATCH(part)[95]];
    } else r = 0;
    *(unsigned int *)(ram_413c9 + part * 0x11f) = r;
}
