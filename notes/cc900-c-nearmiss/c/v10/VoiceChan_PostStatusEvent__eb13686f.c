/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_19b.c (2026-11-17-2-p6-r29)
   sha256 eb13686fbc5584600b7d99505a04a593a80ed6a6f6f9f990ae5c051fdc0c36dc (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2546[];
extern unsigned int __near ram_2526[];
extern volatile unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
void VoiceChan_PostStatusEvent(void)
{
  ram_2546[SEQ_PART_LOOP] = ram_2587;
  SEQ_PART_LOOP[(unsigned int *)ram_2526] = ram_258e;
}
