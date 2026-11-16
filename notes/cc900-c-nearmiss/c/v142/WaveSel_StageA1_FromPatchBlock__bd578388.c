/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_11b.c (2026-11-16-94-sub-r11)
   sha256 bd5783887b95ef5eafc767a653a0a38f9363723a2758927b050ad92af2b06c6f (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_41381[];
extern void WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
void WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot)
{
    int x;
    int y;

    x = (*(unsigned char **)&((unsigned char *)((unsigned long)ram_41368 + (long)((int)part * 0x11f)))[(int)slot * 37 + 0x6e])[2];
    y = (*(unsigned char **)&((unsigned char *)((unsigned long)ram_41368 + (long)((int)part * 0x11f)))[(int)slot * 37 + 0x6e])[3];
    WaveSel_StageA1_FindVelSplit(slot, (unsigned char)x, (unsigned char)y, ram_41381[part * 0x11f], part);
}
