/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m285.c (2026-11-16-103-p6-r20-staged)
   sha256 a838dc1d739d298f4972a677ad6b71ad2f360c4ef98b979050980824b8910fe7 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_bc7c;
extern unsigned char __near ram_bc80;
extern unsigned char __near ram_bc9a;
extern unsigned char __near ram_bc9c;
void MidiChan_SetStateMode(void)
{
    if (ram_bc7c & 0x40) ram_bc9a = 1;
    else ram_bc9a = 2;
    if (ram_bc9a == ram_bc9c) return;
    ram_bc80 |= 0x40;
    ram_bc9c = ram_bc9a;
}
