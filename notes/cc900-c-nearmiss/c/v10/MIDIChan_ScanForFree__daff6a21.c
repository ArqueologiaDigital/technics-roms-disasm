/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2a.c (2026-11-16-33-p6-r2)
   sha256 daff6a210ae1d585590cbca49a5d49ac10efb93aef3c1766c7663df3000edf26 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_3996;
void MIDIChan_ScanForFree(void)
{
    unsigned char *p;
    unsigned char i;
    p = (unsigned char *)0xf1a0;
    i = 1;
    do {
        if (*p == 0x10)
            break;
        p++;
        i++;
    } while (i <= 0x11);
    if (i > 0x10)
        ram_3996 = 0;
    else
        ram_3996 = i;
}
