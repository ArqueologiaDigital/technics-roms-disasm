/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FDC_Format2DD_Start FDC_Format2HD_Start */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char ram_3e3e4;
extern unsigned int ram_3e3e6;
extern unsigned char ram_3e3e2;
extern void FDC_ClearDiskChangeStatus(void);
extern unsigned char FDC_ReadDiskType(void);
extern unsigned char ram_3e3be;
extern void __cdecl FDC_StoreDiskType(unsigned char t);
extern int FileIO_ValidateHandle(long h);
extern unsigned int FDC_ReadDiskChangeStatus(void);

void FDC_ClearDiskChangeStatus(void)
{
  ram_3e3e6 = 0;
  ram_3e3e2 = ram_3e3e4;
}

unsigned char FDC_ReadDiskType(void)
{
  return ram_3e3e4;
}

void __cdecl FDC_StoreDiskType(unsigned char t)
{
  ram_3e3e4 = t;
  ram_3e3e6 = 1;
  ram_3e3be = 0;
}

int FileIO_ValidateHandle(long h)
{
  if (h == 0) return -1;
  return 0;
}

unsigned int FDC_ReadDiskChangeStatus(void)
{
  return ram_3e3e6;
}
