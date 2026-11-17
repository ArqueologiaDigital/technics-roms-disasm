/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_19a.c (2026-11-17-2-p6-r29)
   sha256 0e2c6631fa73a27a0e007e13d834c976e454c1abc291185404fe91b9051cb79a (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2546[];
extern unsigned int __near ram_2526[];
extern volatile unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
void VoiceChan_PostStatusEvent(void)
{
  ram_2546[SEQ_PART_LOOP] = ram_2587;
  *(unsigned int *)((char *)ram_2526 + SEQ_PART_LOOP * 2) = ram_258e;
}
