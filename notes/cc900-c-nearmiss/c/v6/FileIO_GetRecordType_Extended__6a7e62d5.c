/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/file_demo_proc.c (2026-11-16-33-p6-r2)
   sha256 6a7e62d5630fa3c8429f73b2dedf5a52d79dcca8003100e46fb491142df0d327 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void FileIO_GetRecordType_Extended(unsigned char *s)
{
    if (*s == 0) return;
    do {
        if (*s == 0x7e) *s = 0x5f;
        else if (*s < 0x20) *s = 0x20;
        s++;
    } while (*s != 0);
}
