/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2b.c (2026-11-16-33-p6-r2)
   sha256 6466b0db5cc304449e230b5c4768605e1ab3bae7d08d95327934985fddd8f094 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *AccTone_LookupByProgram_Table_2[];
extern unsigned long RhythmTiming_OffsetTable[];
extern unsigned char AccTone_LookupByProgram_Table[];
unsigned char AccTone_LookupByProgram(unsigned char a)
{
    unsigned char *p;
    unsigned char *r;
    p = AccTone_LookupByProgram_Table_2[(unsigned char)(a - 0xf0)];
    r = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[*p];
    return AccTone_LookupByProgram_Table[r[12]];
}
