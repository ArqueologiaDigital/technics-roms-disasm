/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char Voice_ToneRampPitch_Curve[];
extern unsigned char Voice_ToneRampFilter_Curve[];
extern void Voice_LoadPitchTable_All(int ch);
extern void Voice_LoadFilterTable_All(int ch);
extern void Voice_LoadToneTable_All(int ch);
void Voice_LoadPitchTable_Ch(int ch, char depth);
void Voice_LoadFilterTable_Ch(int ch, char depth);
void Voice_LoadToneTable_Ch(int ch, char depth);

/* cc900-module: Voice_LoadFilterTable_All Voice_LoadFilterTable_Ch Voice_LoadPitchTable_All Voice_LoadPitchTable_Ch Voice_LoadToneTable_All Voice_LoadToneTable_Ch */
void Voice_ToneTableRamp_Up(unsigned char ch, unsigned char *s)
{
    unsigned char k;
    if (s[100] >= 0x4f) {
        s[99] |= 8;
        Voice_LoadPitchTable_All(ch);
    } else {
        ++s[100];
        s[99] &= ~8;
        k = s[100];
        Voice_LoadPitchTable_Ch(ch, Voice_ToneRampPitch_Curve[k]);
    }
    if (s[101] >= 0x96) {
        Voice_LoadFilterTable_All(ch);
        Voice_LoadToneTable_All(ch);
    } else {
        ++s[101];
        s[99] &= ~8;
        k = s[101] / 6;
        Voice_LoadFilterTable_Ch(ch, Voice_ToneRampFilter_Curve[k]);
        Voice_LoadToneTable_Ch(ch, Voice_ToneRampFilter_Curve[k]);
    }
}
