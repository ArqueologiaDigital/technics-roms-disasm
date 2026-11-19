/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_26c.c (2026-11-19-30-sub-r26a)
   sha256 40a21d1fb0f304e8922b84cb8fde2528ea1fae3343dec596f1d9e9a5eaa3ca0b (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot);
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot)
{
    if (*(unsigned int *)&ram_41368[part * 0x11f] & 1) {
        *(unsigned char **)((((int)slot * 37 + 0x6e) + (unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)) + 4) =
            &ram_44fce[(int)(unsigned int)((int)slot * 11 + 0x1aa)];
    } else {
        *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)slot * 37 + 0x6e)))[4] =
            WaveSel_StageA1_FromPatchBlock(part, slot);
    }
}
