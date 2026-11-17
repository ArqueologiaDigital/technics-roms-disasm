/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2b.c (2026-11-16-33-p6-r2)
   sha256 b9efa2757706d71e6e9c9e909054c7167cfc9ddaea6d230749048ed7913a21f6 (tar-sha256); compiled at -O3 -Xr */
struct frec { unsigned int w[6]; };
extern struct frec ram_25db8[];
extern int ram_25ea8;
unsigned int CheckFileSystemStatus(void)
{
    if (ram_25ea8 < 0 || ram_25ea8 >= 20) return 0;
    return ((unsigned int *)ram_25db8)[ram_25ea8 * 6];
}
