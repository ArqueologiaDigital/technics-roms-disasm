/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3a.c (2026-11-16-58-sub-r3)
   sha256 528c9ccfc8cfe66716d81cade2bea6c2e8912fd14acd603daeff550ed19b8639 (name+funcs); compiled at -Xr */
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
    switch (t) {
    case 8:
        if (slot == 1) r = PART_PATCH(part)[96];
    }
    return r;
}
