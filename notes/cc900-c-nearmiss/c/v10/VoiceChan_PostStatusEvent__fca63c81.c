/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_19c.c (2026-11-17-2-p6-r29)
   sha256 fca63c81fb71f8019aebc7e7d31641914e7fb30e7c2f0b5ea81a796bca0686de (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2546[];
extern unsigned int __near ram_2526[];
#define WORD_2526 ((unsigned int *)ram_2526)
extern volatile unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
void VoiceChan_PostStatusEvent(void)
{
  ram_2546[SEQ_PART_LOOP] = ram_2587;
  WORD_2526[(int)SEQ_PART_LOOP] = ram_258e;
}
