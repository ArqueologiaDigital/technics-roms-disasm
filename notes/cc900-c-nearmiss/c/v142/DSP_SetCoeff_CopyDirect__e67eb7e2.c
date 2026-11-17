/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_9c.c (2026-11-16-86-sub-r9)
   sha256 e67eb7e2c0c66eb6b52a53b2f206995f13036598ffdb92b26d1921ab65cda84b (name+funcs); compiled at -O1 -Xr */
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
void DSP_SetCoeff_CopyDirect(unsigned int n)
{
    unsigned long off;
    unsigned char *src;
    unsigned int i;
    unsigned int cnt;

    off = ToneDB_RootPtr[32];
    src = (unsigned char *)(ToneDB_RelBase + off);
    cnt = 13;
    for (i = 0; i < cnt; i++)
        ram_45210[i + 6] = src[(unsigned long)n * 16 + i];
}
