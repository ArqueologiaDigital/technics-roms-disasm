/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_15b.c (2026-11-16-100-p6-r19)
   sha256 7f95acf3745d575ececbdfdbd8d96ac3fe6d9f317e9c8d0e6638d65ff9f1acb9 (tar-sha256); compiled at -Xr */
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
