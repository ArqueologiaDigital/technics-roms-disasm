/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_4132f[];
extern unsigned char ram_41339[];
void AudioMod_Apply_Porta_Curve(unsigned char part, int val, unsigned char *m);

/* cc900-data: AudioMod_Apply_Porta_Curve 1 = AudioMod_PortaCurve_CaseOffsets */
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
