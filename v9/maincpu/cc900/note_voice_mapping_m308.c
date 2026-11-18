/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void __cdecl Itoa_Safe(int value, char *buf, int radix);

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
