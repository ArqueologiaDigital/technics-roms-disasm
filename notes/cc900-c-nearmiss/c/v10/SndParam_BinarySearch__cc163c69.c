/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_6m283a.c (2026-11-16-100-p6-r19)
   sha256 cc163c69f7fc974d121e418b768ffd0651b39c90bbb6d1ba4e4deea36d2095c0 (tar-sha256); compiled at -O3 -Xr */
int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    if (n != 0) {
        hi = n - 1;
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
