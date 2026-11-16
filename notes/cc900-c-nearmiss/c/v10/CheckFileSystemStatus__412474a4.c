/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3b.c (2026-11-16-37-p6-r5)
   sha256 412474a4bcb1b07706b807e204b3c008566145fa8f25b4beb61a0e0ac464ffd3 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int ram_25db8[];
extern int ram_25ea8;
unsigned int CheckFileSystemStatus(void)
{
    int i = ram_25ea8;
    if (i < 0 || i >= 20) return 0;
    return *(unsigned int *)((unsigned char *)ram_25db8 + i * 12);
}
