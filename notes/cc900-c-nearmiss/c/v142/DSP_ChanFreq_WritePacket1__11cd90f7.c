/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18c.c (2026-11-17-7-sub-r18)
   sha256 11cd90f719c686bf95df843efa1165d230f4ca93f1f4a74de11f60b2fcf7bbb8 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_413c7[];
extern unsigned char DSP_AlgoDescriptor_SelIdx[];
extern unsigned char DSP_AlgoChannel_SelectorByte4[][6];
extern unsigned char DSP_ChanFreq_Packet1_Curve[];
extern int EGEnv_ModeBits_Table[];
#define PATCH(p) (*(unsigned char **)&ram_4136e[(p) * 0x11f])
unsigned int DSP_ChanFreq_WritePacket1(unsigned char part)
{
    unsigned int r;
    unsigned char t;
    unsigned char sel;

    t = PATCH(part)[93] & 0xf;
    switch (t) {
    case 6:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66))[PATCH(part)[94]];
        r |= EGEnv_ModeBits_Table[PATCH(part)[96]];
        break;
    case 7:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66))[DSP_AlgoDescriptor_SelIdx[(unsigned int)t * 0x27]];
        break;
    default:
        r = 0;
    }
    return (*(unsigned int *)(ram_413c7 + part * 0x11f) = r);
}
