/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers.c (2026-11-16-36-p6-staged-r4)
   sha256 c7538b77a43309e07940c73eadae39d321fcda1012f04dbffba7301bc9f3a528 (tar-sha256); compiled at -O3 -XS -Xr
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
