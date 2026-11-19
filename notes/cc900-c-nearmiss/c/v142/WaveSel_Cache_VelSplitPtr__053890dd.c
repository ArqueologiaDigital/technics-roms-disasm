/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_26a.c (2026-11-19-30-sub-r26a)
   sha256 053890dd60837e738fe353af1697989105b37f380ad816b39b57b6455beaa9c1 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot);
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot)
{
    if (*(unsigned int *)&ram_41368[part * 0x11f] & 1) {
        *(unsigned char **)&((unsigned char *)(unsigned long)(((int)slot * 37 + 0x6e)
                                                              + (unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)))[4] =
            &ram_44fce[(int)(unsigned int)((int)slot * 11 + 0x1aa)];
    } else {
        *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)slot * 37 + 0x6e)))[4] =
            WaveSel_StageA1_FromPatchBlock(part, slot);
    }
}
