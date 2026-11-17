/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/file_demo_proc.c (2026-11-16-40-p6-r8)
   sha256 f4ed9da277e24e64306884a95600b23c803b7dfd373294d8db253a401358a39c (tar-sha256); compiled at -Xr
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
