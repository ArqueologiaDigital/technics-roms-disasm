/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/dsp_voice_params_ai_22a.c (2026-11-18-32-sub-r21g-staged)
   sha256 60f85914f1fed144b9fba7f85b0afb9e425a3d04cea8f6f4cf651bee755922de (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4131c[];
extern unsigned char ram_44f82[];
extern unsigned char DSP_VOICEPARAM_DEFAULT_TABLE[];
int DSP_VoiceParamReadWrite(unsigned int part, unsigned int idx, unsigned char *out)
{
    int r;
    unsigned int k;
    unsigned int cnt;
    cnt = 0;
    if (*(unsigned int *)(ram_4131c + (unsigned long)part * 0x11f) & 1) {
        *out = ram_44f82[(unsigned long)idx + 0x1d8];
    } else {
        for (k = 0; k < 4; k++) {
            if (((*(unsigned char **)((unsigned long)(ram_4131c + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0xc0) == 0) {
                if (!((*(unsigned char **)((unsigned long)(ram_4131c + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0x20))
                    cnt++;
            }
        }
        *out = cnt == 4 ? DSP_VOICEPARAM_DEFAULT_TABLE[(unsigned long)idx] : 0;
    }
    return r;
}
