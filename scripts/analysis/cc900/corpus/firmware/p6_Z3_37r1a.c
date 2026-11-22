/* Probe round 37r1, lane_z3 (feedback plan step Z3, the djnz pool), form a: v10 routines with a counted loop
   (djnz) that otherwise look compiled.  Each function is one routine of notes/cc900-feedback-plan-2026-11-22/
   z3_pool.tsv; form a is the plainest C (for loops with the count as the controlling variable). */
/* cc900-module: FDC_CMD_SEND FDC_Set_Status SOME_DELAY */

extern unsigned char __tiny PA;
extern unsigned char __near FDC_ERROR_CODE;
extern void FDC_CMD_SEND(int);
extern void FDC_Set_Status(int);
extern void SOME_DELAY(int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned int __cdecl Strlen(char *);

/* storage/fdc_routines.s: set PA bit 3 (motor / drive enable), send command 254; on an error report status 49,
   else wait one SOME_DELAY(10) (a one-pass counted loop the compiler did not fold). */
void FDC_CMD_ENABLE(void)
{
    int i;

    PA |= 0x08;
    FDC_CMD_SEND(254);
    if (FDC_ERROR_CODE != 0) {
        FDC_Set_Status(49);
        return;
    }
    for (i = 1; i != 0; i--)
        SOME_DELAY(10);
}

/* sequencer/seq_step_routines.s: from block b down to 1, the first whose bit-7 test is set; 0 if none. */
unsigned int SeqStep_SearchBackward(unsigned int b)
{
    unsigned int i;

    i = b;
    do {
        if (PartCtrl_TestBit7(i) != 0)
            break;
    } while (--i != 0);
    return i;
}

/* audio/sprintf_core.s: strrchr(s, c). */
char * __cdecl Sprintf_StringLength(char *s, int c)
{
    unsigned int n;
    char *p;

    n = Strlen(s) + 1;
    p = s + n;
    for (; n != 0; n--)
        if (*--p == (char)c)
            return p;
    return 0;
}

/* audio/note_voice_mapping.s: the SOUND RAM image's word checksum (0x24b8 words from 0x1e0010), complemented. */
unsigned int SoundRam_ComputeChecksum(void)
{
    unsigned int *p;
    unsigned int n, s;

    p = (unsigned int *)0x1e0010;
    s = 0;
    for (n = 0x24b8; n != 0; n--)
        s += *p++;
    return ~s;
}

/* audio/note_voice_mapping.s: the same checksum, stored at image + 0x72a8. */
void SoundRam_WriteChecksum(void)
{
    unsigned char *b;
    unsigned int *p;
    unsigned int n, s;

    n = 0x24b8;
    b = (unsigned char *)0x1e0000;
    p = (unsigned int *)(b + 16);
    s = 0;
    for (; n != 0; n--)
        s += *p++;
    *(unsigned int *)(b + 29352) = ~s;
}

/* display/scoop_display.s: 15 words of two spaces from 0x0eca. */
void DisplayStr_BlankLineBuffer(void)
{
    unsigned int n;
    unsigned int *p;

    p = (unsigned int *)0x0eca;
    for (n = 15; n != 0; n--)
        *p++ = 0x2020;
}

/* sequencer/smf_tonegen_core.s: a busy wait, 0xc00 x 0x3c0 passes. */
void SeqPlay_DelayLoop_Outer(void)
{
    unsigned int i, j;

    for (i = 0xc00; i != 0; i--)
        for (j = 0x3c0; j != 0; j--)
            ;
}

/* demo/file_demo_proc.s: strncpy-like: copy s to d up to n bytes or s's terminator, then zero-fill the rest. */
void FileIO_CopyString_WriteNull(char *d, char *s, unsigned int n)
{
    while (n != 0 && *s != 0) {
        *d++ = *s++;
        n--;
    }
    while (n != 0) {
        *d++ = 0;
        n--;
    }
}
