/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_ic08.c (2026-11-16-99-sub-r13-idioms)
   sha256 37133501e63e9132be880ab1bd34e36b2d55490fe5c2900ec8a1a478a40d2cf6 (name+funcs); compiled at -Xr */
extern unsigned char Voice_ToneRampFilter_Curve[];
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
