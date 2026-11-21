/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Vga_SelectWritePlane */   /* scripts/analysis/cc900/module_calls.py v10 */

extern volatile unsigned char __tiny P7;
extern int Flash_CheckReady(void);
extern void Copy_DE_words_from_XBC_to_XWA(unsigned long, unsigned long, unsigned long);
extern void Flash_CopyROMToBuffer(unsigned long a);
extern void Flash_FillBuffer(unsigned int *p, unsigned int n);

int Flash_CheckReady(void)
{
  if (P7 & 0x20) return 0;
  return -1;
}

void Flash_CopyROMToBuffer(unsigned long a)
{
  Copy_DE_words_from_XBC_to_XWA(0x69800L, a & 0xff0000L, 0x8000L);
}

void Flash_FillBuffer(unsigned int *p, unsigned int n)
{
  unsigned int i;
  for (i = 0; i < n; i++)
    *p++ = i;
}
