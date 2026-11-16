/* Functions of audio/sndparam_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern int SndParam_BinarySearch(unsigned char key, unsigned char *t, unsigned int n);

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
