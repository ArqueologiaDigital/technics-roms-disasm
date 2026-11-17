/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_dispatch_handlers.c (2026-11-16-38-p6-r6)
   sha256 429cfe28602b61900a641694fd6d0c64a92d390061dd94703531cfc9e0fc58cf (tar-sha256); compiled at -O3 -XS -Xr
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
