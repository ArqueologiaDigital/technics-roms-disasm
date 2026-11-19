/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AK_23b.c (2026-11-19-11-sub-r23h-helpers)
   sha256 0698f9ca782ce17a5cc1b5e31a7d86c061435b71cd238ca979dd16ad2273fde5 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136e[];
int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void Voice_ChanPressure(unsigned char *m)
{
    unsigned char part;
    unsigned char *pr;
    unsigned char i;
    unsigned char u;

    if (m[1] >= 0x1a) return;
    u = m[1];
    part = u;
    switch ((*(unsigned char **)(ram_4136e + (int)u * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        pr = *(unsigned char **)(ram_4136e + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, m[3], &pr[(int)i * 3 + 0x23]);
        break;
    case 0x80:
        pr = *(unsigned char **)(ram_4136e + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, m[3], &pr[(int)i * 3 + 0x21]);
        break;
    }
}
