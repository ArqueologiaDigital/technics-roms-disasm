/* Probe round 37r1, lane_z3 (feedback plan step Z3, the djnz pool), form b: the same functions as form a with
   do-while / pre-decrement loop spellings and unsigned counters. */
/* cc900-module: FDC_CMD_SEND FDC_Set_Status SOME_DELAY */

extern unsigned char __tiny PA;
extern unsigned char __near FDC_ERROR_CODE;
extern void FDC_CMD_SEND(int);
extern void FDC_Set_Status(int);
extern void SOME_DELAY(int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned int __cdecl Strlen(char *);

void FDC_CMD_ENABLE(void)
{
    unsigned int i;

    PA |= 0x08;
    FDC_CMD_SEND(254);
    if (FDC_ERROR_CODE != 0)
        FDC_Set_Status(49);
    else
        for (i = 1; i; --i)
            SOME_DELAY(10);
}

unsigned int SeqStep_SearchBackward(unsigned int b)
{
    unsigned int i;

    for (i = b;;) {
        if (PartCtrl_TestBit7(i))
            break;
        if (--i == 0)
            break;
    }
    return i;
}

char * __cdecl Sprintf_StringLength(char *s, int c)
{
    unsigned int n;
    char *p;

    n = Strlen(s) + 1;
    p = s + n;
    if (n != 0) {
        do {
            if (*--p == (char)c)
                return p;
        } while (--n != 0);
    }
    return 0;
}

unsigned int SoundRam_ComputeChecksum(void)
{
    unsigned int *p;
    unsigned int n, s;

    n = 0x24b8;
    p = (unsigned int *)0x1e0010;
    s = 0;
    do
        s += *p++;
    while (--n != 0);
    return ~s;
}

void SoundRam_WriteChecksum(void)
{
    unsigned char *b;
    unsigned int *p;
    unsigned int n, s;

    n = 0x24b8;
    b = (unsigned char *)0x1e0000;
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

    n = 15;
    p = (unsigned int *)0x0eca;
    do
        *p++ = 0x2020;
    while (--n != 0);
}

void SeqPlay_DelayLoop_Outer(void)
{
    unsigned int i, j;

    i = 0xc00;
    do {
        j = 0x3c0;
        do
            ;
        while (--j != 0);
    } while (--i != 0);
}

void FileIO_CopyString_WriteNull(char *d, char *s, unsigned int n)
{
    for (; n != 0; n--) {
        if (*s == 0)
            break;
        *d++ = *s++;
    }
    for (; n != 0; n--)
        *d++ = 0;
}
