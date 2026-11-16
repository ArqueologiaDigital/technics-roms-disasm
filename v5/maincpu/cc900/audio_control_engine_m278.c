/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char GetDialEnableState(void);
extern unsigned char CtrlPanel_GetSelectionState(void);
extern unsigned char __near ram_8e9e;
extern unsigned char __near ram_8ea0;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near LED_REQUEST_HOLD_3;
extern unsigned char __near ram_8e8c;
extern unsigned char __near DEMO_PLAY_STATE;
extern unsigned char __near ram_8e90;
extern unsigned char __near ram_8e92;
extern unsigned char __near ram_8e94;
extern unsigned char __near ram_8e96;

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

void Audio_InitChannelTimers(void)
{
	ram_8e8c = 5;
	DEMO_PLAY_STATE = 5;
	ram_8e90 = 5;
	ram_8e92 = 5;
	ram_8e94 = 5;
	ram_8e96 = 5;
}
