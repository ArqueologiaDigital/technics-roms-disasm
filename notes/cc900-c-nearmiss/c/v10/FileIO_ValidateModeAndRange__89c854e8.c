/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-30-p6-r1)
   sha256 89c854e8d1cefff97d8e3bd7f8dd41e25e56a8bb83e3b643d1a5fe02db8a7c3a (tar-sha256); compiled at -O3 -XS -Xr */
struct rec14 { unsigned char used; unsigned char rest[13]; };
extern struct rec14 ram_2723c[];
extern int ram_25ea8, ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
extern char ram_25db6;
int FileIO_ValidateModeAndRange(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_272ca) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_2723c[i - b].used == 0) return 2;
    return 0;
}
