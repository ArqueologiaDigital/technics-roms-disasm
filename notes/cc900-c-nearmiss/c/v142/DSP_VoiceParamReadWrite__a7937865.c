/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_22b.c (2026-11-18-29-sub-r21f)
   sha256 a7937865b2d5666356b2f2e8100afb572e560ad0f65760f91724127592776088 (tar-sha256); compiled at -Xr */
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
            if (((*(unsigned char **)&(ram_41368 + (unsigned long)part * 0x11f)[(unsigned long)k * 37 + 0x6e])[6] & 0xc0) == 0) {
                if (!((*(unsigned char **)&(ram_41368 + (unsigned long)part * 0x11f)[(unsigned long)k * 37 + 0x6e])[6] & 0x20))
                    cnt++;
            }
        }
        *out = cnt == 4 ? DSP_VOICEPARAM_DEFAULT_TABLE[(unsigned long)idx] : 0;
    }
    return r;
}
