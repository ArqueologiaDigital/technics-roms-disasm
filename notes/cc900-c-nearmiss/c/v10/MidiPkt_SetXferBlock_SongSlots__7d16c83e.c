/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-31-p6-r1b)
   sha256 7d16c83e6f1cf5e299730f8d1d1afaeca30c78536fe0c0f5702fb6c24ee9316d (tar-sha256); compiled at -O3 -XS -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char SEQ_SONG_SLOTS[];
void MidiPkt_SetXferBlock_SongSlots(struct xfer *x)
{
    x->end = (x->start = SEQ_SONG_SLOTS) + 0x5000;
    x->size = 0x5000;
}
