/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2a.c (2026-11-16-33-p6-r2)
   sha256 e1e5d1622a68bbc27489c801d6928dde38f9ceff8816827f2bfd0be724fc352c (tar-sha256); compiled at -O3 -Xr */
struct dirent82 { unsigned int w[41]; };
extern struct dirent82 ram_25eb2[];
extern int ram_271ec;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern char ram_25db6;
int ValidateFileRange(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (((unsigned char *)ram_25eb2)[(i - b) * 82] == 0) return 2;
    return 0;
}
