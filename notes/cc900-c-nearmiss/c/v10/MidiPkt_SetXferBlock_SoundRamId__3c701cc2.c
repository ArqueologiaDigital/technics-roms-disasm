/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-32-p6-m18-olevels)
   sha256 3c701cc280ffa91c9be4bfde230be135727936b7adbcf85cb0819f84e269f11d (tar-sha256); compiled at -O2 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
void MidiPkt_SetXferBlock_SoundRamId(struct xfer *x)
{
    x->start = (unsigned char *)0x1e0000;
    x->size = 16;
    x->end = x->start + x->size;
}
