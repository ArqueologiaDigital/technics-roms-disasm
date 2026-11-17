/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_20c.c (2026-11-17-16-p6-r31)
   sha256 7d3e44df5e3fc9cd5496e97dca74919be33076be617222a25535753dca33ad9e (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_2546[];
extern unsigned int __near ram_2526[];
#define WORD_2526 ((unsigned int *)ram_2526)
extern volatile unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
void VoiceChan_PostStatusEvent(void)
{
  unsigned char i;
  i = SEQ_PART_LOOP;
  ram_2546[i] = ram_2587;
  i = SEQ_PART_LOOP;
  WORD_2526[i] = ram_258e;
}
