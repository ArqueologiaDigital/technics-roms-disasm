/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-30-p6-r1)
   sha256 89c854e8d1cefff97d8e3bd7f8dd41e25e56a8bb83e3b643d1a5fe02db8a7c3a (tar-sha256); compiled at -O3 -XS -Xr */
struct frec { unsigned int flags; unsigned int w[5]; };
extern struct frec FileIO_EmptyFileRecord, ram_25db8[];
extern int ram_25ea8, ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
unsigned int CheckFileSystemStatus(void)
{
    int i = ram_25ea8;
    if (i < 0 || i >= 20) return 0;
    return ram_25db8[i].flags;
}
