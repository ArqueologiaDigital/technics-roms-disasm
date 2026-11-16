/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -XS -Xr
*/

struct tgd { unsigned char ch; unsigned char reg; unsigned char val; unsigned char mask; };
extern void MidiTG_WriteRegByDescriptor(struct tgd *);
extern void TGReg_WriteCC0_AltMask(void);
extern void TGReg_WriteCC0_Volume(void);

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

void TGReg_WriteCC0_Volume(void)
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
    d.val = 0;
    d.mask = 0xff;
    MidiTG_WriteRegByDescriptor(&d);
    d.ch = 15;
    d.reg = 1;
    d.val = 0x78;
    d.mask = 0x7f;
    MidiTG_WriteRegByDescriptor(&d);
}
