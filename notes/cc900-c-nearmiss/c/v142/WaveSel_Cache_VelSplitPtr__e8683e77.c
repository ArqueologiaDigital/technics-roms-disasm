/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_23a.c (2026-11-19-11-sub-r23h-helpers)
   sha256 e8683e77249204df0e843745ae4458f42cb1a47a265a11dc5eab820db5604c24 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot);
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot)
{
    if (*(unsigned int *)&ram_41368[part * 0x11f] & 1) {
        *(unsigned char **)&(&(&ram_41368[(int)(unsigned int)((int)part * 0x11f)])
                               [(int)(unsigned int)((int)slot * 37 + 0x6e)])[4] =
            &ram_44fce[(int)(unsigned int)((int)slot * 11 + 0x1aa)];
    } else {
        *(unsigned char **)&(&(&ram_41368[(int)(unsigned int)((int)part * 0x11f)])
                               [(int)slot * 37 + 0x6e])[4] =
            WaveSel_StageA1_FromPatchBlock(part, slot);
    }
}
