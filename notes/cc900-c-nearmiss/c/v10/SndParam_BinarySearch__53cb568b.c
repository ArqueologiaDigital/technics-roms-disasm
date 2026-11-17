/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_9m283b.c (2026-11-16-107-p6-r21)
   sha256 53cb568b54e7d0b445ed3ebdfaa2071a9d155552b182d093e04f113112383e92 (tar-sha256); compiled at -O3 -Xr */
int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n)
{
    unsigned int lo;
    unsigned int hi;
    unsigned int mid;
    unsigned char e;

    lo = 0;
    if (n >= 1) {
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
