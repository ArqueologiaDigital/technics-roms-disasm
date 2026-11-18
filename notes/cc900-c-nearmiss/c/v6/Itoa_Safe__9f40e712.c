/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/note_voice_mapping_m308.c (2026-11-18-33-p6-r37)
   sha256 9f40e712c84601d7b76b714ec00c6b3baeec909ef58c2110c6496dd53439794b (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
void __cdecl Itoa_Safe(int value, char *buf, int radix)
{
    char tmp[18];
    char *p;
    int neg;
    unsigned int v;

    neg = 0;
    if (radix < 2 || radix > 36) {
        *buf = 0;
        return;
    }
    v = value;
    tmp[17] = 0;
    p = &tmp[16];
    if (radix == 10 && (int)v < 0) {
        neg = 1;
        v = -v;
    }
    for (;;) {
        *p = v % radix + '0';
        if (*p > '9')
            *p += 0x27;
        v /= radix;
        if (v == 0)
            break;
        p--;
    }
    if (neg)
        *--p = '-';
    Mem_Copy(buf, p, tmp + 18 - p);
}
