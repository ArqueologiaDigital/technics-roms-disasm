/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-31-p6-r1b)
   sha256 7d16c83e6f1cf5e299730f8d1d1afaeca30c78536fe0c0f5702fb6c24ee9316d (tar-sha256); compiled at -O3 -XS -Xr */
struct frec { unsigned int flags; unsigned int w[5]; };
extern struct frec FileIO_EmptyFileRecord, ram_25db8[];
extern int ram_25ea8, ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
unsigned int CheckFileSystemStatus(void)
{
    int i = ram_25ea8;
    if (i < 0 || i >= 20) return 0;
    return ram_25db8[i].flags;
}
