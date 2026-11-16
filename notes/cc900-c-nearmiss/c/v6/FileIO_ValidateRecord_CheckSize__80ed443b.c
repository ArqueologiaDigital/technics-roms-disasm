/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/file_demo_proc_m267.c (2026-11-16-68-p6-r12)
   sha256 80ed443b98fd4031aef2b2acdc03027667ca7d99c18a0abca3de2e89087d7d9d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int FILE_ERROR;
extern int format_FD(unsigned int);
int FileIO_ValidateRecord_CheckSize(unsigned char a)
{
    if (format_FD(a) != 0) return 0;
    if (FILE_ERROR == 31) return -11;
    return -6;
}
