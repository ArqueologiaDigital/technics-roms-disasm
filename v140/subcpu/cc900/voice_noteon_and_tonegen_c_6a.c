/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_4131c[];
extern unsigned char ram_41335[];
extern unsigned char ram_41336[];
extern unsigned char ram_45158;
extern void VoiceParam_FullSetup();
extern void WaveSel_Rebuild_PartCaches();

/* cc900-module: VoiceParam_FullSetup */
void VoiceAlloc_CheckAndInit(unsigned char part)
{
    if (ram_45158 == part) {
        if (part <= 2 || (*(unsigned int *)(ram_4131c + part * 0x11f) & 3) == 3) {
            if (*(unsigned int *)(ram_4131c + part * 0x11f) & 1) {
                *(unsigned int *)(ram_4131c + part * 0x11f) |= 1;
            } else {
                *(unsigned int *)(ram_4131c + part * 0x11f) |= 1;
                VoiceParam_FullSetup(part);
                WaveSel_Rebuild_PartCaches(part, ram_41335[part * 0x11f], ram_41336[part * 0x11f]);
            }
        }
    }
}
