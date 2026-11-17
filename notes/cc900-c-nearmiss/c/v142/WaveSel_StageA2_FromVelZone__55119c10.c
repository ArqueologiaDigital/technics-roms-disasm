/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_10a.c (2026-11-16-90-sub-r10)
   sha256 55119c10bf70d64332a47b3a6a60f61ec60204f1153235ca93ccacfebfb2acff (name+funcs); compiled at -Xr */
extern void WaveSel_StageA2_FindSetDesc(int, int);
void WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p)
{
    int lo;
    int hi;

    lo = p[(int)z * 2 + 3];
    hi = *(unsigned char *)((unsigned long)(p + ((int)z * 2 + 3)) + 1);
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}
