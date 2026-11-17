/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2b.c (2026-11-16-33-p6-r2)
   sha256 b9efa2757706d71e6e9c9e909054c7167cfc9ddaea6d230749048ed7913a21f6 (tar-sha256); compiled at -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_1e0000;
void MidiPkt_SetXferBlock_SoundRamData(struct xfer *x)
{
    unsigned char *p = &ram_1e0000;
    p += 16;
    x->start = p;
    x->size = 0x729a;
    x->end = x->start + 0x729a;
}
