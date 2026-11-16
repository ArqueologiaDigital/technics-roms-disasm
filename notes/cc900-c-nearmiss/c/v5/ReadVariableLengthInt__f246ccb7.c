/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m268.c (2026-11-16-81-p6-r14)
   sha256 f246ccb7a1b73145f523a2cc8cdb177a1fea97481386cd0fedb035ade1c0a7ba (tar-sha256); compiled at -O3 -XS -Xr
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
