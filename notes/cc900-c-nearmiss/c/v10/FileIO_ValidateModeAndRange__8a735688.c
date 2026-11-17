/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-30-p6-r1)
   sha256 8a7356886e18f7ab911e798723ccf50ecdd2436ab818c9ee86a2ecf0d3209eb9 (tar-sha256); compiled at -O3 -XS -Xr */
struct rec14 { unsigned char used; unsigned char rest[13]; };
extern struct rec14 ram_2723c[];
extern int ram_25ea8, ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
extern char ram_25db6;
int FileIO_ValidateModeAndRange(int i)
{
    int b;
    if ((ram_25db6 != 2 && ram_25db6 != 3 && ram_25db6 != 4) || i < 0 || i > ram_272ca) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_2723c[i - b].used != 0) return 0;
    return 2;
}
