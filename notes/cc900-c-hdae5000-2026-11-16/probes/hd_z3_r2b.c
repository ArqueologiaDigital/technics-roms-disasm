/* Probe round z3-r2 (lane_z3), form b: HDAE5000_Lyrics_WriteVarLen retry, the shift tested with `!= 0` and
   `continue`, the count a register variable. */

int HDAE5000_Lyrics_WriteVarLen(unsigned long v, unsigned char *buf)
{
    register unsigned long x;
    register unsigned int i;
    register unsigned int n;

    x = v;
    for (i = 1; i < 5; i++) {
        if ((x >>= 7) != 0)
            continue;
        n = i;
        break;
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
