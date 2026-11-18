/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41322[];
extern unsigned char Voice_ToneRampPitch_Curve[];
extern unsigned char Voice_ToneRampFilter_Curve[];
extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
extern void Voice_LoadPitchTable_Ch(int ch, char depth);
extern void Voice_LoadFilterTable_Ch(int ch, char depth);
extern void Voice_LoadToneTable_Ch(int ch, char depth);
void Voice_ModWheel_Apply(unsigned char part, unsigned char val);
void Voice_ToneTableApply_Filter(unsigned char ch, unsigned char *r);
void Voice_ToneTableApply_Pitch(unsigned char ch, unsigned char *r);
void Voice_ModWheel_Apply(unsigned char part, unsigned char val);
void Voice_ToneTableApply_Filter(unsigned char ch, unsigned char *r);
void Voice_ToneTableApply_Pitch(unsigned char ch, unsigned char *r);

/* cc900-module: AudioChannel_Dispatch Voice_LoadFilterTable_Ch Voice_LoadPitchTable_Ch Voice_LoadToneTable_Ch Voice_ToneTableApply_Filter Voice_ToneTableApply_Pitch */
void Voice_ModWheel_Apply(unsigned char part, unsigned char val)
{
    unsigned char *pr;
    unsigned int i;
    switch ((*(unsigned char **)(ram_41322 + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, *(unsigned char **)(ram_41322 + (int)part * 287) + ((unsigned long)i * 3 + 0x17));
        break;
    case 0x80:
        pr = *(unsigned char **)(ram_41322 + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, val, pr + ((unsigned long)i * 3 + 0x15));
        break;
    }
}

void Voice_ToneTableApply_Filter(unsigned char ch, unsigned char *r)
{
    unsigned char i;
    unsigned char t;
    r[99] &= 0xe7;
    t = Voice_ToneRampFilter_Curve[r[100] >> 1];
    for (i = 0; t > Voice_ToneRampPitch_Curve[i]; i++)
        ;
    r[100] = i;
    Voice_LoadPitchTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
    t = r[101];
    t /= 5;
    i = t;
    t *= 6;
    r[101] = t;
    Voice_LoadFilterTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
    Voice_LoadToneTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
}

void Voice_ToneTableApply_Pitch(unsigned char ch, unsigned char *r)
{
    unsigned char i;
    unsigned char t;
    r[99] &= 0xe7;
    t = Voice_ToneRampPitch_Curve[r[100]];
    for (i = 25; t < Voice_ToneRampFilter_Curve[i]; i--)
        ;
    r[100] = i;
    Voice_LoadPitchTable_Ch(ch, Voice_ToneRampPitch_Curve[t]);
    t = r[101];
    t /= 6;
    i = t;
    t *= 5;
    r[101] = t;
    Voice_LoadFilterTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
    Voice_LoadToneTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
}
