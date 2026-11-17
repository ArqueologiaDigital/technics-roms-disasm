/* Functions of hdae5000_ui_display.s.  (hdae5000_varint.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_varint.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: VarEnc_d=HDAE5000_VarInt_Encode
   cc900-module: HDAE5000_Smf_SwapBytes32 HDAE5000_Smf_SwapBytes16 HDAE5000_Smf_CheckHeader
   cc900-module: HDAE5000_Delay_Loop HDAE5000_VGA_Port_Write
*/
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
