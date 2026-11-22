/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m288a.c (2026-11-21-2-p6-r58)
   sha256 9db3c06b71b664d84d5a2685a533f363a566ec3712b45c1151740192c24b6f47 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char ram_340f9;
extern unsigned char __near ram_b7ec;
extern void SndParam_ApplyAndSync(void);
void SoundMode_SetChorusType(void)
{
  switch (ram_340f9) {
  case 1:
    ram_b7ec = 91;
    break;
  case 2:
    ram_b7ec = 92;
    break;
  case 3:
    ram_b7ec = 93;
    break;
  default:
    return;
  }
  SndParam_ApplyAndSync();
}
