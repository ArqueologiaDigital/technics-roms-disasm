/* Probe round 37r3, lane_z3 (feedback plan step Z3), form b: as form a with the pointer a register variable
   declared first and a 32-bit unused argument. */

void DisplayStr_BlankLineBuffer(void)
{
    register unsigned int *p;
    unsigned int n;

    n = 15;
    p = (unsigned int *)0x0eca;
    do
        *p++ = 0x2020;
    while (--n != 0);
}

void SeqPlay_DelayLoop_Outer(long unused)
{
    register unsigned int i;
    unsigned int j;

    i = 0xc00;
    do {
        j = 0x3c0;
        do
            ;
        while (--j != 0);
    } while (--i != 0);
}
