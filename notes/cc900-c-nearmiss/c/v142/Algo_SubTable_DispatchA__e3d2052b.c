/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w4a.c (2026-11-19-10-sub-r23w-asm)
   sha256 e3d2052b28570ae8bfe935ea9dda629d0d26b499fe425733ed49ee3544609745 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
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
