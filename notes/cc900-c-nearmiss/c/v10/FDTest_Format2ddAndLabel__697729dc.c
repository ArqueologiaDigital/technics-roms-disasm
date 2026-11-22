/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/test_init_m159_xr_b.c (2026-11-21-5-p6-r60)
   sha256 697729dc5d0ac2956058369777ec4e0537419c3ca0c5290df8970a347a5b5e02 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern void format_FD(unsigned int);
extern char FDTest_Format2ddAndLabel_Str_TEST_HAMA[];
extern int FileIO_CheckPathAndVolumeLabel(char *);
int FDTest_Format2ddAndLabel(void)
{
  format_FD(2);
  FileIO_CheckPathAndVolumeLabel(FDTest_Format2ddAndLabel_Str_TEST_HAMA);
  return 0;
}
