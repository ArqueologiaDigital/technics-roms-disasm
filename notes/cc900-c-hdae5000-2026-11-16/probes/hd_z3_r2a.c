/* Probe round z3-r2 (lane_z3), form a: HDAE5000_Lyrics_WriteVarLen retry.  Run hd-z3-r1 (form r1a, -Xr) differed
   at +7: the `(x >>= 7) == 0` test went through a copy, where the ROM tests the shift's own flags; the chunk count
   then took IY instead of IX.  Here the shift is its own statement. */

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
