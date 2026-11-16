/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_6c.c (2026-11-16-73-sub-r6)
   sha256 1436c0167ca865fd96c0b3ab1de1827a7123f835a7b393d992b04dd9cdefb00e (name+funcs); compiled at -Xr */
extern unsigned char Voice_ToneRampFilter_Curve[];
void Voice_LoadPitchTable_Ch(int ch, unsigned char depth);
void Voice_LoadFilterTable_Ch(int ch, unsigned char depth);
void Voice_LoadToneTable_Ch(int ch, unsigned char depth);
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
