/* lane_p6 round 4 (2026-11-19): p6_I_5m292a.c (r37: +35, Xr).  The ROM pushes the template's address to Mem_Copy as
   two words (@hi16 / @lo16), as V4.23 does for the `char[]` strings of FileIO_ParsePathComponents; V4.23 wrote lda +
   push for this `unsigned char[]`.  Form a: the template declared `char[]`; form b: Mem_Copy's source `char *`.
   Phase 6, lane_p6 helper I, round 5, module 292 (audio/dsp_config_sysex.s), form a.  New.
   MidiSysEx_BuildAndSend(ch, prog, bank): copies the 7-byte template Midi_BankProgramTemplate (B0 00 00 20 00 C0 00)
   into a Malloc'd buffer, sets the channel and program (and, when bank != -1, the bank select MSB / LSB, sending
   all 7 bytes; else only the 2-byte program change at +5) and sends it with SeqOut_WriteTimedBytes (__cdecl:
   the count is its first stack argument), then clears 0x424 and frees the buffer.
   Read from the hand assembly: the buffer held twice (XIZ for the first statements, the frame +4 for the rest:
   `buf = p = Malloc(7)`), the count (+8) and the parameters in the frame, p + 5 computed once into XBC and copied
   as the start (-O3 CSE), `prog & 0x7f` as res 7.  Form b: the double assignment the other way round (p = buf = ...). */
/* cc900-module: SeqOut_WriteTimedBytes */

extern char Midi_BankProgramTemplate[];
extern unsigned char __near ram_424;
extern void *__cdecl Malloc(unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
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
