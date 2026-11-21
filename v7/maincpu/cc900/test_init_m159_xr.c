/* Functions of factory_test/test_init.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char FDTest_Format2hdAndLabel_Str_TESTHAMA2HD[];
extern int format_FD(int);
extern void FileIO_CheckPathAndVolumeLabel(unsigned char *);
extern int FDTest_Format2hdAndLabel(void);

int FDTest_Format2hdAndLabel(void)
{
  format_FD(3);
  FileIO_CheckPathAndVolumeLabel(FDTest_Format2hdAndLabel_Str_TESTHAMA2HD);
  return 0;
}
