/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Vga_SelectWritePlane */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int ram_ffcc;
extern int Sys_CheckPowerStableFlag(void);
extern volatile unsigned char __tiny T8RUN;
extern void Timer3_Start(void);
extern void Copy_DE_words_from_XBC_to_XWA(unsigned long, unsigned long, unsigned long);
extern void Vga_SelectWritePlane(int);
extern void Timer3_Stop(void);
extern void Vga_RestorePlane3FromBuffer(void);

int Sys_CheckPowerStableFlag(void)
{
  return ram_ffcc == 0x5a5a;
}

void Timer3_Start(void)
{
  T8RUN |= 0x08;
}

void Vga_RestorePlane3FromBuffer(void)
{
  Timer3_Stop();
  Vga_SelectWritePlane(3);
  Copy_DE_words_from_XBC_to_XWA(0x69800L, 0x1a9800L, 0xb400L);
  Vga_SelectWritePlane(0);
  Timer3_Start();
}
