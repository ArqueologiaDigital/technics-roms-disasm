/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern volatile unsigned char __tiny T8RUN;
extern volatile unsigned char __tiny P7;
extern unsigned int ram_ffcc;
extern void Copy_DE_words_from_XBC_to_XWA(unsigned long, unsigned long, unsigned long);
extern void Vga_SelectWritePlane(int);
extern void Timer3_Stop(void);
extern void Timer3_Start(void);

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

int Sys_CheckPowerStableFlag(void)
{
  return ram_ffcc == 0x5a5a;
}

void Timer3_Start(void)
{
  T8RUN |= 0x08;
}

void Timer3_Stop(void)
{
  T8RUN &= ~0x08;
}

void Vga_RestorePlane3FromBuffer(void)
{
  Timer3_Stop();
  Vga_SelectWritePlane(3);
  Copy_DE_words_from_XBC_to_XWA(0x69800L, 0x1a9800L, 0xb400L);
  Vga_SelectWritePlane(0);
  Timer3_Start();
}
