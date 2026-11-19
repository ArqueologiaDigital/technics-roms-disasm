/* Functions of core/11_ringbuf_and_midi_dispatch.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41322[];
extern unsigned char ram_41335[];
extern unsigned char ram_41336[];
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void VoiceSlot_FullInit(int n);
void VoiceSlot_AltInit(int n);
void Voice_PortamentoTargets_SetAll(int n);

void DSP_VoiceState_Dispatch(int a, int b)
{
    unsigned char i;

    for (i = 0; i < 0x1a; i++) {
        if (ram_41336[i * 287] == 0x10 || ram_41336[i * 287] == 0x50) {
            WaveSel_Rebuild_PartCaches(i, ram_41335[i * 287], ram_41336[i * 287]);
            switch ((*(unsigned char **)&ram_41322[i * 287])[16] & 0xc0) {
            case 0:
            case 0xc0:
                VoiceSlot_FullInit(i);
                break;
            case 0x40:
                Voice_PortamentoTargets_SetAll(i);
                VoiceSlot_AltInit(i);
                break;
            case 0x80:
                break;
            }
        }
    }
}
