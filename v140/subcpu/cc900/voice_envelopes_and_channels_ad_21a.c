/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_43042[][0x47];
extern unsigned int ram_45180[];
extern void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);
extern void Voice_WriteChPanShift2(unsigned char *v, int flag);
extern void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);

/* cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
/* cc900-module: ToneGen_WriteVoice_Reg21_Reg22 */
void AudioChannel_AllVoices_UpdVar3(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    unsigned char *f;
    base = ram_43042;
    list += 5;
    q = list;
    if (*list < 0x40) {
        do {
            v = base[*q];
            switch (*(unsigned int *)(v + 1) & 0x3c) {
            case 4:
            case 0x20:
            case 8:
                break;
            case 0x10:
                f = *(unsigned char **)(v + 19);
                Voice_Calc_LevelPair_FixedAtk(v);
                Voice_WriteChPanShift2(v, 0);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_45180);
                break;
            }
        } while (*++q < 0x40);
    }
}
