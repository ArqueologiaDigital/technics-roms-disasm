/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AK_23c.c (2026-11-19-11-sub-r23h-helpers)
   sha256 65cbfbbe65fa282d080e419a18a57186237b2fde7a8580acbb4d99f475fc1845 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136e[];
int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void Voice_ChanPressure(unsigned char *m)
{
    unsigned char part;
    unsigned char *pr;
    unsigned char i;

    (void *)&part;
    if (m[1] >= 0x1a) return;
    switch ((*(unsigned char **)(ram_4136e + (int)(part = m[1]) * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        pr = *(unsigned char **)(ram_4136e + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, m[3], ((int)i * 3 + 0x23) + pr);
        break;
    case 0x80:
        pr = *(unsigned char **)(ram_4136e + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, m[3], ((int)i * 3 + 0x21) + pr);
        break;
    }
}
