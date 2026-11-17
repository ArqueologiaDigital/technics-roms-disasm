/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m278.c (2026-11-16-68-p6-r12)
   sha256 931b31ee76072e32d9495b11e0a459d1361f35c4680409fd4c4e6be9267e234f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char GetDialEnableState(void);
extern unsigned char CtrlPanel_GetSelectionState(void);
extern unsigned char __near ram_8f5e;
extern unsigned char __near ram_8f60;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near LED_REQUEST_HOLD_3;
void Audio_CheckAndFlagChanges(void)
{
  unsigned char l;
  l = GetDialEnableState();
  if (l != ram_8f5e) { LED_REQUEST_3 |= 0x40; ram_8f5e = l; }
  l = CtrlPanel_GetSelectionState();
  if (l == ram_8f60) return;
  if (l == 2) LED_REQUEST_HOLD_3 |= 0x04;
  if (ram_8f60 == 2) LED_REQUEST_HOLD_3 &= ~0x04;
  LED_REQUEST_3 |= 0x04;
  ram_8f60 = l;
}
