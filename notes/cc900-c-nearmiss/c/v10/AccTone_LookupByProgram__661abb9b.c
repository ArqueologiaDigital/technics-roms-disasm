/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-30-p6-r1)
   sha256 661abb9b1607433d32862ee68a6f8b4ea5a2c002087e5a7b864f5b7e199c0570 (tar-sha256); compiled at -O3 -XS -Xr */
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
