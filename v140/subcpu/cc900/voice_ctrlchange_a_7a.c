/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
struct pkt *Voice_Query_AllChannels(void);
void Voice_SetMasterTune(int a);
void Voice_SetKeyShiftEnable(int a);
void Pitch_Refresh_Sounding_Voices(struct pkt *q);

/* cc900-module: Pitch_Refresh_Sounding_Voices Voice_SetKeyShiftEnable Voice_SetMasterTune */
void Voice_SetKeyShiftEnableAndApply(unsigned char a)
{
    Voice_SetKeyShiftEnable(a);
    Pitch_Refresh_Sounding_Voices(Voice_Query_AllChannels());
}

void Voice_SetMasterTuneAndApply(char a)
{
    Voice_SetMasterTune(a);
    Pitch_Refresh_Sounding_Voices(Voice_Query_AllChannels());
}
