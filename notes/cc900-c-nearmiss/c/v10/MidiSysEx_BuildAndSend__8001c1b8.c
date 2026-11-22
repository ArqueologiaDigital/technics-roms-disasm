/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r1m292c.c (2026-11-21-2-p6-r58)
   sha256 8001c1b808e1078a5de3f4ae63e78c2352ae34c29383005d4c9ffb64c2ca3ef9 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern char Midi_BankProgramTemplate[];
extern unsigned char __near ram_424;
extern void *__cdecl Malloc(unsigned int);
extern char *__cdecl Mem_Copy(char *, char *, unsigned int);
extern void __cdecl Free(void *);
extern void __cdecl SeqOut_WriteTimedBytes(int n, unsigned char *p);
void MidiSysEx_BuildAndSend(unsigned char ch, unsigned char prog, int bank)
{
    unsigned char *buf;
    int n;
    unsigned char *p;
    unsigned char *start;

    n = 2;
    p = (unsigned char *)Malloc(7);
    buf = p;
    if (buf == 0)
        return;
    Mem_Copy((char *)p, Midi_BankProgramTemplate, 7);
    start = p + 5;
    if (bank != -1) {
        *p |= ch & 0xf;
        buf[2] = bank >> 7;
        buf[4] = bank & 0x7f;
        start = buf;
        n = 7;
    }
    p[5] |= ch & 0xf;
    buf[6] = prog & 0x7f;
    SeqOut_WriteTimedBytes(n, start);
    ram_424 = 0;
    Free(buf);
}
