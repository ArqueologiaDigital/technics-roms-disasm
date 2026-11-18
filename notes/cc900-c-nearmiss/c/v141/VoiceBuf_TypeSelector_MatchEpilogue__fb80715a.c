/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/dsp_voice_params_ai_21c.c (2026-11-18-21-sub-r21c-staged)
   sha256 fb80715a9d256d63b56ee5de677ab66aac2b56b4487124ab6ef4d593ca96a3e2 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41356[];
extern unsigned char ram_4136a[];
extern unsigned int VoiceChanScan_SlotEnableMask[];
unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c)
{
    unsigned char b;
    unsigned char w;
    if (ram_4136a[part * 0x11f] < 0x10 || c == 0) {
        if (VoiceChanScan_SlotEnableMask[c] & (*(unsigned char **)(ram_41356 + (part) * 0x11f))[17]) {
            w = 0;
            for (b = 1; b < c + 1; b++)
                if (VoiceChanScan_SlotEnableMask[b] & (*(unsigned char **)(ram_41356 + (part) * 0x11f))[17]) w++;
            c = w;
        } else c = 0xff;
    }
    return c;
}
