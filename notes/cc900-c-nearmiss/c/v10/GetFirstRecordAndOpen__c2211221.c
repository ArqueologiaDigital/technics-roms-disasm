/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/file_demo_proc_m266_xr.c (2026-11-21-5-p6-r60)
   sha256 c221122189cb196280667e568850466b43d1ebc5f6fc265d8972a6fe8d9375b9 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern int FileIO_OpenDefault(char *);
int GetFirstRecordAndOpen(void)
{
  int n = GetFirstPageBase();
  if (n < 0) return -0x68;
  return FileIO_OpenDefault(GetRecordPtrForFile(n));
}
