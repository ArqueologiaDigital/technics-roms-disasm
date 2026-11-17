/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3a.c (2026-11-16-37-p6-r5)
   sha256 3f4da9760305cc181a03f903f54adec3de046408b1665d02d1fe4258e884294e (tar-sha256); compiled at -O3 -Xr */
extern unsigned char SndParam_PresetBanks[];
unsigned char *SndParam_GetBlockPointer(unsigned char a)
{
    unsigned char *b;
    int k;
    if (a < 0x19) {
        k = a;
        b = SndParam_PresetBanks;
        return b + k * 0xea;
    }
    switch (a) {
    case 0x1b: return (unsigned char *)0x3d3010;
    case 0x1c: return (unsigned char *)0x3d3110;
    case 0x1d: return (unsigned char *)0x3d3210;
    }
    return 0;
}
