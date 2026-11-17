/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/midi_dispatch_handlers.c (2026-11-16-40-p6-r8)
   sha256 443f509779a72f5a86c67ed9a7873444ecb44c4a755f1b9067a263e42c368c1d (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near SEQ_SONG_RECORD;
void MidiPkt_SetXferBlock_CurrentSong(struct xfer *x)
{
    x->end = (x->start = &SEQ_SONG_RECORD) + 0x800;
    x->size = 0x800;
}
