/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17b.c (2026-11-16-126-sub-r17)
   sha256 0e0a840326316c81afba23a05abfb073bad3f8133f4552d566393030e1a46134 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void Voice_PitchBend(unsigned char *m)
{
    unsigned char part;
    unsigned int w;
    if (m[1] >= 0x1a) return;
    part = m[1];
    w = ((unsigned int)m[3] << 7) | (m[2] | 32768);
    switch ((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        AudioChannel_Dispatch(part, w, *(unsigned char **)(ram_4136e + (int)part * 287) + 20);
        break;
    case 0x80:
        AudioChannel_Dispatch(part, w, *(unsigned char **)(ram_4136e + (int)part * 287) + 18);
        break;
    }
}
