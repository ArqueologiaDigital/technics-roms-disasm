/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_15a.c (2026-11-16-100-p6-r19)
   sha256 7caacf92b81c580e558ace02d13d4a4484a651c893c11e49cb579bb494e4fe60 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd1c;
extern unsigned char __near ram_bd36;
extern unsigned char __near ram_bd38;
void MidiChan_SetStateMode(void)
{
    unsigned char a;
    if (ram_bd18 & 0x40) {
        ram_bd36 = 1;
        a = 1;
    } else {
        ram_bd36 = 2;
        a = ram_bd36;
    }
    if (a == ram_bd38) return;
    ram_bd1c |= 0x40;
    ram_bd38 = ram_bd36;
}
