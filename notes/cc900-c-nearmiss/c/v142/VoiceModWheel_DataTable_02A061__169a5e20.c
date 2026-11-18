/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_envelopes_and_channels_ag_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 169a5e2055979a6e2611f549812fd19ea8357c1809485d3c025a465401095fd4 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136e[];
extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void VoiceModWheel_DataTable_02A061(unsigned char part, unsigned char val)
{
    unsigned char i;
    switch ((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, *(unsigned char **)(ram_4136e + (int)part * 287) + ((int)i * 3 + 0x1d));
        break;
    }
}
