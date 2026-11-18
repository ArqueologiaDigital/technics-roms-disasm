/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_envelopes_and_channels_ag_21c.c (2026-11-18-32-sub-r21g-staged)
   sha256 2d9b8d39311e011936c634fda410ce355aac0e6a47f1412482b273a81a2156e9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4132f[];
extern unsigned char ram_41339[];
void AudioMod_Apply_Porta_Curve(unsigned char part, int val, unsigned char *m)
{
    long r;
    if (m[1] & 0x80) r = (long)val - 8192;
    else r = (long)val >> 1;
    r = m[2] * r;
    r >>= 6;
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
        r = r * ram_4132f[part * 0x11f];
        break;
    }
    r <<= 9;
    if (r > 0) r = r / 16384;
    else r = r / 16383;
    *(int *)&ram_41339[part * 0x11f] = r;
}
