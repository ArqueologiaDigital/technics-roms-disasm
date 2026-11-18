/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_fls_small.c (2026-11-18-24-hd-r56)
   sha256 8e6a821fa4639e31727455fa0fbbea86b8941dad1aceeb2e120f3a022c6ec78a (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };
extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *u);
long HDAE5000_RcmStream_FreeSpace(void)
{
    struct DiskUsage u;

    HDAE5000_HD_GetDiskUsage(&u);
    return u.free << 10;
}
