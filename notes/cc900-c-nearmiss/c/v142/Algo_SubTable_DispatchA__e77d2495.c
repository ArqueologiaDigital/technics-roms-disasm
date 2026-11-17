/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2a.c (2026-11-16-47-sub-r2)
   sha256 e77d2495b549821b0ba06f8b78d5c1927c12696a39635b76364de81b0b34400e (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
struct algsub { unsigned char a; unsigned char b; unsigned char c; unsigned char d; unsigned char e; };
struct algrec { char pad[0x13]; struct algsub s[4]; };
extern struct algrec DSP_AlgoDescriptor_Records[];
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char slot)
{
    unsigned char t;
    unsigned char r;
    t = PART_PATCH(part)[93] & 0xf;
    r = DSP_AlgoDescriptor_Records[t].s[slot].b;
    if (t == 8) {
        if (slot == 1) r = PART_PATCH(part)[96];
    }
    return r;
}
