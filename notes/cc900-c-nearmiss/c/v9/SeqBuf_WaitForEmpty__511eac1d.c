/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_dispatch_handlers_m285.c (2026-11-16-68-p6-r12)
   sha256 511eac1d867022aa1f418740d9cfcda07734e16af66f2282b24b3a5ae04de7be (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int SeqBuf_MidiOut_CheckEmpty(void);
void SeqBuf_WaitForEmpty(void)
{
    unsigned int n = 0xfffe;
    do {
        if (SeqBuf_MidiOut_CheckEmpty() == 0) return;
    } while (n--);
}
