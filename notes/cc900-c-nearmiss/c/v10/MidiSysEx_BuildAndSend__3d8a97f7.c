/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_5m292c.c (2026-11-19-19-p6-r43)
   sha256 3d8a97f735d5e4049425dc709cf49c67faac16f319fe01a10e0a7ff90e09ff12 (tar-sha256); compiled at -O3 -Xr */
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
    buf = p = (unsigned char *)Malloc(7);
    if (p == 0)
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
