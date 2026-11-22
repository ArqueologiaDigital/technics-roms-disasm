/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m264a.c (2026-11-21-3-p6-r59)
   sha256 eba320e24d4fee75bd612035f88f5751be2a56a029d71061e644bf166d676c3b (tar-sha256); compiled at -O3 -Xr */
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern int FileIO_OpenDefault(char *);
int GetFirstRecordAndOpen(void)
{
  int n = GetFirstPageBase();
  if (n < 0) return -0x68;
  return FileIO_OpenDefault(GetRecordPtrForFile(n));
}
