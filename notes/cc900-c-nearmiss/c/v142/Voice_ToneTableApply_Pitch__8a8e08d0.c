/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_envelopes_and_channels_ag_20a.c (2026-11-18-19-sub-r21b-staged)
   sha256 8a8e08d05c34548637e0bba8a75e6ebd4c79573af704ef7c8ae052bd4810a715 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char Voice_ToneRampPitch_Curve[];
extern unsigned char Voice_ToneRampFilter_Curve[];
extern void Voice_LoadPitchTable_Ch(int ch, char depth);
extern void Voice_LoadFilterTable_Ch(int ch, char depth);
extern void Voice_LoadToneTable_Ch(int ch, char depth);
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
