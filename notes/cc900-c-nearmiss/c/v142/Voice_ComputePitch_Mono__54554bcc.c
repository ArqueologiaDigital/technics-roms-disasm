/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_12a.c (2026-11-16-97-sub-r12)
   sha256 54554bcc953685d087ad86d8a0c80cd2be017622a3fee998c309449b2972798a (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern int __near ram_2940;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char Voice_AltNoteMap_Curve[];
extern unsigned char Voice_DepthMirror_Table[];
extern char Voice_FineTune_Curve[];
extern int Voice_Colour_LookupIndex(int a, int b);
void Voice_ComputePitch_Mono(unsigned char *v)
{
    unsigned char *s;
    unsigned int n;
    int p, t;
    s = *(unsigned char **)(v + 23);
    n = (unsigned int)v[12] & 0x7f;
    if ((ram_41343 & 1) || s[7] == 0xe0) {
        t = Voice_AltNoteMap_Curve[n];
        p = t - 12;
    } else {
        if (ram_41343 & 2) {
            t = Voice_AltNoteMap_Curve[n];
            p = t - 12;
        }
        if (((char *)s)[6] < 0) {
            p = Voice_Colour_LookupIndex(Voice_DepthMirror_Table[n], s[7]) - 0xd0;
            p *= ~(int)(char)s[6] + 1;
        } else {
            p = Voice_Colour_LookupIndex(n, s[7]) - 0xd0;
            p *= (char)s[6];
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
