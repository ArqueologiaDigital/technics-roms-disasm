/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/test_init_m159_xr.c (2026-11-21-5-p6-r60)
   sha256 1c0d0157422856c7637ff49293ff07b2e7ef19256bdad0c285bd22360a828728 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern unsigned char FDTest_Format2hdAndLabel_Str_TESTHAMA2HD[];
extern int format_FD(int);
extern void FileIO_CheckPathAndVolumeLabel(unsigned char *);
int FDTest_Format2hdAndLabel(void)
{
  format_FD(3);
  FileIO_CheckPathAndVolumeLabel(FDTest_Format2hdAndLabel_Str_TESTHAMA2HD);
  return 0;
}
