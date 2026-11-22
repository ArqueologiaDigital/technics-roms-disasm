/* Probe round Z3-2 (lane_z3), form c: DSP_WriteCount_Compute retry.  Run sub-z3-r1 (form b, -Xr) differs at +14
   only in the sum's register: V4.23 keeps it in HL, the ROM in DE (and complements it through WA).  Here the sum
   is declared first. */

extern unsigned char *ram_4531c;

unsigned int DSP_WriteCount_Compute(void)
{
    unsigned int s;
    unsigned int n;
    unsigned int *p;

    n = 0x4970;
    n /= 2;
    p = (unsigned int *)(ram_4531c + 16);
    for (s = 0; n != 0; n--)
        s += *p++;
    return ~s;
}
