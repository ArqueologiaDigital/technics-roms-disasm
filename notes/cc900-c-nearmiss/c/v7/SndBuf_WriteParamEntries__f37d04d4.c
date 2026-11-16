/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 f37d04d4cf90e9f65661b261fe9b19bca25c73b38a3503e1a3cbaeeee2a9f164 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_904e[];
extern unsigned char __near ram_9052[];
void SndBuf_WriteParamEntries(void)
{
  unsigned char b[6];
  b[0] = ram_904e[0]; b[1] = ram_904e[1]; b[2] = ram_904e[2]; b[5] = ram_904e[3];
  SndParam_CheckAndApplyMode(b);
  ram_9052[0] = b[3]; ram_9052[1] = b[4];
}
