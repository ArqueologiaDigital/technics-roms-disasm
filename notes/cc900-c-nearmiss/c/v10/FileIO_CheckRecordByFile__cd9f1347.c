/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4b.c (2026-11-16-39-p6-r7)
   sha256 cd9f134746513c7c9c77d7c0d599b0c4008c48aed497a7f2cb2fa6c3e2f78376 (tar-sha256); compiled at -O3 -XS -Xr */
struct frec { unsigned int w[6]; };
extern unsigned int ram_25db8[];
unsigned char FileIO_CheckRecordByFile(unsigned int i, unsigned char b)
{
    unsigned int m;
    if (i >= 20 || b >= 10) return 0;
    m = 1;
    m <<= b;
    return (unsigned char)((((struct frec *)ram_25db8)[i].w[0] & m) == m);
}
