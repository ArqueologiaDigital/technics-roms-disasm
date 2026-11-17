/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_dispatch_handlers.c (2026-11-16-40-p6-r8)
   sha256 c8506d3b1427959e38673461679326677060071b4d9806189c04338306408d18 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char SEQ_SONG_SLOTS[];
void MidiPkt_SetXferBlock_SongSlots(struct xfer *x)
{
    x->end = (x->start = SEQ_SONG_SLOTS) + 0x5000;
    x->size = 0x5000;
}
