/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-31-p6-r1b)
   sha256 3f150caa4e8af344bb960480c9e2d9301aeff28c615c172cb13fb76c7a3f84d7 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char *AccTone_LookupByProgram_Table_2[], AccTone_LookupByProgram_Table[];
extern unsigned long RhythmTiming_OffsetTable[];
unsigned char AccTone_LookupByProgram(unsigned char a)
{
    unsigned char *r;
    unsigned char *t;
    t = AccTone_LookupByProgram_Table_2[(unsigned char)(a - 0xf0)];
    r = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[*t];
    return AccTone_LookupByProgram_Table[r[12]];
}
