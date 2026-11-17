/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3b.c (2026-11-16-58-sub-r3)
   sha256 788f0d271359aef4ace536ce58c994c054403ce241712b29d2f7e0b99f5470cf (name+funcs); compiled at -Xr */
extern unsigned char Voice_Selector_FieldSlot_Table[][3];
void Voice_Selector_Unpack3Groups(unsigned char *p, unsigned int v, unsigned char e)
{
    p[Voice_Selector_FieldSlot_Table[e][0]] = (int)v & 0xf;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][1]] = (int)v & 0xf;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][2]] = (int)v & 0xf;
}
