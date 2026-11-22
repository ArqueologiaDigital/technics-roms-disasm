/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_W_21r2m288b.c (2026-11-21-9-p6-r64)
   sha256 258a63a5e7a6c7cbab4e8df354168e89923d4bff6a720f6012ebf4696f597c0f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char ram_340f9;
extern unsigned char __near ram_b7ec;
extern void SndParam_ApplyAndSync(void);
void SoundMode_SetChorusType(void)
{
  switch (ram_340f9) {
  case 1:
    ram_b7ec = 91;
    SndParam_ApplyAndSync();
    return;
  case 2:
    ram_b7ec = 92;
    SndParam_ApplyAndSync();
    return;
  case 3:
    ram_b7ec = 93;
    SndParam_ApplyAndSync();
    return;
  }
}
