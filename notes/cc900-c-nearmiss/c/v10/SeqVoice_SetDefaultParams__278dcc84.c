/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m234.c (2026-11-16-111-p6-r22-staged)
   sha256 278dcc8402667cc209b615ab5ea8763c03b18d43d959e2e1fb6f264f6dbbd4f0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_28a1;
extern unsigned char __near ram_289e;
extern unsigned int __near ram_28a2;
extern unsigned int __near SEQ_BLOCK_TOTAL;
extern unsigned long __near SEQ_BLOCK_POOL;
extern unsigned long __near ram_ce8;
extern unsigned int __near ram_d30;
void SeqVoice_SetDefaultParams(void)
{
  ram_28a1 = 16;
  ram_289e = 15;
  ram_28a2 = SEQ_BLOCK_TOTAL;
  ram_ce8 = SEQ_BLOCK_POOL;
  ram_d30 = 0;
}
