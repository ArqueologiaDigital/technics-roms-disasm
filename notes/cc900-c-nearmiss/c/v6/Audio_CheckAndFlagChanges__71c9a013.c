/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine_m278.c (2026-11-16-68-p6-r12)
   sha256 71c9a013e8095a1f078937b51a9c24149cf7505128183a825c0ecff5c0016109 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char GetDialEnableState(void);
extern unsigned char CtrlPanel_GetSelectionState(void);
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
