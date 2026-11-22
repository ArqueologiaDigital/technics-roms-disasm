/* Probe round 37r2, lane_z3 (feedback plan step Z3), form b: as form a with the locals declared in other orders
   (register choice is where r1 differed) and Sprintf_StringLength's count incremented in place. */

extern unsigned int __cdecl Strlen(char *);
extern unsigned int ram_1e0010[];
extern unsigned char ram_1e0000[];

char * __cdecl Sprintf_StringLength(char *s, int c)
{
    char *p;
    int n;

    n = Strlen(s);
    n++;
    p = s + n;
    if (n != 0)
        do {
            if (*--p == (char)c)
                return p;
        } while (--n != 0);
    return 0;
}

unsigned int SoundRam_ComputeChecksum(void)
{
    unsigned int s;
    unsigned int *p;
    unsigned int n;

    n = 0x24b8;
    p = ram_1e0010;
    s = 0;
    do
        s += *p++;
    while (--n != 0);
    return ~s;
}

void SoundRam_WriteChecksum(void)
{
    unsigned int s;
    unsigned int *p;
    unsigned char *b;
    unsigned int n;

    n = 0x24b8;
    b = ram_1e0000;
    p = (unsigned int *)(b + 16);
    s = 0;
    do
        s += *p++;
    while (--n != 0);
    *(unsigned int *)(b + 29352) = ~s;
}

void DisplayStr_BlankLineBuffer(void)
{
    register unsigned int *p;
    register unsigned int v;
    register unsigned int n;

    n = 15;
    p = (unsigned int *)0x0eca;
    v = 0x2020;
    do
        *p++ = v;
    while (--n != 0);
}

void SeqPlay_DelayLoop_Outer(void)
{
    unsigned int i;
    unsigned int j;

    for (i = 0xc00; i != 0; i--) {
        j = 0x3c0;
        do
            ;
        while (--j);
    }
}
