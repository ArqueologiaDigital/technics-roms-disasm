/* Probe round 37r2, lane_z3 (feedback plan step Z3, the djnz pool), form a: retries of run p6-z3-r1's near misses.
   r1: BlankLineBuffer / DelayLoop / ComputeChecksum / WriteChecksum +3 (register choice; the ROM's lda of the
   SOUND RAM address is the address of an extern array, as V4.23 writes it), Sprintf_StringLength +12 (the count
   is an int, the ROM indexes with (xiz+bc)).  New: Fill_memory_at_XWA_with_DE_words_of_BC_value (the djnz of the
   pool row Copy_DE_words_from_XBC_to_XWA). */
/* cc900-name: FillMemWordsXwaDeBc=Fill_memory_at_XWA_with_DE_words_of_BC_value */

extern unsigned int __cdecl Strlen(char *);
extern unsigned int ram_1e0010[];
extern unsigned char ram_1e0000[];

char * __cdecl Sprintf_StringLength(char *s, int c)
{
    int n;
    char *p;

    n = Strlen(s) + 1;
    p = s + n;
    for (; n != 0; n--)
        if (*--p == (char)c)
            return p;
    return 0;
}

unsigned int SoundRam_ComputeChecksum(void)
{
    unsigned int n;
    unsigned int *p;
    unsigned int s;

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
    unsigned int n;
    unsigned char *b;
    unsigned int *p;
    unsigned int s;

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

void SeqPlay_DelayLoop_Outer(void)
{
    register unsigned int j;
    register unsigned int i;

    i = 0xc00;
    do {
        j = 0x3c0;
        do
            ;
        while (--j != 0);
    } while (--i != 0);
}

void FillMemWordsXwaDeBc(unsigned int *p, unsigned int v, unsigned int n)
{
    do
        *p++ = v;
    while (--n != 0);
}
