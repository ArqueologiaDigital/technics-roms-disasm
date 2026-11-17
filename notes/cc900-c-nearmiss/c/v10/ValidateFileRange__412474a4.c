/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3b.c (2026-11-16-37-p6-r5)
   sha256 412474a4bcb1b07706b807e204b3c008566145fa8f25b4beb61a0e0ac464ffd3 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char ram_25eb2[];
extern int ram_271ec;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern char ram_25db6;
int ValidateFileRange(int i)
{
    int b;
    char m = ram_25db6;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_25eb2[(i - b) * 82] != 0) return 0;
    return 2;
}
