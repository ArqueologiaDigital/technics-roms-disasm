/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers.c (2026-11-16-55-p6-r10)
   sha256 22e38cac52930a6b38b02f5f9b89a034e3990db25806a0101b12d678569f3790 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
void SeqBuf_WaitForEmpty(void)
{
    unsigned int n = 0xfffe;
    do {
        if (SeqBuf_MidiOut_CheckEmpty() == 0) return;
    } while (n--);
}
