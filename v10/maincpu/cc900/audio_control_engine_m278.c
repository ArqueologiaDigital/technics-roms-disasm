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
extern unsigned char __near ram_8f5e;
extern unsigned char __near ram_8f60;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near LED_REQUEST_HOLD_3;
extern unsigned char __near ram_8f4c;
extern unsigned char __near DEMO_PLAY_STATE;
extern unsigned char __near ram_8f50;
extern unsigned char __near ram_8f52;
extern unsigned char __near ram_8f54;
extern unsigned char __near ram_8f56;

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

void Audio_InitChannelTimers(void)
{
	ram_8f4c = 5;
	DEMO_PLAY_STATE = 5;
	ram_8f50 = 5;
	ram_8f52 = 5;
	ram_8f54 = 5;
	ram_8f56 = 5;
}

extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ram_347b;
extern unsigned int __near LED_REQUEST_2;
extern void MidiChOut_DetectChanges(void);

void MidiChOut_DetectChanges(void)
{
	if (ACC_TRANSPORT_STATE & 4) return;
	if (!((PLAY_TRANSPORT_STATE ^ ram_347b) & 4)) return;
	LED_REQUEST_2 |= 4;
	ram_347b = PLAY_TRANSPORT_STATE;
}

/* cc900-module: AnalogIn_PollAfterTouch AnalogIn_PollExpressionPedal ArpQueue_Enqueue ArpQueue_InitBuffer Audio_FlushPendingBankSelects MidiChan_ParseVoiceData PanelTlv_WriteBlock0Headers PanelTlv_WriteBlock1Headers PanelTlv_WriteLivePanelHeaders PanelTlv_WritePanelMemoryHeaders SeqBuf_WaitForEmpty SeqData_InitPlaybackFromField SeqOut_FlushWithChunking */
extern void AnalogIn_PollExpressionPedal(unsigned char *);
extern void AnalogIn_PollAfterTouch(unsigned char *);
extern void AnalogIn_PollCpuAdc(void);

void AnalogIn_PollCpuAdc(void)
{
  AnalogIn_PollExpressionPedal((unsigned char *)0x8f10L);
  AnalogIn_PollAfterTouch((unsigned char *)0x8f16L);
}

extern unsigned int __near LED_REQUEST_HOLD_1;
extern unsigned int __near LED_REQUEST_HOLD_2;
extern unsigned int __near ram_8f48;
extern unsigned long CtrlPanel_LookupIndicatorEntry(unsigned int a);
extern void CtrlPanel_IndicatorDispatch(unsigned char a);
extern unsigned int __near LED_REQUEST_1;
extern unsigned int __near ram_8f46;
extern void CtrlPanel_SetIndicatorBit(unsigned char a);

void CtrlPanel_IndicatorDispatch(unsigned char a)
{
	unsigned char g;
	unsigned int m;

	g = a & 0xf0;
	m = CtrlPanel_LookupIndicatorEntry(a & 0x0f);
	switch (g) {
	case 0x00:
		LED_REQUEST_HOLD_1 |= m;
		break;
	case 0x20:
		LED_REQUEST_HOLD_2 |= m;
		break;
	case 0x40:
		LED_REQUEST_HOLD_3 |= m;
		break;
	case 0x60:
		ram_8f48 |= m;
		break;
	}
}
void CtrlPanel_SetIndicatorBit(unsigned char a)
{
	unsigned char g;
	unsigned int m;

	g = a & 0xf0;
	m = CtrlPanel_LookupIndicatorEntry(a & 0x0f);
	switch (g) {
	case 0x00:
		LED_REQUEST_1 |= m;
		break;
	case 0x20:
		LED_REQUEST_2 |= m;
		break;
	case 0x40:
		LED_REQUEST_3 |= m;
		break;
	case 0x60:
		ram_8f46 |= m;
		break;
	}
}
