/* FORM B of p6_I_2m308a.c: the value copied into an unsigned local v after the radix check.  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 2, module 308 (the runtime library in audio/note_voice_mapping.s), form a.  New.
   Itoa_Safe(value, buf, radix) (__cdecl: all three on the stack, value lowest): radix outside 2..36 gives "";
   otherwise the digits are built backwards in an 18-byte frame buffer (lowercase letters past '9': += 0x27), with a
   '-' only for a negative value in radix 10, and copied to buf with Mem_Copy: tmp + 18 - p bytes, the digits and
   the terminator at tmp[17] (the length pushed as a word).
   Read from the hand assembly: buf in XHL, the sign flag in IX, the radix in BC, the value in QBC (unsigned
   division: extz + div xwa,de), the buffer base in XIZ and the digit pointer in XIY.
   Form b: the value through an unsigned local. */

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
