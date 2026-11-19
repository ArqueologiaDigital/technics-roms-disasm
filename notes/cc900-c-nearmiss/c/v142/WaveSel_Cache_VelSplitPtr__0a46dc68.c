/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_24c.c (2026-11-19-24-sub-r24a)
   sha256 0a46dc6816abd4fd6b112927e37cd1a316dd4f023a0510735532d0682f7d0910 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot);
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot)
{
    if (*(unsigned int *)&ram_41368[part * 0x11f] & 1) {
        *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)slot * 37 + 0x6e)))[4] =
            &ram_44fce[(int)(unsigned int)((int)slot * 11 + 0x1aa)];
    } else {
        *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)slot * 37 + 0x6e)))[4] =
            WaveSel_StageA1_FromPatchBlock(part, slot);
    }
}
