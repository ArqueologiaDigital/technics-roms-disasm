/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-31-p6-r1b)
   sha256 3c701cc280ffa91c9be4bfde230be135727936b7adbcf85cb0819f84e269f11d (tar-sha256); compiled at -Xr */
void FileIO_GetRecordType_Extended(unsigned char *s)
{
    if (*s != 0) do {
        if (*s == 0x7e) *s = 0x5f;
        else if (*s < 0x20) *s = 0x20;
    } while (*++s != 0);
}
