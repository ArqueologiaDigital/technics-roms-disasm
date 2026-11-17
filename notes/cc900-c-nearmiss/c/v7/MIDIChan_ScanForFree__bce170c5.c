/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/accompaniment_engine.c (2026-11-16-40-p6-r8)
   sha256 bce170c5483988609e00354cd6ae65e733dfc4c8db216b7b36d6b26071fd3916 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_38fa;
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
        ram_38fa = 0;
    else
        ram_38fa = i;
}
