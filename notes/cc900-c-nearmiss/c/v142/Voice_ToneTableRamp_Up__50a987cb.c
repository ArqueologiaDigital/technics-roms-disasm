/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17c.c (2026-11-16-126-sub-r17)
   sha256 50a987cbc6cdbc37c89132eff20ee2e3fdc579b48bf25a3767fa1b68170ec996 (name+funcs); compiled at -Xr */
extern unsigned char Voice_ToneRampPitch_Curve[];
extern unsigned char Voice_ToneRampFilter_Curve[];
extern void Voice_LoadPitchTable_All(int ch);
extern void Voice_LoadFilterTable_All(int ch);
extern void Voice_LoadToneTable_All(int ch);
void Voice_LoadPitchTable_Ch(int ch, char depth);
void Voice_LoadFilterTable_Ch(int ch, char depth);
void Voice_LoadToneTable_Ch(int ch, char depth);
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
