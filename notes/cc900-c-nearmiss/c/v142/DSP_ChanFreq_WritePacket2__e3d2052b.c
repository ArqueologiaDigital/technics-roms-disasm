/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w4a.c (2026-11-19-10-sub-r23w-asm)
   sha256 e3d2052b28570ae8bfe935ea9dda629d0d26b499fe425733ed49ee3544609745 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
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
