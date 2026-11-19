/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_4m292b.c (2026-11-19-13-p6-r41)
   sha256 15335e1b9154d68ebf896b32fb55b030bad7a26c19baab775a65f2de034d6147 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char Midi_BankProgramTemplate[];
extern unsigned char __near ram_424;
extern void *__cdecl Malloc(unsigned int);
extern void *__cdecl Mem_Copy(void *, char *, unsigned int);
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
    Mem_Copy(p, Midi_BankProgramTemplate, 7);
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
