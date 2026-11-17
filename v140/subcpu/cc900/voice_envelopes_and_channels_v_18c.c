/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_412f7;
extern int __near ram_2940;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char Voice_AltNoteMap_Curve[];
extern unsigned char Voice_DepthMirror_Table[];
extern char Voice_FineTune_Curve[];
extern int Voice_Colour_LookupIndex(int a, int b);
extern int Voice_Colour_ClampUpper(int a, int b, int c, int d, int e);
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q);
int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q);

/* cc900-module: Voice_Colour_ClampUpper Voice_Colour_LookupIndex Voice_InterpolateNoteCurve Voice_InterpolatePanCurve */
void Voice_ComputePitch(unsigned char *v)
{
    unsigned char *s;
    int q;
    unsigned int c;
    unsigned int n;
    int p, t;
    s = *(unsigned char **)(v + 23);
    n = (unsigned int)v[12];
    if (n & 0x80) *(unsigned int *)(v + 1) |= 0x800;
    n &= 0x7f;
    if ((ram_412f7 & 1) || s[25] == 0xe0) {
        t = Voice_AltNoteMap_Curve[n];
        p = t - 12;
    } else if (ram_412f7 & 2) {
        t = Voice_AltNoteMap_Curve[n];
        p = t - 12;
    } else {
        if (((char *)s)[24] < 0) {
            n = Voice_DepthMirror_Table[n];
            c = s[25];
            q = Voice_Colour_LookupIndex(n, c) - 0xd0;
            q *= ~(int)(char)s[24] + 1;
        } else {
            c = s[25];
            q = Voice_Colour_LookupIndex(n, c) - 0xd0;
            q *= (char)s[24];
        }
        q >>= 5;
        p = q + 0xd8;
    }
    p += Voice_Colour_ClampUpper(*(int *)(v + 8), s[26], s[27], s[28], (char)s[29]);
    p += Voice_FineTune_Curve[*(unsigned int *)(v + 43) & 0x7f];
    p += (*(char **)(v + 15))[3];
    p += *(int *)(ToneDB_RootPtr + 224);
    p += ram_2940;
    p += Voice_InterpolatePanCurve(v, s);
    p += Voice_InterpolateNoteCurve(v, s);
    if (s[0] & 0x80) p += (*(unsigned char **)(v + 35))[286];
    *(int *)(v + 13) = p;
    *(unsigned int *)(v + 51) = 0;
}
