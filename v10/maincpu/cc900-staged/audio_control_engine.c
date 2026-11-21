/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char *PanelTlv_PayloadByTag[];

unsigned char *PanelTlv_PayloadOfTag(unsigned char t)
{
  return PanelTlv_PayloadByTag[t];
}

extern void AnalogIn_PollExpressionPedal(unsigned char *);
extern void AnalogIn_PollAfterTouch(unsigned char *);
extern unsigned long CtrlPanel_SingleBitMaskTable[];
extern unsigned char __near ANALOG_MAIN_VOLUME_VALUE;
extern unsigned char __near ANALOG_MAIN_VOLUME_PENDING;
extern void Audio_FlushPendingBankSelects(void);
extern unsigned char __near ram_917e;
extern unsigned char __near ram_917f;
extern unsigned char __near ram_9180;
extern unsigned char __near ram_9181;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern void MIDI_LoadParamsAndDispatchCC(void);

/* cc900-name: ExtData_VoiceCmpDisp_Helper=ExtData_Voice_CompareAndDispatch_Helper */
void AnalogIn_PollCpuAdc(void)
{
  AnalogIn_PollExpressionPedal((unsigned char *)0x8f10L);
  AnalogIn_PollAfterTouch((unsigned char *)0x8f16L);
}

unsigned long CtrlPanel_LookupIndicatorEntry(unsigned char a)
{
  return CtrlPanel_SingleBitMaskTable[a];
}

void ExtData_VoiceCmpDisp_Helper(void)
{
  ANALOG_MAIN_VOLUME_PENDING = ANALOG_MAIN_VOLUME_VALUE | 0x80;
  Audio_FlushPendingBankSelects();
  ram_917e = 176;
  ram_917f = 0;
  ram_9180 = EXTDATA_VALUE;
  ram_9181 = EXTDATA_MASK;
  MIDI_LoadParamsAndDispatchCC();
}
