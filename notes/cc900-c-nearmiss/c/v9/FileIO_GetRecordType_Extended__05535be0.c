/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/file_demo_proc.c (2026-11-16-38-p6-r6)
   sha256 05535be0a1c5bb46880084febe77e147af34b2f0422f36aa7eed092ad3075c03 (tar-sha256); compiled at -Xr
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
