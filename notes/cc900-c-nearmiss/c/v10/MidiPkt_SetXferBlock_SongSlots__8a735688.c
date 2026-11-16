/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-30-p6-r1)
   sha256 8a7356886e18f7ab911e798723ccf50ecdd2436ab818c9ee86a2ecf0d3209eb9 (tar-sha256); compiled at -O3 -XS -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char SEQ_SONG_SLOTS[];
void MidiPkt_SetXferBlock_SongSlots(struct xfer *x)
{
    unsigned char *p = SEQ_SONG_SLOTS;
    x->start = p;
    x->end = p + 0x5000;
    x->size = 0x5000;
}
