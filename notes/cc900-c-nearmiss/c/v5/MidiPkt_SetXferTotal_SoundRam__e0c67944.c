/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/midi_dispatch_handlers.c (2026-11-16-38-p6-r6)
   sha256 e0c67944a7fa4a7a4e90654190ad3b833645b13858f43f36290532234d38ad22 (tar-sha256); compiled at -O3 -XS -Xr
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
