/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-30-p6-r1)
   sha256 8a7356886e18f7ab911e798723ccf50ecdd2436ab818c9ee86a2ecf0d3209eb9 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_bc68[], ram_bc64[], PANEL_PART_RT1;
void MidiChan_ClearStorageFields(void)
{
    ram_bc68[0] = 0xff;
    ram_bc68[1] = 0xff;
    ram_bc68[2] = 0xff;
    ram_bc64[0] = 0xff;
    ram_bc64[1] = 0xff;
    ram_bc64[2] = 0xff;
}
