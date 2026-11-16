/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/file_demo_proc_m268.c (2026-11-16-68-p6-r12)
   sha256 5ee788303a5b9ec2b2d5d4100bc15d449b6d9562abd5a389a2468f3b5b32b001 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern long ram_25d6c;
extern long FileIO_DiskInfoInit;
extern void GetDiskFreeSpace(long *, long *);
long GetEncodedFreeSpaceData(void)
{
    long *p = &ram_25d6c;
    if (FileIO_DiskInfoInit == *p) GetDiskFreeSpace(p, p + 1);
    return ram_25d6c;
}
