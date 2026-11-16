/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_dispatch_handlers_m285.c (2026-11-16-103-p6-r20-staged)
   sha256 91fe6d1f34966876ba7754418eee3458abf1937ee25e58f5d0ef6a20c1f8943b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd1c;
extern unsigned char __near ram_bd36;
extern unsigned char __near ram_bd38;
void MidiChan_SetStateMode(void)
{
    if (ram_bd18 & 0x40) ram_bd36 = 1;
    else ram_bd36 = 2;
    if (ram_bd36 == ram_bd38) return;
    ram_bd1c |= 0x40;
    ram_bd38 = ram_bd36;
}
