/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_21a.c (2026-11-18-19-sub-r21b-staged)
   sha256 28de3138f83f8ba5dc56f6b6558142886ccd9667bf1bc62fdaa02e6a4566ee82 (tar-sha256); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
extern unsigned char DSP_VOICEPARAM_DEFAULT_TABLE[];
int DSP_VoiceParamReadWrite(unsigned int part, unsigned int idx, unsigned char *out)
{
    int r;
    unsigned int k;
    unsigned int cnt;

    cnt = 0;
    if (*(unsigned int *)(ram_41368 + (unsigned long)part * 0x11f) & 1) {
        *out = ram_44fce[(unsigned long)idx + 0x1d8];
    } else {
        for (k = 0; k < 4; k++) {
            if (((*(unsigned char **)(ram_41368 + (unsigned long)part * 0x11f + ((unsigned long)k * 37 + 0x6e)))[6] & 0xc0) == 0
                && ((*(unsigned char **)(ram_41368 + (unsigned long)part * 0x11f + ((unsigned long)k * 37 + 0x6e)))[6] & 0x20) == 0)
                cnt++;
        }
        *out = cnt == 4 ? DSP_VOICEPARAM_DEFAULT_TABLE[(unsigned long)idx] : 0;
    }
    return r;
}
