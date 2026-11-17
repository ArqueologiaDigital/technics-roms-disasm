/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers.c (2026-11-16-38-p6-r6)
   sha256 4ef1c90b4a28c88a39cf0adeee143c22bc508f3392b514db83520bbd149e8d2e (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near SEQ_SONG_RECORD;
void MidiPkt_SetXferBlock_CurrentSong(struct xfer *x)
{
    x->end = (x->start = &SEQ_SONG_RECORD) + 0x800;
    x->size = 0x800;
}
