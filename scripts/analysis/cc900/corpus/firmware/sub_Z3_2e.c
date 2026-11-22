/* Probe round Z3-2 (lane_z3), form e: DSP_WriteCount_Compute retry, the pointer declared first, then the sum,
   then the count. */

extern unsigned char *ram_4531c;

unsigned int DSP_WriteCount_Compute(void)
{
    unsigned int *p;
    unsigned int s;
    unsigned int n;

    n = 0x4970;
    n /= 2;
    p = (unsigned int *)(ram_4531c + 16);
    for (s = 0; n != 0; n--)
        s += *p++;
    return ~s;
}
