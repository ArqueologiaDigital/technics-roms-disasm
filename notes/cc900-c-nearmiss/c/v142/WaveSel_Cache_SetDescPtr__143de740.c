/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_7a.c (2026-11-16-79-sub-r7)
   sha256 143de7409dae35d7976fc4f35166d64c5f696ce04cd1c3c30aec77c5887d93f4 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char *WaveSel_StageA2_FromToneRec();
void WaveSel_Cache_SetDescPtr(unsigned char a, unsigned char c, unsigned char e)
{
    *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + a * 0x11f)
                                                         + ((int)c * 37 + (int)e * 4)))[118] =
        WaveSel_StageA2_FromToneRec(a, c, e);
}
