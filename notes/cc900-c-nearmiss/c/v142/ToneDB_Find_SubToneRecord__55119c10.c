/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_10a.c (2026-11-16-90-sub-r10)
   sha256 55119c10bf70d64332a47b3a6a60f61ec60204f1153235ca93ccacfebfb2acff (name+funcs); compiled at -Xr */
extern unsigned char *ToneDB_Resolve_NamedToneRecord(int, int, int, int);
unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e)
{
    int x;
    int y;

    x = rec[(int)k * 2 + 0x27];
    y = *(unsigned char *)((unsigned long)&rec[(int)k * 2 + 0x27] + 1);
    return ToneDB_Resolve_NamedToneRecord(x, y, k, e);
}
