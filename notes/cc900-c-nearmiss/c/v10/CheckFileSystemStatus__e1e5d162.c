/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2a.c (2026-11-16-33-p6-r2)
   sha256 e1e5d1622a68bbc27489c801d6928dde38f9ceff8816827f2bfd0be724fc352c (tar-sha256); compiled at -O3 -Xr */
struct frec { unsigned int w[6]; };
extern struct frec ram_25db8[];
extern int ram_25ea8;
unsigned int CheckFileSystemStatus(void)
{
    if (ram_25ea8 < 0 || ram_25ea8 >= 20) return 0;
    return *(unsigned int *)((unsigned char *)ram_25db8 + ram_25ea8 * 12);
}
