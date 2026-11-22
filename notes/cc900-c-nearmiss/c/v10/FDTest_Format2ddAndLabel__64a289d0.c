/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m184a.c (2026-11-21-3-p6-r59)
   sha256 64a289d0702fd242de8a70377756559545e5d2ac5230ca40062d2f048e446c75 (tar-sha256); compiled at -O3 -Xr */
extern void format_FD(unsigned int);
extern char FDTest_Format2ddAndLabel_Str_TEST_HAMA[];
extern int FileIO_CheckPathAndVolumeLabel(char *);
int FDTest_Format2ddAndLabel(void)
{
  format_FD(2);
  FileIO_CheckPathAndVolumeLabel(FDTest_Format2ddAndLabel_Str_TEST_HAMA);
  return 0;
}
