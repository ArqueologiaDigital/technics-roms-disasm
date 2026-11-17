/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 905b102ec67db05241a7bb46d72e45cb08dfa79fb3ce724d46d401b5490c3eb7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8e9e;
extern unsigned char __near ram_8ea0;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near LED_REQUEST_HOLD_3;
void Audio_CheckAndFlagChanges(void)
{
  unsigned char l;
  l = GetDialEnableState();
  if (l != ram_8e9e) { LED_REQUEST_3 |= 0x40; ram_8e9e = l; }
  l = CtrlPanel_GetSelectionState();
  if (l == ram_8ea0) return;
  if (l == 2) LED_REQUEST_HOLD_3 |= 0x04;
  if (ram_8ea0 == 2) LED_REQUEST_HOLD_3 &= ~0x04;
  LED_REQUEST_3 |= 0x04;
  ram_8ea0 = l;
}
