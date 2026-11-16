/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4b.c (2026-11-16-39-p6-r7)
   sha256 cd9f134746513c7c9c77d7c0d599b0c4008c48aed497a7f2cb2fa6c3e2f78376 (tar-sha256); compiled at -O3 -XS -Xr */
void Vga_WritePortShortDelay(unsigned int r, unsigned char v)
{
    unsigned int d = 0;
    unsigned char *p;
    do d++; while (d < 0x80);
    p = (unsigned char *)0x170000;
    p[r] = v;
}
