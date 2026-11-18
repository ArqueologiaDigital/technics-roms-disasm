/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_envelopes_and_channels_ag_21c.c (2026-11-18-32-sub-r21g-staged)
   sha256 bc24bdca41605fca055b94c122346623fea398d82dff72142e5518141d09790f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4137b[];
extern unsigned char ram_41385[];
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
        r = r * ram_4137b[part * 0x11f];
        break;
    }
    r <<= 9;
    if (r > 0) r = r / 16384;
    else r = r / 16383;
    *(int *)&ram_41385[part * 0x11f] = r;
}
