/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-31-p6-r1b)
   sha256 3c701cc280ffa91c9be4bfde230be135727936b7adbcf85cb0819f84e269f11d (tar-sha256); compiled at -O3 -XS -Xr */
unsigned long *TableData_ROM_Verify(unsigned long *p, unsigned long *end)
{
    for (;;) {
        if (*p != 0xffffffff) return p;
        p += 16;
        if (p == end) return 0;
    }
}
