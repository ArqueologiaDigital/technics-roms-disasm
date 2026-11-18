/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_envelopes_and_channels_ag_20a.c (2026-11-18-19-sub-r21b-staged)
   sha256 43c1560f4df2ca61e8c75bbfb0990a5af59f9cc7e1581a028228a7a2eb483f05 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41356[];
extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void Voice_ModWheel_Apply(unsigned char part, unsigned char val)
{
    unsigned char *pr;
    unsigned int i;
    switch ((*(unsigned char **)(ram_41356 + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, *(unsigned char **)(ram_41356 + (int)part * 287) + ((unsigned long)i * 3 + 0x17));
        break;
    case 0x80:
        pr = *(unsigned char **)(ram_41356 + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, pr + ((unsigned long)i * 3 + 0x15));
        break;
    }
}
