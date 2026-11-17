/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_6a.c (2026-11-16-73-sub-r6)
   sha256 48cb2a34c932b610dc7a2362e4cb075b87eb421455fb87b353b9fb0553972087 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char *WaveSel_StageA2_FromToneRec();
void WaveSel_Cache_SetDescPtr(unsigned char a, unsigned char c, unsigned char e)
{
    *(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + a * 0x11f + ((int)c * 37 + (int)e * 4)))[118] =
        WaveSel_StageA2_FromToneRec(a, c, e);
}
