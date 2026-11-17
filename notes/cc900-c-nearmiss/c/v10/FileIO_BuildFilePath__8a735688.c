/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-30-p6-r1)
   sha256 8a7356886e18f7ab911e798723ccf50ecdd2436ab818c9ee86a2ecf0d3209eb9 (tar-sha256); compiled at -O3 -XS -Xr */
void FileIO_BuildFilePath(char *d, char *s)
{
    while (*d != 0) d++;
    while (*s != 0) *d++ = *s++;
    *d = 0;
}
