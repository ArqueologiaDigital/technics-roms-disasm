/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
extern unsigned char Voice_Selector_FieldSlot_Table[][3];
void Voice_Selector_Unpack3Groups(unsigned char *p, unsigned int v, unsigned char e)
{
    p[Voice_Selector_FieldSlot_Table[e][0]] = v & 0xf;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][1]] = v & 0xf;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][2]] = v & 0xf;
}
