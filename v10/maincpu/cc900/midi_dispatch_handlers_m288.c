/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void MidiTG_WriteRegByDescriptor(unsigned char *);

void TGReg_WriteCC12_Assign(void)
{
    unsigned char d[4];
    for (d[0] = 0; d[0] <= 15; d[0]++) {
        d[1] = 0xc;
        d[2] = 0;
        d[3] = 0x10;
        MidiTG_WriteRegByDescriptor(d);
    }
}

void TGReg_WriteCC3_Expression(void)
{
    unsigned char d[4];
    d[1] = 3;
    d[2] = 0x64;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC10_KeyShift(void)
{
    unsigned char d[4];
    d[1] = 0xa;
    d[2] = 0x80;
    d[3] = 0xff;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC11_PartMode(void)
{
    unsigned char d[4];
    d[1] = 0xb;
    d[2] = 0x2;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC4_Pan(void)
{
    unsigned char d[4];
    d[1] = 0x4;
    d[2] = 0x0;
    d[3] = 0x8;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC4_Sustain(void)
{
    unsigned char d[4];
    d[1] = 0x4;
    d[2] = 0x0;
    d[3] = 0x40;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC5_Modulation(void)
{
    unsigned char d[4];
    d[1] = 0x5;
    d[2] = 0x0;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC7_Reverb(void)
{
    unsigned char d[4];
    d[1] = 0x7;
    d[2] = 0x28;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC8_Chorus(void)
{
    unsigned char d[4];
    d[1] = 0x8;
    d[2] = 0x40;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC9_Variation(void)
{
    unsigned char d[4];
    d[1] = 0x9;
    d[2] = 0x40;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}
