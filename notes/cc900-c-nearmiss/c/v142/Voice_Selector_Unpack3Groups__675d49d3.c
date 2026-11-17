/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2c.c (2026-11-16-47-sub-r2)
   sha256 675d49d3eeeea79e327148ffdc5c5179606a08452f10204af09a37e964ae4c72 (name+funcs); compiled at -Xr */
extern unsigned char Voice_Selector_FieldSlot_Table[][3];
void Voice_Selector_Unpack3Groups(unsigned char *p, unsigned int v, unsigned char e)
{
    p[Voice_Selector_FieldSlot_Table[e][0]] = v & 0xf;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][1]] = v & 0xf;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][2]] = v & 0xf;
}
