/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_9m283a.c (2026-11-16-107-p6-r21)
   sha256 7d977e1b84fde5b654e37b6a6c3d68f9fd9f03a4001a215e73154c642a6c15aa (tar-sha256); compiled at -O3 -Xr */
int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    hi = n - 1;
    if (hi < n) {
        do {
            mid = (lo + hi) >> 1;
            e = t[mid];
            if (key == e) return 0;
            if (key > e) lo = mid + 1;
            else hi = mid - 1;
        } while (lo <= hi);
    }
    return -1;
}
