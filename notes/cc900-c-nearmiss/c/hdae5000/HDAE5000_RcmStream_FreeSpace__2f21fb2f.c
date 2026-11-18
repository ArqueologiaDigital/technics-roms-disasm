/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_fls_small.c (2026-11-18-26-hd-r56-ports)
   sha256 2f21fb2fbd9da944370fff660f77c16abdd46a929d52b43872efd1c6dc487e25 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };
extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *u);
long HDAE5000_RcmStream_FreeSpace(void)
{
    struct DiskUsage u;

    HDAE5000_HD_GetDiskUsage(&u);
    return u.free << 10;
}
