/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc.c (2026-11-16-55-p6-r10)
   sha256 7472fd7aac5942733077a1738f4bddd3fb3bf69803cd91dfb1af6a633889b28f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int FILE_ERROR;
int FileIO_ValidateRecord_CheckSize(unsigned char a)
{
    if (format_FD(a) != 0) return 0;
    if (FILE_ERROR == 31) return -11;
    return -6;
}
