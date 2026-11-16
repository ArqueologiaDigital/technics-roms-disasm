/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m278.c (2026-11-16-68-p6-r12)
   sha256 e9b87df03ca0c26b8a9cc22a4d78c8cf3389c2e176aeffbf545c3e51a70e5ccc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char GetDialEnableState(void);
extern unsigned char CtrlPanel_GetSelectionState(void);
extern unsigned char __near ram_8ec2;
extern unsigned char __near ram_8ec4;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near LED_REQUEST_HOLD_3;
void Audio_CheckAndFlagChanges(void)
{
  unsigned char l;
  l = GetDialEnableState();
  if (l != ram_8ec2) { LED_REQUEST_3 |= 0x40; ram_8ec2 = l; }
  l = CtrlPanel_GetSelectionState();
  if (l == ram_8ec4) return;
  if (l == 2) LED_REQUEST_HOLD_3 |= 0x04;
  if (ram_8ec4 == 2) LED_REQUEST_HOLD_3 &= ~0x04;
  LED_REQUEST_3 |= 0x04;
  ram_8ec4 = l;
}
