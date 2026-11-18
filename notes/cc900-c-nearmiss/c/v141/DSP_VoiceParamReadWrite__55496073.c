/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/dsp_voice_params_ai_22a.c (2026-11-18-32-sub-r21g-staged)
   sha256 55496073d78ab37af244a6452c3457aa1623dd98d93a2fdc3faae092efc0c86f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41350[];
extern unsigned char ram_44fb6[];
extern unsigned char DSP_VOICEPARAM_DEFAULT_TABLE[];
int DSP_VoiceParamReadWrite(unsigned int part, unsigned int idx, unsigned char *out)
{
    int r;
    unsigned int k;
    unsigned int cnt;
    cnt = 0;
    if (*(unsigned int *)(ram_41350 + (unsigned long)part * 0x11f) & 1) {
        *out = ram_44fb6[(unsigned long)idx + 0x1d8];
    } else {
        for (k = 0; k < 4; k++) {
            if (((*(unsigned char **)((unsigned long)(ram_41350 + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0xc0) == 0) {
                if (!((*(unsigned char **)((unsigned long)(ram_41350 + (unsigned long)part * 0x11f) + ((unsigned long)k * 37 + 0x6e)))[6] & 0x20))
                    cnt++;
            }
        }
        *out = cnt == 4 ? DSP_VOICEPARAM_DEFAULT_TABLE[(unsigned long)idx] : 0;
    }
    return r;
}
