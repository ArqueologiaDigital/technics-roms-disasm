/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_ic14.c (2026-11-16-99-sub-r13-idioms)
   sha256 f49171167d4f454df97ba6dd1e379979da5f2a4ba422a0dd51d06807f961cb78 (name+funcs); compiled at -Xr */
extern unsigned char Voice_ToneRampFilter_Curve[];
void Voice_LoadPitchTable_Ch(int ch, unsigned char depth);
void Voice_LoadFilterTable_Ch(int ch, unsigned char depth);
void Voice_LoadToneTable_Ch(int ch, unsigned char depth);
void Voice_ToneTableRamp_Down(unsigned char ch, unsigned char *s)
{
    unsigned char k;
    unsigned char d;
    if (s[100] == 0) s[99] |= 0x10;
    else {
        --s[100];
        s[99] &= ~0x10;
        k = s[100] >> 1;
        d = Voice_ToneRampFilter_Curve[k];
        Voice_LoadPitchTable_Ch(ch, d);
    }
    if (s[101] != 0) {
        --s[101];
        s[99] &= ~0x10;
        k = s[101] / 5;
        d = Voice_ToneRampFilter_Curve[k];
        Voice_LoadFilterTable_Ch(ch, d);
        d = Voice_ToneRampFilter_Curve[k];
        Voice_LoadToneTable_Ch(ch, d);
    }
}
