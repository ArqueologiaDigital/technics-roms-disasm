/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17b.c (2026-11-16-126-sub-r17)
   sha256 103952cb479afdc1c60db40fc3853c5ae181d89a51e462c0596d12a2a476ff39 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct slotrec { unsigned char *p0; unsigned char *vel; };
extern void WaveSel_StageA2_FindSetDesc(int, int);
void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z)
{
    int lo;
    int hi;
    lo = ((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->vel[(int)z * 2 + 3];
    hi = (&((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->vel[(int)z * 2 + 3])[1];
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}
