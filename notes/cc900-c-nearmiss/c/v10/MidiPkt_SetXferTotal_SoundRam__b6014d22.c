/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/midi_dispatch_handlers.c (2026-11-16-36-p6-staged-r4)
   sha256 b6014d226e19011512d12414f6c00efcd128c4d2f07167045281c16915ce7163 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_1e0000, MSP_SETTINGS__BASE_ADDR, ram_1e8820, ram_1e8b00;
void MidiPkt_SetXferTotal_SoundRam(struct xfer *x)
{
    x->start = &ram_1e0000;
    x->size = 0x72aa;
    x->end = x->start + 0x72aa;
}
extern unsigned char ram_1e0000;
