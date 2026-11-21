/* helper W, round 21r2, module 288, form b: SoundMode_SetChorusType with the call written in each case (V4.23's
   cross-jumping then shares one tail jp, hopefully after the last case) and the default returning.
   cc900-options: -O3 -Xr
*/

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
