/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers.c (2026-11-16-33-p6-r2)
   sha256 8bbcc58e05679c0807d9857c85e581193e2af1cd771f11fc06ee6fcc3a4087f2 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near SEQ_SONG_RECORD;
void MidiPkt_SetXferBlock_CurrentSong(struct xfer *x)
{
    x->end = (x->start = &SEQ_SONG_RECORD) + 0x800;
    x->size = 0x800;
}
