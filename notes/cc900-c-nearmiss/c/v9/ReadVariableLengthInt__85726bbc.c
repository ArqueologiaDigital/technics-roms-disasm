/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/file_demo_proc.c (2026-11-16-45-p6-r9)
   sha256 85726bbc6b8710e4c2174cf99a3fe9c343a73ab032e9d1fd0520a3263df9591b (tar-sha256); compiled at -Xr
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
