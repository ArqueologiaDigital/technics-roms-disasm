/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/file_demo_proc.c (2026-11-16-36-p6-staged-r4)
   sha256 6551b26f0525441f8574b7ba1e15f1bb5c316662fe3ed37082ea8a774b293290 (tar-sha256); compiled at -Xr
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
