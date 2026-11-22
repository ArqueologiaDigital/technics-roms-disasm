/* Probe round z3-r1 (lane_z3, feedback plan step Z3, the djnz pool), form a: HDAE5000_Lyrics_WriteVarLen of
   hdae5000/hdae5000_ui_display.s, the variable-length-number encoder.  Count the 7-bit chunks of v (at most 4
   tested; n is left unset when none of 1..4 suffices), then write them MSB-first to buf, each with bit 7 set
   unless it is the last; returns the remaining count when the rest fits 7 bits, else -1. */

int HDAE5000_Lyrics_WriteVarLen(unsigned long v, unsigned char *buf)
{
    unsigned long x;
    unsigned int i;
    unsigned int n;

    x = v;
    for (i = 1; i < 5; i++) {
        if ((x >>= 7) == 0) {
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
