/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41350[];
extern unsigned char AudioMod_BusRouting_EnableBits[];
extern unsigned char AudioMod_BusRouting_OrIXBits[];

/* cc900-module: AudioMod_Apply_BusRouting */
void AudioMod_Apply_BusRouting(unsigned char part, unsigned char mask, unsigned int a, unsigned int b)
{
    unsigned char w;
    for (w = 0; w < 4; w++) {
        if (AudioMod_BusRouting_EnableBits[w] & mask) {
            if (AudioMod_BusRouting_OrIXBits[w] & mask) {
                (((unsigned int *)&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(w) * 37 + 0x6e])[12]) |= a | b;
            } else {
                (((unsigned int *)&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(w) * 37 + 0x6e])[12]) &= ~b;
                (((unsigned int *)&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(w) * 37 + 0x6e])[12]) |= a;
            }
        } else {
            (((unsigned int *)&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(w) * 37 + 0x6e])[12]) &= ~(a | b);
        }
    }
}
