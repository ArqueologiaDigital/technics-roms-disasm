/* Functions of hdae5000_ui_display.s.  (hdae5000_lyrics_varlen_z3.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_lyrics_varlen_z3.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
int HDAE5000_Lyrics_WriteVarLen(unsigned long v, unsigned char *buf)
{
    unsigned long x;
    unsigned int i;
    unsigned int n;

    x = v;
    for (i = 1; i < 5; i++) {
        x >>= 7;
        if (x == 0) {
            n = i;
            break;
        }
    }
    x = v;
    for (i = n; i != 0; i--) {
        buf[i - 1] = x & 0x7f;
        x >>= 7;
        if (x <= 0x7f)
            return i;
        buf[i - 1] = buf[i - 1] | 0x80;
    }
    return -1;
}
