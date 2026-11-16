/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/accompaniment_engine.c (2026-11-16-36-p6-staged-r4)
   sha256 882f54cba9ade7fa21eb4a9c666de6b3c042df1ad5a1cb269c90e9c18028bd3e (tar-sha256); compiled at -O3 -XS -Xr
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
