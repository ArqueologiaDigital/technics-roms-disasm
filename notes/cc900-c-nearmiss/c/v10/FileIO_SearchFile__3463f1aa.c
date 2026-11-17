/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4a.c (2026-11-16-39-p6-r7)
   sha256 3463f1aae6c33574e20f2ee81cb11a9209f625d63976be3d448a39b81d910ff2 (tar-sha256); compiled at -O3 -XS -Xr */
int FileIO_SearchFile(char *a, char *b)
{
    char c;
    while ((c = *a) == *b) {
        if (c == 0) return 0;
        a++;
        b++;
    }
    return (char)(*a - *b);
}
