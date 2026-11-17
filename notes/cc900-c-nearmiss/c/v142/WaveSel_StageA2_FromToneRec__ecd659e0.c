/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_10c.c (2026-11-16-90-sub-r10)
   sha256 ecd659e02d856f795e8e5bc4d2071af22ef5d0dc0758d1b8896dd134179ad82d (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern void WaveSel_StageA2_FindSetDesc(int, int);
void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z)
{
    int lo;
    int hi;

    lo = (*(unsigned char **)((unsigned long)&(ram_41368 + (int)part * 0x11f)[(int)slot * 37 + 0x6e] + 4))[(int)z * 2 + 3];
    hi = *(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&(ram_41368 + (int)part * 0x11f)[(int)slot * 37 + 0x6e] + 4))[(int)z * 2 + 3] + 1);
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}
