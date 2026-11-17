/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m234.c (2026-11-16-111-p6-r22-staged)
   sha256 83e57315c375c1c940336c1fd470f4631a66d0a489ca456b1c516c63985f9806 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2885;
extern unsigned char __near ram_2882;
extern unsigned int __near ram_2886;
extern unsigned int __near SEQ_BLOCK_TOTAL;
extern unsigned long __near SEQ_BLOCK_POOL;
extern unsigned long __near ram_ce8;
extern unsigned int __near ram_d30;
void SeqVoice_SetDefaultParams(void)
{
  ram_2885 = 16;
  ram_2882 = 15;
  ram_2886 = SEQ_BLOCK_TOTAL;
  ram_ce8 = SEQ_BLOCK_POOL;
  ram_d30 = 0;
}
