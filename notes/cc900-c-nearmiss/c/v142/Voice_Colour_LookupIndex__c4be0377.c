/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
extern unsigned char Voice_Colour_RowOffset_Table[];
extern unsigned char Voice_Colour_TransferCurves[];
unsigned int Voice_Colour_LookupIndex(unsigned int a, unsigned char b)
{
    unsigned int r;
    b = (b & 0xe0) >> 5;
    r = Voice_Colour_RowOffset_Table[a];
    return Voice_Colour_TransferCurves[((int)b << 8) + r];
}
