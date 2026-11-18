/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_envelopes_and_channels_ag_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 ffcedff560f1dc88ff9d34b0d6db4e4b13655df466d77899e99df330f4d6543b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41322[];
extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void VoiceModWheel_DataTable_02A061(unsigned char part, unsigned char val)
{
    unsigned char i;
    switch ((*(unsigned char **)(ram_41322 + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, *(unsigned char **)(ram_41322 + (int)part * 287) + ((int)i * 3 + 0x1d));
        break;
    }
}
