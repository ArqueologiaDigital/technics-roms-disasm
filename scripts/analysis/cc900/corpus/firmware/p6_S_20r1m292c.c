/* Phase 6, lane_p6 helper S, round 1 of 2026-11-20, module 292 (audio/dsp_config_sysex.s), form c: one-spot retry
   of MidiSysEx_BuildAndSend from p6_P_5m292c.c (run r43: +29, everything before matches, the template's two-word
   push included).  The spot: after Malloc's result is copied to XIZ (p), the ROM stores the frame copy (buf) from
   XIZ and tests XIZ; V4.23 stored and tested XHL, the call's result (`buf = p = Malloc(7)` assigns buf from the
   result).  Form c: `p = Malloc(7); buf = p; if (buf == 0)`, the copy tested.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqOut_WriteTimedBytes */

extern char Midi_BankProgramTemplate[];
extern unsigned char __near ram_424;
extern void *__cdecl Malloc(unsigned int);
extern char *__cdecl Mem_Copy(char *, char *, unsigned int);
extern void __cdecl Free(void *);
extern void __cdecl SeqOut_WriteTimedBytes(int n, unsigned char *p);
extern void MidiSysEx_BuildAndSend(unsigned char ch, unsigned char prog, int bank);

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
