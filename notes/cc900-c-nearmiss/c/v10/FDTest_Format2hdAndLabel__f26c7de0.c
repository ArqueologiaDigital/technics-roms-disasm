/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m159a.c (2026-11-21-2-p6-r58)
   sha256 f26c7de061ec46b8480e8a7e15a3895efdabf6c827a45d1c861e249fb5caedf9 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char FDTest_Format2hdAndLabel_Str_TESTHAMA2HD[];
extern int format_FD(int);
extern void FileIO_CheckPathAndVolumeLabel(unsigned char *);
int FDTest_Format2hdAndLabel(void)
{
  format_FD(3);
  FileIO_CheckPathAndVolumeLabel(FDTest_Format2hdAndLabel_Str_TESTHAMA2HD);
  return 0;
}
