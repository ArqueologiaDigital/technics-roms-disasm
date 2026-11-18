/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AG_20a.c (2026-11-18-18-sub-r21a)
   sha256 e64749487a5b77e74adcadd02c8847171c6991e4cd15a61fe8c5172fc9c0813c (tar-sha256); compiled at -Xr */
extern unsigned char ram_4137b[];
extern unsigned char ram_41385[];
void AudioMod_Apply_Porta_Curve(unsigned char part, int val, unsigned char *m)
{
    long r;
    if (m[1] & 0x80) r = (long)val - 8192;
    else r = (long)val >> 1;
    r = r * m[2] >> 6;
    switch (part) {
    case 0x10:
    case 0x11:
    case 0x12:
    case 0x13:
    case 0x15:
    case 0x16:
    case 0x17:
    case 0x18:
    case 0x19:
        r = r * 12;
        break;
    default:
        r = r * ram_4137b[part * 0x11f];
        break;
    }
    r <<= 9;
    if (r > 0) r = r / 16384;
    else r = r / 16383;
    *(int *)&ram_41385[part * 0x11f] = r;
}
