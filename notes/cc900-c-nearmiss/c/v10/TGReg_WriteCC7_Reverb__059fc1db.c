/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_8a.c (2026-11-16-53-p6-r11)
   sha256 059fc1dbc74e38faafb386fe8d5405b2a2d3d26241e37ac23ba5310d1dcc5b81 (tar-sha256); compiled at -O3 -XS -Xr */
extern void MidiTG_WriteRegByDescriptor(unsigned char *);
void TGReg_WriteCC7_Reverb(void)
{
    unsigned char d[4];
    d[1] = 0x7;
    d[2] = 0x28;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}
