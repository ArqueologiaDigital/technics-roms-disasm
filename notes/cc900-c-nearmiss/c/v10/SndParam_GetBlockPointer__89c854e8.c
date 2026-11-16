/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-30-p6-r1)
   sha256 89c854e8d1cefff97d8e3bd7f8dd41e25e56a8bb83e3b643d1a5fe02db8a7c3a (tar-sha256); compiled at -O3 -XS -Xr */
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
