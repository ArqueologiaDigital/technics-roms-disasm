/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_envelopes_and_channels_ag_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 1b4bb0d186058d9acd2018736b641e21f68bf71d32d6b7249cfa49e3ef574558 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41356[];
extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void VoiceModWheel_DataTable_02A061(unsigned char part, unsigned char val)
{
    unsigned char i;
    switch ((*(unsigned char **)(ram_41356 + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, *(unsigned char **)(ram_41356 + (int)part * 287) + ((int)i * 3 + 0x1d));
        break;
    }
}
