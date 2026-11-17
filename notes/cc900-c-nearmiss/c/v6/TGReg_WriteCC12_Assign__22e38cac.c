/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers.c (2026-11-16-55-p6-r10)
   sha256 22e38cac52930a6b38b02f5f9b89a034e3990db25806a0101b12d678569f3790 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
