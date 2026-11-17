/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_18a.c (2026-11-16-128-p6-r27)
   sha256 bfae7c1ad0d072c4e30669eb5a779d2b54efb3a420a174f7146b44fe63e33bb8 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2576[];
extern unsigned int __near ram_2556[];
#define WORD_2556 ((unsigned int *)ram_2556)
extern volatile unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
void SeqScan_StoreResultB(void)
{
  ram_2576[SEQ_PART_LOOP] = ram_2587;
  WORD_2556[SEQ_PART_LOOP] = ram_258e;
}
