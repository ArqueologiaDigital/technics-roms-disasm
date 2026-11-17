/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_10m283a.c (2026-11-16-118-p6-r23)
   sha256 c3cd59d1f5affaf9f3a5d10c7a8c858173f6970cda4882faede02b8ca900cb50 (tar-sha256); compiled at -Xr */
int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    hi = n - 1;
    while (lo <= hi) {
        mid = (lo + hi) >> 1;
        e = t[mid];
        if (key == e) return 0;
        if (key > e) lo = mid + 1;
        else hi = mid - 1;
    }
    return -1;
}
