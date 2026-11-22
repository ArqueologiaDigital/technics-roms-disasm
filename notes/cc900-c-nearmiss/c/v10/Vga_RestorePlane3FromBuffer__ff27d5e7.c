/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_R_20r1m2a.c (2026-11-21-3-p6-r59)
   sha256 ff27d5e75c370376ec3182fa770ee61513dad2372d1b0567f6f6047909bd18d2 (tar-sha256); compiled at -O3 -XS -Xr */
/* Helper R, round 1 of 2026-11-20: modules 0 / 2 / 3 (boot/system_handlers.s, shared/boot_routines.s), timer, flash
   and region helpers.  Form a. */
/* cc900-module: Vga_SelectWritePlane */   /* scripts/analysis/cc900/module_calls.py v10 */

extern volatile unsigned char __tiny T8RUN;
extern volatile unsigned char __tiny P7;
extern volatile unsigned char __tiny PH;
extern volatile int __near SYSTEM_TIMESTAMP;
extern unsigned char __near REGION_CODE_VAR;
extern unsigned int ram_ffcc;
extern void Copy_DE_words_from_XBC_to_XWA(unsigned long, unsigned long, unsigned long);
extern void Vga_SelectWritePlane(int);
extern void Timer3_Stop(void);
extern void Timer3_Start(void);

void Timer3_Start(void)
{
  T8RUN |= 0x08;
}

void Timer3_Stop(void)
{
  T8RUN &= ~0x08;
}

void TaskSched_DelayTicks(unsigned int t)
{
  int e = (t >> 1) + SYSTEM_TIMESTAMP;
  while (e > SYSTEM_TIMESTAMP)
    ;
}

int Flash_CheckReady(void)
{
  if (P7 & 0x20) return 0;
  return -1;
}

void Flash_FillBuffer(unsigned int *p, unsigned int n)
{
  unsigned int i;
  for (i = 0; i < n; i++)
    *p++ = i;
}

void Flash_CopyROMToBuffer(unsigned long a)
{
  Copy_DE_words_from_XBC_to_XWA(0x69800L, a & 0xff0000L, 0x8000L);
}

void Vga_RestorePlane3FromBuffer(void)
{
  Timer3_Stop();
  Vga_SelectWritePlane(3);
  Copy_DE_words_from_XBC_to_XWA(0x69800L, 0x1a9800L, 0xb400L);
  Vga_SelectWritePlane(0);
  Timer3_Start();
}

int Sys_CheckPowerStableFlag(void)
{
  return ram_ffcc == 0x5a5a;
}

void Detect_Region_Code(void)
{
  if (PH & 0x04) {
    if (PH & 0x02)
      REGION_CODE_VAR = 1;
    else
      REGION_CODE_VAR = 2;
  } else {
    if (PH & 0x02)
      REGION_CODE_VAR = 3;
    else
      REGION_CODE_VAR = 4;
  }
}
