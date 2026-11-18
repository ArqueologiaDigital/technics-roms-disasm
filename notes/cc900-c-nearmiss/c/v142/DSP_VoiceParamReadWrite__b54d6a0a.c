/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/dsp_voice_params_ai_22a.c (2026-11-18-32-sub-r21g-staged)
   sha256 b54d6a0ad609d3d1db832de095dd1e663019c7025aaea2349ba161515c0f3718 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
            if (((*(unsigned char **)((unsigned long)(ram_41368 + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0xc0) == 0) {
                if (!((*(unsigned char **)((unsigned long)(ram_41368 + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0x20))
                    cnt++;
            }
        }
        *out = cnt == 4 ? DSP_VOICEPARAM_DEFAULT_TABLE[(unsigned long)idx] : 0;
    }
    return r;
}
