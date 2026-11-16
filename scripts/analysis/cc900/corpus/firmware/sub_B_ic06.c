/* lane_sub helper B, idiom probe class (c), spelling 06: prototype (int, unsigned int)
   Voice_ToneTableRamp_Down (core/06_voice_envelopes_and_channels.s, KN5000 sub-CPU payload v1.42): the ROM passes the
   depth byte to the loaders unextended (`ld c,(xbc+wa)`); only the declaration / argument spelling varies per file.
   cc900-module: Voice_LoadPitchTable_Ch Voice_LoadFilterTable_Ch Voice_LoadToneTable_Ch */

extern unsigned char Voice_ToneRampFilter_Curve[];
void Voice_LoadPitchTable_Ch(int ch, unsigned int depth);
void Voice_LoadFilterTable_Ch(int ch, unsigned int depth);
void Voice_LoadToneTable_Ch(int ch, unsigned int depth);

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
