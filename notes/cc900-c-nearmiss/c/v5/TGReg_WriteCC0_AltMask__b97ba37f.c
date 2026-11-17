/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/midi_dispatch_handlers_m288_xs.c (2026-11-16-92-p6-r18)
   sha256 b97ba37f82ad5ee5bda4029eca9abb1a98773d10d43e6f97e44359a8dc6d8d76 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -XS -Xr */
struct tgd { unsigned char ch; unsigned char reg; unsigned char val; unsigned char mask; };
extern void MidiTG_WriteRegByDescriptor(struct tgd *);
void TGReg_WriteCC0_AltMask(void)
{
    struct tgd d;
    for (d.ch = 0; d.ch <= 15; d.ch++) {
        d.reg = 0;
        d.val = 0;
        d.mask = 0xff;
        MidiTG_WriteRegByDescriptor(&d);
        d.reg = 1;
        d.val = 0;
        d.mask = 0x7f;
        MidiTG_WriteRegByDescriptor(&d);
    }
    d.ch = 15;
    d.reg = 0;
    d.val = 0xf0;
    d.mask = 0xff;
    MidiTG_WriteRegByDescriptor(&d);
    d.ch = 15;
    d.reg = 1;
    d.val = 0;
    d.mask = 0x7f;
    MidiTG_WriteRegByDescriptor(&d);
}
