/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2b.c (2026-11-16-33-p6-r2)
   sha256 b9efa2757706d71e6e9c9e909054c7167cfc9ddaea6d230749048ed7913a21f6 (tar-sha256); compiled at -O3 -Xr */
struct dirent82 { unsigned int w[41]; };
extern struct dirent82 ram_25eb2[];
extern int ram_271ec;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern char ram_25db6;
int ValidateFileRange(int i)
{
    int b;
    if ((ram_25db6 != 2 && ram_25db6 != 3 && ram_25db6 != 4) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (((unsigned char *)ram_25eb2)[(i - b) * 82] == 0) return 2;
    return 0;
}
