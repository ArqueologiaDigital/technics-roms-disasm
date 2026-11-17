/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4b.c (2026-11-16-39-p6-r7)
   sha256 cd9f134746513c7c9c77d7c0d599b0c4008c48aed497a7f2cb2fa6c3e2f78376 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int ram_25db8[];
extern int ram_25ea8;
unsigned char FileIO_CheckRecordValid(unsigned char a)
{
    unsigned int m;
    int i;
    i = ram_25ea8;
    if (i < 0 || i >= 20 || a >= 10) return 0;
    m = 1;
    m <<= a;
    return (unsigned char)((*(unsigned int *)((unsigned char *)ram_25db8 + i * 12) & m) == m);
}
