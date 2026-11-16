/* lane_sub helper B, round 6, form c: the tone-table ramp routines of core/06_voice_envelopes_and_channels.s that
   reach the depth loaders with calr (KN5000 sub-CPU payload v1.42).  Their calls extend the channel (extz) but
   not the depth byte, so the loaders are declared (int, unsigned char) here, apart from forms a / b which define
   them with two unsigned char parameters.
   cc900-module: Voice_LoadPitchTable_Ch Voice_LoadFilterTable_Ch Voice_LoadToneTable_Ch */

extern unsigned char Voice_ToneRampPitch_Curve[];
extern unsigned char Voice_ToneRampFilter_Curve[];
void Voice_LoadPitchTable_Ch(int ch, unsigned char depth);
void Voice_LoadFilterTable_Ch(int ch, unsigned char depth);
void Voice_LoadToneTable_Ch(int ch, unsigned char depth);

/* s[99] bit 4 = ramp finished, s[100] pitch step, s[101] filter step */
void Voice_ToneTableRamp_Down(unsigned char ch, unsigned char *s)
{
    unsigned char k;
    if (s[100] == 0) s[99] |= 0x10;
    else {
        --s[100];
        s[99] &= ~0x10;
        k = s[100] >> 1;
        Voice_LoadPitchTable_Ch(ch, Voice_ToneRampFilter_Curve[k]);
    }
    if (s[101] != 0) {
        --s[101];
        s[99] &= ~0x10;
        k = s[101] / 5;
        Voice_LoadFilterTable_Ch(ch, Voice_ToneRampFilter_Curve[k]);
        Voice_LoadToneTable_Ch(ch, Voice_ToneRampFilter_Curve[k]);
    }
}

/* the filter step: the largest k (from 25 down) whose filter-curve value the pitch-curve value reaches */
void Voice_ToneTableApply_Pitch(unsigned char ch, unsigned char *s)
{
    unsigned char l;
    unsigned char k;
    s[99] &= 0xe7;
    l = Voice_ToneRampPitch_Curve[s[100]];
    for (k = 0x19; l < Voice_ToneRampFilter_Curve[k]; k--)
        ;
    s[100] = k;
    Voice_LoadPitchTable_Ch(ch, Voice_ToneRampPitch_Curve[l]);
    l = s[101];
    l /= 6;
    k = l;
    l *= 5;
    s[101] = l;
    Voice_LoadFilterTable_Ch(ch, Voice_ToneRampFilter_Curve[k]);
    Voice_LoadToneTable_Ch(ch, Voice_ToneRampFilter_Curve[k]);
}
