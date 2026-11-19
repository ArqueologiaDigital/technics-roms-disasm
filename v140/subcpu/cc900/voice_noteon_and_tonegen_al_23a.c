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
extern unsigned char ram_41322[];
extern unsigned char ram_41326[];
extern unsigned char ram_41335[];
extern unsigned char ram_41336[];
extern void Voice_NoteState_Clear(int);
extern void Voice_SetLFO_ActiveFlag(int);
extern void WaveSel_Rebuild_PartCaches(int, int, int);
extern void VoiceSlot_FullInit(int);
extern void VoiceSlot_AltInit(int);

void Voice_Part_SetStateAndReinit(unsigned char part, unsigned char c)
{
    if ((*(unsigned int *)&ram_4131c[part * 0x11f] & 3) == 0)
        return;
    if (c == 0) {
        *(unsigned int *)&ram_4131c[part * 0x11f] &= 0xfffe;
        *(unsigned int *)&ram_4131c[part * 0x11f] |= 2;
    } else {
        *(unsigned int *)&ram_4131c[part * 0x11f] &= 0xfffd;
        *(unsigned int *)&ram_4131c[part * 0x11f] |= 1;
    }
    *(unsigned int *)&ram_4131c[part * 0x11f] |= 4;
    Voice_NoteState_Clear(part);
    Voice_SetLFO_ActiveFlag(part);
    WaveSel_Rebuild_PartCaches(part, ram_41335[part * 287], ram_41336[part * 287]);
    if ((*(unsigned char **)&ram_41322[part * 287])[93] & 0x80)
        *(unsigned int *)&ram_41326[part * 0x11f] |= 0x4000;
    else
        *(unsigned int *)&ram_41326[part * 0x11f] &= 0xbfff;
    switch ((*(unsigned char **)&ram_41322[part * 287])[16] & 0xc0) {
    case 0:
    case 0xc0:
        VoiceSlot_FullInit(part);
        break;
    case 0x40:
        VoiceSlot_AltInit(part);
        break;
    case 0x80:
        break;
    }
}
