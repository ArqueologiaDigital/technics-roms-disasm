/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2b.c (2026-11-16-33-p6-r2)
   sha256 6466b0db5cc304449e230b5c4768605e1ab3bae7d08d95327934985fddd8f094 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_3996;
void MIDIChan_ScanForFree(void)
{
    unsigned char *p;
    unsigned char i;
    p = (unsigned char *)0xf1a0;
    for (i = 1; i <= 0x11; i++) {
        if (*p == 0x10)
            break;
        p++;
    }
    if (i <= 0x10)
        ram_3996 = i;
    else
        ram_3996 = 0;
}
