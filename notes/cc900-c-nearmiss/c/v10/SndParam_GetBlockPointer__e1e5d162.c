/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2a.c (2026-11-16-33-p6-r2)
   sha256 e1e5d1622a68bbc27489c801d6928dde38f9ceff8816827f2bfd0be724fc352c (tar-sha256); compiled at -O3 -Xr */
extern unsigned char SndParam_PresetBanks[];
unsigned char *SndParam_GetBlockPointer(unsigned char a)
{
    int k;
    if (a < 0x19) {
        k = a;
        return &SndParam_PresetBanks[k * 0xea];
    }
    switch (a) {
    case 0x1b: return (unsigned char *)0x3d3010;
    case 0x1c: return (unsigned char *)0x3d3110;
    case 0x1d: return (unsigned char *)0x3d3210;
    }
    return 0;
}
