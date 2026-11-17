/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine_m280.c (2026-11-16-68-p6-r12)
   sha256 8d529fe092298a6a4d785732e8c53cdd60c87538f977c98b542b50379e4c9b95 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_902a[];
extern unsigned char __near ram_902e[];
extern void SndParam_CheckAndApplyMode(unsigned char *);
void SndBuf_WriteParamEntries(void)
{
  unsigned char b[6];
  b[0] = ram_902a[0]; b[1] = ram_902a[1]; b[2] = ram_902a[2]; b[5] = ram_902a[3];
  SndParam_CheckAndApplyMode(b);
  ram_902e[0] = b[3]; ram_902e[1] = b[4];
}
