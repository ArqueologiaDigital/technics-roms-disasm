/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/dsp_voice_params_ai_21c.c (2026-11-18-21-sub-r21c-staged)
   sha256 b26dc6f954754ab99fef2a7065faf3f933e594d9e2a6f465f7596bff69bfa66f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41382[];
extern unsigned int VoiceChanScan_SlotEnableMask[];
unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c)
{
    unsigned char b;
    unsigned char w;
    if (ram_41382[part * 0x11f] < 0x10 || c == 0) {
        if (VoiceChanScan_SlotEnableMask[c] & (*(unsigned char **)(ram_4136e + (part) * 0x11f))[17]) {
            w = 0;
            for (b = 1; b < c + 1; b++)
                if (VoiceChanScan_SlotEnableMask[b] & (*(unsigned char **)(ram_4136e + (part) * 0x11f))[17]) w++;
            c = w;
        } else c = 0xff;
    }
    return c;
}
