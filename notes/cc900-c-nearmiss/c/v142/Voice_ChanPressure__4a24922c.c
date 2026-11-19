/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AK_23a.c (2026-11-19-11-sub-r23h-helpers)
   sha256 4a24922c9cacfd2bb26eb34d451f6c3f059d692d5b474e169b542a9dbffe7789 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136e[];
int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void Voice_ChanPressure(unsigned char *m)
{
    unsigned char part;
    unsigned char *pr;
    unsigned char i;

    if (m[1] >= 0x1a) return;
    switch ((*(unsigned char **)(ram_4136e + (int)(part = m[1]) * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        pr = *(unsigned char **)(ram_4136e + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, m[3], pr + ((int)i * 3 + 0x23));
        break;
    case 0x80:
        pr = *(unsigned char **)(ram_4136e + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, m[3], pr + ((int)i * 3 + 0x21));
        break;
    }
}
