/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_22c.c (2026-11-18-29-sub-r21f)
   sha256 aa65228827b5c13d4928aa081d6d0eccf2afdbc117c3d98aab0a4910a2ba5af8 (tar-sha256); compiled at -Xr */
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
void DSP_SetVoiceCoefficients(unsigned char part, unsigned char sel, unsigned char *out)
{
    unsigned int n;
    unsigned int i;
    register unsigned char *s = 0;
    unsigned long off = 0;
    unsigned char *rec;
    unsigned int x;
    unsigned int y;
    unsigned int h;

    rec = ToneDB_Find_ToneRecord(ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
    x = rec[(int)sel * 2 + 0x27];
    y = *(unsigned char *)((unsigned long)&rec[(int)sel * 2 + 0x27] + 1);
    switch (y & 0x20) {
    case 0:
        x &= 0x7f;
        h = y & 0x1f;
        switch (y & 0xc0) {
        case 0x00:
        case 0x40:
        case 0x80:
        case 0xc0:
            off = ToneDB_RootPtr[31];
            break;
        }
        x = *(unsigned long *)((unsigned long)(((h << 7) + x) * 2) + off + ToneDB_RelBase);
        off = ToneDB_RootPtr[44];
        s = (unsigned char *)(ToneDB_RelBase + off);
        s += x * 10;
        break;
    case 0x20:
        s = ToneDB_Find_SubToneRecord(rec, sel, 0xff);
        break;
    }
    n = 10;
    for (i = 0; i < n; i++) *out++ = *s++;
}
