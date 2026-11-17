/* hd_r36_fix3v.c (helper h_fix3, lane_hd round 36): HDAE5000_VarInt_Encode and HDAE5000_VarInt_Decode
   (hdae5000_ui_display.s), with named variants.  Neither calls anything; the module lines are those of the C file
   they sit in (hd_r27_c2b.c).
   cc900-options: -Xr
   cc900-module: HDAE5000_Smf_SwapBytes32 HDAE5000_Smf_SwapBytes16 HDAE5000_Smf_CheckHeader
   cc900-module: HDAE5000_Delay_Loop HDAE5000_VGA_Port_Write
   cc900-name: VarEnc_b=HDAE5000_VarInt_Encode
   cc900-name: VarEnc_c=HDAE5000_VarInt_Encode
   cc900-name: VarEnc_d=HDAE5000_VarInt_Encode
   cc900-name: VarDec_b=HDAE5000_VarInt_Decode
   cc900-name: VarDec_c=HDAE5000_VarInt_Decode
   Run 116 (hd_r27_c2b.c) against the ROM:
   - VarInt_Encode differs only in its first loop.  The ROM moves the value out of XWA into XIX on entry, takes
     the buffer's address into XDE, and masks a 32-bit copy of the value in XWA with the long constant 0x7f before
     storing its low byte; the shift and the zero test work on XIX.  V4.23 left the value in XWA, took the
     buffer's address into XIX and masked a byte copy (bit 7 cleared in E).  The second loop, the last store and
     the return are the ROM's already.
       HDAE5000_VarInt_Encode: a local copy of the parameter (the README's "local copy" idiom), `v & 0x7f`.
       VarEnc_b: no copy; the mask is a long expression converted by a cast, `(unsigned char)(value & 0x7fL)`.
       VarEnc_c: no copy; `value % 128` and `value /= 128` (a remainder may not be narrowed to a byte).
       VarEnc_d: the local copy with `% 128` and `/= 128`.
   - VarInt_Decode differs in one instruction: the ROM shifts the accumulator left LOGICALLY (unsigned), V4.23
     arithmetically (signed `long r`).  All the rest is the ROM's.
       HDAE5000_VarInt_Decode: `unsigned long r`, the function still returns long (-1 on error).
       VarDec_b: the function returns unsigned long too, the error value written 0xffffffffL, the mask 0x7fU.
       VarDec_c: `long r` kept, the shift done on the unsigned value: `r = (unsigned long)r << 7`.
*/

long HDAE5000_VarInt_Encode(unsigned long value, unsigned char *out)
{
    unsigned char tmp[6];
    int n;
    int i;
    unsigned long v;

    v = value;
    n = 0;
    do {
        tmp[n] = v & 0x7f;
        v >>= 7;
        n++;
    } while (v != 0);
    for (i = 1; i < n; i++)
        out[n - i - 1] = tmp[i] | 0x80;
    out[n - 1] = tmp[0];
    return n;
}

long VarEnc_b(unsigned long value, unsigned char *out)
{
    unsigned char tmp[6];
    int n;
    int i;

    n = 0;
    do {
        tmp[n] = (unsigned char)(value & 0x7fL);
        value >>= 7;
        n++;
    } while (value != 0);
    for (i = 1; i < n; i++)
        out[n - i - 1] = tmp[i] | 0x80;
    out[n - 1] = tmp[0];
    return n;
}

long VarEnc_c(unsigned long value, unsigned char *out)
{
    unsigned char tmp[6];
    int n;
    int i;

    n = 0;
    do {
        tmp[n] = value % 128;
        value /= 128;
        n++;
    } while (value != 0);
    for (i = 1; i < n; i++)
        out[n - i - 1] = tmp[i] | 0x80;
    out[n - 1] = tmp[0];
    return n;
}

long VarEnc_d(unsigned long value, unsigned char *out)
{
    unsigned char tmp[6];
    int n;
    int i;
    unsigned long v;

    v = value;
    n = 0;
    do {
        tmp[n] = v % 128;
        v /= 128;
        n++;
    } while (v != 0);
    for (i = 1; i < n; i++)
        out[n - i - 1] = tmp[i] | 0x80;
    out[n - 1] = tmp[0];
    return n;
}

long HDAE5000_VarInt_Decode(unsigned char *p, unsigned char *count)
{
    int i;
    unsigned long r;
    unsigned char first;

    i = 0;
    r = 0;
    first = p[0];
    do {
        r += p[i] & 0x7f;
        if ((p[i] & 0x80) == 0) {
            *count = i + 1;
            return r;
        }
        i++;
        r <<= 7;
    } while ((i <= 4 || first <= 7) && i <= 5);
    return -1;
}

unsigned long VarDec_b(unsigned char *p, unsigned char *count)
{
    int i;
    unsigned long r;
    unsigned char first;

    i = 0;
    r = 0;
    first = p[0];
    do {
        r += p[i] & 0x7fU;
        if ((p[i] & 0x80) == 0) {
            *count = i + 1;
            return r;
        }
        i++;
        r <<= 7;
    } while ((i <= 4 || first <= 7) && i <= 5);
    return 0xffffffffL;
}

long VarDec_c(unsigned char *p, unsigned char *count)
{
    int i;
    long r;
    unsigned char first;

    i = 0;
    r = 0;
    first = p[0];
    do {
        r += p[i] & 0x7f;
        if ((p[i] & 0x80) == 0) {
            *count = i + 1;
            return r;
        }
        i++;
        r = (unsigned long)r << 7;
    } while ((i <= 4 || first <= 7) && i <= 5);
    return -1;
}
