/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_18b.c (2026-11-16-128-p6-r27)
   sha256 8f588024d12da20828c864adbbfbe44bda812ae6b96fd4d38071e4b82b4231c1 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2546[];
extern unsigned int __near ram_2526[];
#define WORD_2526 ((unsigned int *)ram_2526)
extern unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
void VoiceChan_PostStatusEvent(void)
{
  ram_2546[SEQ_PART_LOOP] = ram_2587;
  WORD_2526[SEQ_PART_LOOP] = ram_258e;
}
