/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17c.c (2026-11-16-126-sub-r17)
   sha256 bd67878aa1a0f366ab5645d3437f1f797cce2b2e9dbc7116c6bff2282d78e494 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void Voice_PitchBend(unsigned char *m)
{
    unsigned char part;
    unsigned int w;
    unsigned char *q;
    if (m[1] >= 0x1a) return;
    part = m[1];
    w = (unsigned int)m[3] << 7;
    w |= m[2] | 32768;
    switch ((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        q = *(unsigned char **)(ram_4136e + (int)part * 287);
        AudioChannel_Dispatch(part, w, q + 20);
        return;
    case 0x80:
        q = *(unsigned char **)(ram_4136e + (int)part * 287);
        AudioChannel_Dispatch(part, w, q + 18);
        return;
    }
}
