/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_22a.c (2026-11-18-29-sub-r21f)
   sha256 f1667cac05ec896d30235087cc0a76bcfed9f9fea2e4a484286b1e79967f607f (tar-sha256); compiled at -Xr */
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
unsigned int DSP_VoiceParam_Dispatch(unsigned int a, unsigned int b, unsigned char *d)
{
    unsigned int n, i;
    unsigned char *s;
    unsigned int h;
    unsigned long off;

    switch (b & 0x20) {
    case 0:
        a &= 0x7f;
        h = b & 0x1f;
        switch (b & 0xc0) {
        case 0:
        case 0x40:
        case 0x80:
        case 0xc0:
            off = ToneDB_RootPtr[31];
            break;
        }
        b = *(unsigned long *)(((h << 7) + a) * 2 + off + ToneDB_RelBase);
        off = ToneDB_RootPtr[32];
        off = ToneDB_RelBase + off;
        s = (unsigned char *)off + (unsigned long)b * 16;
        break;
    case 0x20:
        s = ToneDB_Find_ToneRecord(a, b);
        break;
    }
    n = 13;
    for (i = 0; i < n; i++) *d++ = s[i];
    return n;
}
