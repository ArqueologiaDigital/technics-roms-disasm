/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m264a.c (2026-11-21-3-p6-r59)
   sha256 eba320e24d4fee75bd612035f88f5751be2a56a029d71061e644bf166d676c3b (tar-sha256); compiled at -Xr */
struct disk { long freesz; long total; };
extern struct disk ram_25d6c;
extern void GetDiskFreeSpace(long *, long *);
long FileIO_GetDiskFreeSpace(void)
{
  GetDiskFreeSpace(&ram_25d6c.freesz, &ram_25d6c.total);
  return ram_25d6c.freesz;
}
