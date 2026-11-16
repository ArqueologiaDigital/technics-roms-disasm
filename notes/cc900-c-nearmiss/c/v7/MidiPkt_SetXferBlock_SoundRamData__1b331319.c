/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers.c (2026-11-16-36-p6-staged-r4)
   sha256 1b3313195bff455e68f68c45dc85faeb5e9150181fdf7b12cfc6b56445eef01e (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_1e0000, MSP_SETTINGS__BASE_ADDR, ram_1e8820, ram_1e8b00;
extern unsigned char ram_1e0000;
void MidiPkt_SetXferBlock_SoundRamData(struct xfer *x)
{
    x->start = (unsigned char *)((long)&ram_1e0000 + 16);
    x->size = 0x729a;
    x->end = x->start + 0x729a;
}
