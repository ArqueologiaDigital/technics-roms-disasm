/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-30-p6-r1)
   sha256 8a7356886e18f7ab911e798723ccf50ecdd2436ab818c9ee86a2ecf0d3209eb9 (tar-sha256); compiled at -Xr */
void FileIO_GetRecordType_Extended(unsigned char *s)
{
    if (*s != 0) do {
        if (*s == 0x7e) *s = 0x5f;
        else if (*s < 0x20) *s = 0x20;
    } while (*++s != 0);
}
