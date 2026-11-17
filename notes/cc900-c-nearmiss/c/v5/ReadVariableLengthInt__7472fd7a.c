/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc.c (2026-11-16-55-p6-r10)
   sha256 7472fd7aac5942733077a1738f4bddd3fb3bf69803cd91dfb1af6a633889b28f (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
int ReadVariableLengthInt(void)
{
    unsigned long v = 0;
    int c;
    while ((c = FileIO_ReadByte()) > 0x7f) {
        v += (long)(c & 0x7f);
        v <<= 7;
    }
    if (c < 0) return -1;
    v += (long)c;
    return (int)(v > 0x7fff ? 0x7fff : v);
}
