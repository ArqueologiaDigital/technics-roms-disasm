/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_20b.c (2026-11-17-16-p6-r31)
   sha256 da15fb2d3ad590bf8711a40ba8747a88ae8018a0fbad8d5c20f7d9a3bf370f65 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2546[];
extern unsigned int __near ram_2526[];
#define WORD_2526 ((unsigned int *)ram_2526)
extern volatile unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
void VoiceChan_PostStatusEvent(void)
{
  int i;
  ram_2546[SEQ_PART_LOOP] = ram_2587;
  i = SEQ_PART_LOOP;
  WORD_2526[i] = ram_258e;
}
