/* Probe round Z3-2 (lane_z3), form d: DSP_WriteCount_Compute retry, the sum a register variable and the result a
   separate local. */

extern unsigned char *ram_4531c;

unsigned int DSP_WriteCount_Compute(void)
{
    unsigned int n;
    unsigned int *p;
    register unsigned int s;
    unsigned int r;

    n = 0x4970;
    n /= 2;
    p = (unsigned int *)(ram_4531c + 16);
    for (s = 0; n != 0; n--)
        s += *p++;
    r = ~s;
    return r;
}
