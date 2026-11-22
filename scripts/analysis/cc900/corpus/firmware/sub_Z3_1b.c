/* Probe round Z3-1 (lane_z3), form b: as form a, the halving as a division and the sum complemented in place. */

extern unsigned char *ram_4531c;

unsigned int DSP_WriteCount_Compute(void)
{
    unsigned int n;
    unsigned int *p;
    unsigned int s;

    n = 0x4970;
    n /= 2;
    p = (unsigned int *)(ram_4531c + 16);
    for (s = 0; n != 0; n--)
        s += *p++;
    s = ~s;
    return s;
}

void DSP_FillMemWords(unsigned int *p, unsigned int v, unsigned int n)
{
    do {
        *p = v;
        p++;
    } while (--n);
}
