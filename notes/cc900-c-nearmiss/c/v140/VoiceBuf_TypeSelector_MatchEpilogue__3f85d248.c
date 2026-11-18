/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/dsp_voice_params_ai_21c.c (2026-11-18-21-sub-r21c-staged)
   sha256 3f85d248b41a955ae75775ba0084608d95e75998810b264eb99ab490b0f18e2d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41322[];
extern unsigned char ram_41336[];
extern unsigned int VoiceChanScan_SlotEnableMask[];
unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c)
{
    unsigned char b;
    unsigned char w;
    if (ram_41336[part * 0x11f] < 0x10 || c == 0) {
        if (VoiceChanScan_SlotEnableMask[c] & (*(unsigned char **)(ram_41322 + (part) * 0x11f))[17]) {
            w = 0;
            for (b = 1; b < c + 1; b++)
                if (VoiceChanScan_SlotEnableMask[b] & (*(unsigned char **)(ram_41322 + (part) * 0x11f))[17]) w++;
            c = w;
        } else c = 0xff;
    }
    return c;
}
