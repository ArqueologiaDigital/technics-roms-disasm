/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3b.c (2026-11-16-58-sub-r3)
   sha256 e14e6b6d5c368715cf8ab076373270904387a8c8c479bba7f55ed229322f8ab3 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
struct algrec { unsigned char pad[0x13]; unsigned char s[4][5]; };
extern unsigned char DSP_AlgoDescriptor_Records[][0x27];
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char slot)
{
    unsigned char t;
    unsigned char r;
    t = PART_PATCH(part)[93] & 0xf;
    r = ((struct algrec *)DSP_AlgoDescriptor_Records[t])->s[slot][1];
    if (t == 8 && slot == 1) r = PART_PATCH(part)[96];
    return r;
}
