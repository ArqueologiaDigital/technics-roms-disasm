/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_25c.c (2026-11-19-27-sub-r25a)
   sha256 680e91dbe4d3bb7869ab1f88857f50f8ea86aeaac3846bd3459c9b40b2ef9bd0 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot);
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot)
{
    if (*(unsigned int *)&ram_41368[part * 0x11f] & 1) {
        *(unsigned char **)(((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f) + ((int)slot * 37 + 0x6e)) + 4) =
            &ram_44fce[(int)(unsigned int)((int)slot * 11 + 0x1aa)];
    } else {
        *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)slot * 37 + 0x6e)))[4] =
            WaveSel_StageA1_FromPatchBlock(part, slot);
    }
}
