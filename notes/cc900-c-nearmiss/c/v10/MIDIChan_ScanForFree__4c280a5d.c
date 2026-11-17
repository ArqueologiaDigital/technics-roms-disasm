/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/accompaniment_engine.c (2026-11-16-40-p6-r8)
   sha256 4c280a5d9acc951dc889467c8cbe194c5422bdd08990b396a7ed2edd97739535 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
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
