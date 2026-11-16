/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_7a.c (2026-11-16-79-sub-r7)
   sha256 143de7409dae35d7976fc4f35166d64c5f696ce04cd1c3c30aec77c5887d93f4 (name+funcs); compiled at -Xr */
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
unsigned char *ToneDB_Find_SubToneRecord(unsigned char *p, unsigned char c, unsigned char e)
{
    unsigned int x;
    unsigned int y;
    x = p[(int)c * 2 + 39];
    y = (p + ((int)c * 2 + 39))[1];
    return ToneDB_Resolve_NamedToneRecord(x, y, c, e);
}
