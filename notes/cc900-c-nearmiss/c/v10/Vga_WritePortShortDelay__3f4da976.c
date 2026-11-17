/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3a.c (2026-11-16-37-p6-r5)
   sha256 3f4da9760305cc181a03f903f54adec3de046408b1665d02d1fe4258e884294e (tar-sha256); compiled at -O3 -Xr */
void Vga_WritePortShortDelay(unsigned int r, unsigned char v)
{
    unsigned int d = 0;
    do d++; while (d < 0x80);
    *(unsigned char *)(r + 0x170000L) = v;
}
