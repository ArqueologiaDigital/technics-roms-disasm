/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_envelopes_and_channels_ag_20a.c (2026-11-18-19-sub-r21b-staged)
   sha256 1a98951acac8447a3939fb071402e52b84d184d260654227be44ce166f528b6d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char Voice_ToneRampPitch_Curve[];
extern unsigned char Voice_ToneRampFilter_Curve[];
extern void Voice_LoadPitchTable_Ch(int ch, char depth);
extern void Voice_LoadFilterTable_Ch(int ch, char depth);
extern void Voice_LoadToneTable_Ch(int ch, char depth);
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
