/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2b.c (2026-11-16-33-p6-r2)
   sha256 b9efa2757706d71e6e9c9e909054c7167cfc9ddaea6d230749048ed7913a21f6 (tar-sha256); compiled at -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near LIVE_PANEL_BLOCK;
extern unsigned char __near ram_ffbe;
void MidiPkt_SetXferBlock_LivePanel(struct xfer *x)
{
    long n;
    unsigned char *p = &LIVE_PANEL_BLOCK;
    x->start = p;
    n = &ram_ffbe - p + 2;
    x->end = n + p;
    x->size = n;
}
