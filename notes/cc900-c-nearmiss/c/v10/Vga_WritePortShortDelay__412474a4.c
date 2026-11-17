/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3b.c (2026-11-16-37-p6-r5)
   sha256 412474a4bcb1b07706b807e204b3c008566145fa8f25b4beb61a0e0ac464ffd3 (tar-sha256); compiled at -O3 -Xr */
void Vga_WritePortShortDelay(unsigned int r, unsigned char v)
{
    unsigned int d;
    for (d = 0; d < 0x80; d++) ;
    ((unsigned char *)0x170000)[r] = v;
}
