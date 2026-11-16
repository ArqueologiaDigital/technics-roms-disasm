/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_10m283b.c (2026-11-16-118-p6-r23)
   sha256 100c6e3d84f736414619f20e5bbb021e5d1130789fe6ff9b479a192b7b3f948e (tar-sha256); compiled at -O3 -Xr */
int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    hi = n;
    if (hi-- != 0) {
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
