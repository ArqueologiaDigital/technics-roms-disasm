/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_11a.c (2026-11-16-94-sub-r11)
   sha256 417738f3d62e20bf0e2a89fd727dcb7d7fab4dcb3644db259e9daf07323b4c99 (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern int __near ram_2940;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char Voice_AltNoteMap_Curve[];
extern unsigned char Voice_DepthMirror_Table[];
extern char Voice_FineTune_Curve[];
extern int Voice_Colour_LookupIndex(int a, int b);
void Voice_ComputePitch_Mono(unsigned char *v)
{
    char *s;
    unsigned int n;
    int p, t;
    s = *(char **)(v + 23);
    n = (unsigned int)v[12] & 0x7f;
    if ((ram_41343 & 1) || (unsigned char)s[7] == 0xe0) {
        t = Voice_AltNoteMap_Curve[n];
        p = t - 12;
    } else {
        if (ram_41343 & 2) {
            t = Voice_AltNoteMap_Curve[n];
            p = t - 12;
        }
        if (s[6] < 0) {
            p = Voice_Colour_LookupIndex(Voice_DepthMirror_Table[n], (unsigned char)s[7]) - 0xd0;
            p *= ~(int)s[6] + 1;
        } else {
            p = Voice_Colour_LookupIndex(n, (unsigned char)s[7]) - 0xd0;
            p *= s[6];
        }
        p >>= 5;
        p += 0xd8;
    }
    p += Voice_FineTune_Curve[*(unsigned int *)(v + 43) & 0x7f];
    p += (*(char **)(v + 15))[3];
    p += *(int *)(ToneDB_RootPtr + 224);
    p += ram_2940;
    *(int *)(v + 13) = p;
    *(unsigned int *)(v + 51) = 0;
}
