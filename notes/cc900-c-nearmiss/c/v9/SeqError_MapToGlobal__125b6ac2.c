/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m0.c (2026-11-16-111-p6-r22-staged)
   sha256 125b6ac29cacc666d3f022c3ec2442b441ea4f0259515244e798ccbad2d8a2b4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near GLOBAL_ERROR_CODE;
void SeqError_MapToGlobal(unsigned char *t)
{
  GLOBAL_ERROR_CODE = t[SEQ_ERROR_CODE];
}
