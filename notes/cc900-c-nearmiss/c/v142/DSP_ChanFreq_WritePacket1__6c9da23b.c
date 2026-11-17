/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17a.c (2026-11-16-126-sub-r17)
   sha256 6c9da23be1740b125262337d35d6419d9e17f20c3d4204d47661ba77eaf9761b (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_413c7[];
extern unsigned char DSP_AlgoDescriptor_SelIdx[];
extern unsigned char DSP_AlgoChannel_SelectorByte4[][6];
extern unsigned char DSP_ChanFreq_Packet1_Curve[];
extern int EGEnv_ModeBits_Table[];
void DSP_ChanFreq_WritePacket1(unsigned char part)
{
    unsigned char t;
    unsigned char sel;
    unsigned int r;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 6:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]]
            | EGEnv_ModeBits_Table[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[96]];
        break;
    case 7:
        sel = DSP_AlgoChannel_SelectorByte4[t][0];
        r = ((unsigned int *)(DSP_ChanFreq_Packet1_Curve + (int)sel * 0x66))[DSP_AlgoDescriptor_SelIdx[t * 0x27]];
        break;
    default:
        r = 0;
    }
    *(unsigned int *)(ram_413c7 + part * 0x11f) = r;
}
