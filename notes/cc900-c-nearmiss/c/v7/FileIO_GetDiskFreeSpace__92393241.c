/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/file_demo_proc_m268.c (2026-11-21-5-p6-r60)
   sha256 92393241a4ada93b343a7112dfbfef7f91a3e0b1e53c752e3a3d703a3e243dbe (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct disk { long freesz; long total; };
extern struct disk ram_25d6c;
extern void GetDiskFreeSpace(long *, long *);
long FileIO_GetDiskFreeSpace(void)
{
  GetDiskFreeSpace(&ram_25d6c.freesz, &ram_25d6c.total);
  return ram_25d6c.freesz;
}
