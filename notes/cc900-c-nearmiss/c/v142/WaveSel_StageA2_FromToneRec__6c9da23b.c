/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17a.c (2026-11-16-126-sub-r17)
   sha256 6c9da23be1740b125262337d35d6419d9e17f20c3d4204d47661ba77eaf9761b (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct slotrec { unsigned char *p0; unsigned char *vel; };
struct b5 { unsigned char f0; unsigned char f1; unsigned char f2; unsigned char f3; unsigned char f4; };
extern void WaveSel_StageA2_FindSetDesc(int, int);
void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z)
{
    int lo;
    int hi;
    lo = ((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->vel[(int)z * 2 + 3];
    hi = ((struct b5 *)&((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->vel[(int)z * 2 + 3])->f1;
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}
