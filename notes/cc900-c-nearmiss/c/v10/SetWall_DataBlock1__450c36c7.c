/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m164a.c (2026-11-21-2-p6-r58)
   sha256 450c36c786576a9c2836269be648cffc7440ddb44ede699c6950de0feba53c4f (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near ram_d3f;
void SetWall_DataBlock1(void)
{
  GLOBAL_ERROR_CODE = 0;
  ram_d3f = SEQ_CURRENT_SONG;
}
