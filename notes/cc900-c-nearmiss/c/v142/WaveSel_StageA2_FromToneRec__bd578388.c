/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_11b.c (2026-11-16-94-sub-r11)
   sha256 bd5783887b95ef5eafc767a653a0a38f9363723a2758927b050ad92af2b06c6f (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern void WaveSel_StageA2_FindSetDesc(int, int);
void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z)
{
    int lo;
    int hi;

    lo = (*(unsigned char **)((unsigned long)&((unsigned char *)((unsigned long)ram_41368 + (long)((int)part * 0x11f)))[(int)slot * 37 + 0x6e] + 4))[(int)z * 2 + 3];
    hi = *(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&((unsigned char *)((unsigned long)ram_41368 + (long)((int)part * 0x11f)))[(int)slot * 37 + 0x6e] + 4))[(int)z * 2 + 3] + 1);
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}
