/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_9m270a.c (2026-11-16-72-p6-r13)
   sha256 1b318ec28fc3d83528c5df921a5bc106b9349cd7f915c69815f3d4a965d6d1e7 (tar-sha256); compiled at -O3 -XS -Xr */
unsigned char FDC_ReadDataRegister()
{
    return *(unsigned char *)0x11000a;
}
