/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/dsp_voice_params_ai_22a.c (2026-11-18-32-sub-r21g-staged)
   sha256 60f85914f1fed144b9fba7f85b0afb9e425a3d04cea8f6f4cf651bee755922de (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct r16 { unsigned char b[16]; };
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_41322[];
extern unsigned char ram_451c4[];
extern unsigned char *ram_452d0;
void DSP_SetCoeff_RouteComplex(unsigned char part, unsigned char sel)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char *rec;
    unsigned int x;
    unsigned int y;
    unsigned int f;
    unsigned int i;
    unsigned long off;
    register unsigned char *q;
    rec = (*(unsigned char **)(ram_41322 + (part) * 0x11f));
    x = rec[(int)sel * 2 + 39];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&rec[(int)sel * 2 + 39] + 1);
    y &= 31;
    f = *(unsigned char *)((unsigned long)&rec[(int)sel * 2 + 39] + 1);
    f &= 32;
    off = ToneDB_RootPtr[31];
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + off + ToneDB_RelBase);
    off = ToneDB_RootPtr[32];
    tbl = (unsigned char *)(ToneDB_RelBase + off);
    n = 13;
    switch (f) {
    case 0:
        for (i = 0; i < n; i++)
            ram_451c4[i + 6] = tbl[(unsigned long)d * 16 + i];
        break;
    case 0x20:
        for (i = 0; i < n; i++) {
            q = &ram_452d0[(int)sel * 80 + 19111];
            ram_451c4[i + 6] = q[i];
        }
        break;
    }
    ram_451c4[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];
    n++;
    ram_451c4[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_451c4[n + 6] = (unsigned char)(d >> 8);
    n++;
}
