/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sndparam_routines_m0.c (2026-11-16-122-p6-r24-staged)
   sha256 242cef0f61705297815c8d304d16e2752ffe4b1c97d973ce81c1e8e6cd878a0b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
