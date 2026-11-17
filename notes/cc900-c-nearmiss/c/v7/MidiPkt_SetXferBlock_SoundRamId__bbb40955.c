/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers.c (2026-11-16-40-p6-r8)
   sha256 bbb40955759a1b5e6bf2ce15d4a26d79eb43a2aab04e15fc2fbb3ada3efa3cd7 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_1e0000, MSP_SETTINGS__BASE_ADDR, ram_1e8820, ram_1e8b00;
void MidiPkt_SetXferBlock_SoundRamId(struct xfer *x)
{
    x->start = &ram_1e0000;
    x->size = 16;
    x->end = x->start + 16;
}
extern unsigned char ram_1e0000;
