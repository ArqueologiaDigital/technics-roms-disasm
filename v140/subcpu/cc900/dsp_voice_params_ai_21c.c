/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41322[];
extern unsigned char ram_41336[];
extern unsigned int VoiceChanScan_SlotEnableMask[];

unsigned char VoiceBuf_TypeSelector_MatchEpilogue(unsigned char part, unsigned char c)
{
    unsigned char b;
    unsigned char w;
    if (ram_41336[part * 0x11f] < 0x10 || c == 0) {
        if (VoiceChanScan_SlotEnableMask[c] & (*(unsigned char **)(ram_41322 + (part) * 0x11f))[17]) {
            w = 0;
            for (b = 1; b < c + 1; b++)
                if (VoiceChanScan_SlotEnableMask[b] & (*(unsigned char **)(ram_41322 + (part) * 0x11f))[17]) w++;
            c = w;
        } else c = 0xff;
    }
    return c;
}
