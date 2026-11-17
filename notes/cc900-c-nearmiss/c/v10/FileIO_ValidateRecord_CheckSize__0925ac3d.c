/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_5b.c (2026-11-16-40-p6-r8)
   sha256 0925ac3d7624e564a79643524eac0977811cc2828328dc740296e5ffc2f35240 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int FILE_ERROR;
extern int format_FD(unsigned int);
int FileIO_ValidateRecord_CheckSize(unsigned char a)
{
    if (format_FD(a) == 0) {
        if (FILE_ERROR == 31) return -11;
        return -6;
    }
    return 0;
}
