/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 eb272322a9ca5cd5672dea3f898fbc1c871c8ab00549b22bdff756d69d49a438 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
