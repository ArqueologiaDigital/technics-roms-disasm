/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3b.c (2026-11-16-37-p6-r5)
   sha256 412474a4bcb1b07706b807e204b3c008566145fa8f25b4beb61a0e0ac464ffd3 (tar-sha256); compiled at -O3 -Xr */
int FileIO_Search_SkipEntry(char *a, char *b, int n)
{
    char c;
    char *p = a;
    while (n != 0 && *p == *b) {
        if (*p == 0) return 0;
        p++;
        b++;
        n--;
    }
    if (n != 0) c = *p - *b;
    else c = 0;
    return c;
}
