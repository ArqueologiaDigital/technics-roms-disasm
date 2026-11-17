/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/midi_dispatch_handlers.c (2026-11-16-38-p6-r6)
   sha256 429cfe28602b61900a641694fd6d0c64a92d390061dd94703531cfc9e0fc58cf (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char SEQ_SONG_SLOTS[];
void MidiPkt_SetXferBlock_SongSlots(struct xfer *x)
{
    x->end = (x->start = SEQ_SONG_SLOTS) + 0x5000;
    x->size = 0x5000;
}
