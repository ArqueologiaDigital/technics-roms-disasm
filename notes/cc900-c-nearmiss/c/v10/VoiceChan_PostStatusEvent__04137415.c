/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_20a.c (2026-11-17-16-p6-r31)
   sha256 041374154c58c748d963e487a9f771412596563478b994ae39c5817995712760 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2546[];
extern unsigned int __near ram_2526[];
#define WORD_2526 ((unsigned int *)ram_2526)
extern volatile unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
void VoiceChan_PostStatusEvent(void)
{
  unsigned char i;
  ram_2546[SEQ_PART_LOOP] = ram_2587;
  i = SEQ_PART_LOOP;
  WORD_2526[i] = ram_258e;
}
