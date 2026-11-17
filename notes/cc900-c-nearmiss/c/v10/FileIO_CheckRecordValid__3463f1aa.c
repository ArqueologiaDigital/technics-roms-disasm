/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4a.c (2026-11-16-39-p6-r7)
   sha256 3463f1aae6c33574e20f2ee81cb11a9209f625d63976be3d448a39b81d910ff2 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int ram_25db8[];
extern int ram_25ea8;
unsigned char FileIO_CheckRecordValid(unsigned char a)
{
    unsigned int m;
    if (ram_25ea8 < 0 || ram_25ea8 >= 20 || a >= 10) return 0;
    m = 1;
    m <<= a;
    return (ram_25db8[ram_25ea8 * 6] & m) == m;
}
