/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4b.c (2026-11-16-39-p6-r7)
   sha256 cd9f134746513c7c9c77d7c0d599b0c4008c48aed497a7f2cb2fa6c3e2f78376 (tar-sha256); compiled at -O3 -XS -Xr */
extern int ram_25ea8;
extern unsigned int ram_272ce;
unsigned char FileIO_FormatName_Return(unsigned char a)
{
    unsigned int m;
    if (ram_25ea8 < 0 || ram_25ea8 >= 20 || a >= 10) return 0;
    m = (unsigned int)1 << a;
    return (unsigned char)((ram_272ce & m) == m);
}
