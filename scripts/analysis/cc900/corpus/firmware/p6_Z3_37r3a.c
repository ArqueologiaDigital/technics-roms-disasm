/* Probe round 37r3, lane_z3 (feedback plan step Z3), form a: last register-choice retries.  r1 / r2: +3 for both
   (BlankLineBuffer's pointer is XIX in the ROM, its value WA; DelayLoop's inner count HL).  Here each has an
   unused argument occupying XWA, as a wrapper-called routine might. */

void DisplayStr_BlankLineBuffer(int unused)
{
    unsigned int n;
    unsigned int *p;
    unsigned int v;

    n = 15;
    p = (unsigned int *)0x0eca;
    v = 0x2020;
    do
        *p++ = v;
    while (--n != 0);
}

void SeqPlay_DelayLoop_Outer(int unused, int unused2)
{
    unsigned int i, j;

    for (i = 0xc00; i != 0; i--)
        for (j = 0x3c0; j != 0; j--)
            ;
}
