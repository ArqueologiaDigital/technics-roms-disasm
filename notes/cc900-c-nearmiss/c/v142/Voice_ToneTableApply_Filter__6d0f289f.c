/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AG_20c.c (2026-11-18-18-sub-r21a)
   sha256 6d0f289faaa16fba0697194cbc0fc6d03975f9e0f21a92c4e8410f5b4a9e9052 (tar-sha256); compiled at -Xr */
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
    t = r[101] / 5;
    i = t;
    r[101] = t * 6;
    Voice_LoadFilterTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
    Voice_LoadToneTable_Ch(ch, Voice_ToneRampFilter_Curve[i]);
}
