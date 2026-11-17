/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers_m285.c (2026-11-16-103-p6-r20-staged)
   sha256 6a07d0360a641f9079dee2f50acdaac6f2cebf4811bfd28675de5111c025e972 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_bc58;
extern unsigned char __near ram_bc5c;
extern unsigned char __near ram_bc76;
extern unsigned char __near ram_bc78;
void MidiChan_SetStateMode(void)
{
    if (ram_bc58 & 0x40) ram_bc76 = 1;
    else ram_bc76 = 2;
    if (ram_bc76 == ram_bc78) return;
    ram_bc5c |= 0x40;
    ram_bc78 = ram_bc76;
}
