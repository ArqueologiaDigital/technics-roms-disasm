/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_6a.c (2026-11-16-73-sub-r6)
   sha256 48cb2a34c932b610dc7a2362e4cb075b87eb421455fb87b353b9fb0553972087 (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern unsigned char *ToneDB_Find_ToneRecord_CoeffPath(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b);
unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b)
{
    unsigned char *r;
    if (ram_41343 & 1) r = ToneDB_Find_ToneRecord_CoeffPath(a, b);
    else r = ToneDB_Find_PatchRecord(a, b);
    return r;
}
