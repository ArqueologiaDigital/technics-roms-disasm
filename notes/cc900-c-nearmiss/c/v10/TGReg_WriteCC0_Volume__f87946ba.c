/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_5a.c (2026-11-16-40-p6-r8)
   sha256 f87946baf95982e11078f1ac542bfcae2d882549a42730c571b8582dbb6869d2 (tar-sha256); compiled at -O3 -XS -Xr */
struct tgd { unsigned char ch; unsigned char reg; unsigned char val; unsigned char mask; };
extern void MidiTG_WriteRegByDescriptor(struct tgd *);
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
