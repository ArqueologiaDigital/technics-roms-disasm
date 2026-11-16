/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m268.c (2026-11-16-68-p6-r12)
   sha256 5ee788303a5b9ec2b2d5d4100bc15d449b6d9562abd5a389a2468f3b5b32b001 (tar-sha256); compiled at -Xr
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
