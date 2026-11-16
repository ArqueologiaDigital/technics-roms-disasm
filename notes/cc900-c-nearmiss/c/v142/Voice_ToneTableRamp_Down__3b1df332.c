/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_ic16.c (2026-11-16-99-sub-r13-idioms)
   sha256 3b1df332b20c9169e61a02fa4d7de419d4c330051fb91790ab888179490c7648 (name+funcs); compiled at -Xr */
extern unsigned char Voice_ToneRampFilter_Curve[];
void Voice_LoadPitchTable_Ch();
void Voice_LoadFilterTable_Ch();
void Voice_LoadToneTable_Ch();
void Voice_ToneTableRamp_Down(unsigned char ch, unsigned char *s)
{
    unsigned char k;
    if (s[100] == 0) s[99] |= 0x10;
    else {
        --s[100];
        s[99] &= ~0x10;
        k = s[100] >> 1;
        Voice_LoadPitchTable_Ch(ch, (unsigned char)Voice_ToneRampFilter_Curve[k]);
    }
    if (s[101] != 0) {
        --s[101];
        s[99] &= ~0x10;
        k = s[101] / 5;
        Voice_LoadFilterTable_Ch(ch, (unsigned char)Voice_ToneRampFilter_Curve[k]);
        Voice_LoadToneTable_Ch(ch, (unsigned char)Voice_ToneRampFilter_Curve[k]);
    }
}
