/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-31-p6-r1b)
   sha256 7d16c83e6f1cf5e299730f8d1d1afaeca30c78536fe0c0f5702fb6c24ee9316d (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char SndParam_PresetBanks[];
unsigned char *SndParam_GetBlockPointer(unsigned char a)
{
    if (a < 0x19) return SndParam_PresetBanks + a * 0xea;
    switch (a) {
    default: return 0;
    case 0x1b: return (unsigned char *)0x3d3010;
    case 0x1c: return (unsigned char *)0x3d3110;
    case 0x1d: return (unsigned char *)0x3d3210;
    }
}
