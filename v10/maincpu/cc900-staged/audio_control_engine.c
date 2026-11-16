/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
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

void SndParam_ResolveVoiceEntry(unsigned char *r)
{
  unsigned char *t = r + 2;
  unsigned char *b;
  if (*t <= 0x1f) SndParam_FetchOscTableEntry(r);
  else if (*t == 0x48) {
    b = ram_90ea;
    b[0] = r[3]; b[1] = r[4]; b[2] = *t;
    Rhythm_DispatchNote_Finalize();
    b = ram_90ee;
    r[0] = b[0]; r[1] = b[1];
  }
}

extern unsigned char __near ram_8f4c;
extern unsigned char __near DEMO_PLAY_STATE;
extern unsigned char __near ram_8f50;
extern unsigned char __near ram_8f52;
extern unsigned char __near ram_8f54;
extern unsigned char __near ram_8f56;
extern unsigned char PanelInput_EventIndexByHeader[];

void Audio_InitChannelTimers(void)
{
	ram_8f4c = 5;
	DEMO_PLAY_STATE = 5;
	ram_8f50 = 5;
	ram_8f52 = 5;
	ram_8f54 = 5;
	ram_8f56 = 5;
}

unsigned char PanelInput_EventIndexOfHeader(unsigned char h)
{
	return PanelInput_EventIndexByHeader[(h & 0xc0) >> 1 | (h & 0x1f)];
}
