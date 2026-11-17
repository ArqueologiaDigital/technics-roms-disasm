/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_6m283b.c (2026-11-16-100-p6-r19)
   sha256 bb5d49ddbd4ab0b4fe2ff807261d08c6b49e6f23f0462ecf3f07c15844c1c009 (tar-sha256); compiled at -O3 -Xr */
int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    hi = n - 1;
    if (n != 0) {
        while (lo <= hi) {
            mid = (lo + hi) >> 1;
            e = t[mid];
            if (key == e) return 0;
            if (key > e) lo = mid + 1;
            else hi = mid - 1;
        }
    }
    return -1;
}
