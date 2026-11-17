/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m268.c (2026-11-16-91-p6-r17)
   sha256 8b034114cb45a5a4796319c6f4a6578534c52e0af3faf3c92ded7426f45b9b2a (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern int FileIO_ReadByte(void);
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
