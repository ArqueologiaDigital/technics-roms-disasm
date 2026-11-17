/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7j.c (2026-11-16-79-sub-r7)
   sha256 ebea7b20874d86b6abbc94f697af05ece70c1ce78314197a491ad92cb8b4b437 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern void VoiceParam_FullSetup(int);
extern void WaveSel_Rebuild_PartCaches(int, int, int);
extern void DSP_AdjustVoiceParams(unsigned char *);
extern void DSP_WriteAlgoBuffer(int, int);
extern void DSP_VoiceState_Dispatch(int, int);
int DSP_AlgoSelect(unsigned char part, unsigned int algo, unsigned char *err)
{
    unsigned char *rec;
    if (algo < 40) {
        rec = &ram_41368[part * 0x11f];
        if (!(*(unsigned int *)rec & 1)) {
            *(unsigned int *)rec |= 1;
            VoiceParam_FullSetup(part);
            WaveSel_Rebuild_PartCaches(part, rec[25], rec[26]);
        }
        if (*(unsigned int *)rec & 1) DSP_AdjustVoiceParams(rec);
        DSP_WriteAlgoBuffer(part, algo);
        DSP_VoiceState_Dispatch(0xff, 0xff);
        *err = 0;
    } else *err = 2;
    return 1;
}
