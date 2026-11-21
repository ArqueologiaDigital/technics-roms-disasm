/* Helper R, round 1 of 2026-11-20: modules 277-288 (ui/cpanel_routines.s, audio/tonegen_fileio_handlers.s,
   audio/audio_control_engine.s, midi/midi_dispatch_handlers.s).  Form a. */
/* cc900-module: AnalogIn_PollAfterTouch AnalogIn_PollExpressionPedal ArpQueue_Enqueue ArpQueue_InitBuffer Audio_FlushPendingBankSelects MidiChan_ParseVoiceData PanelTlv_WriteBlock0Headers PanelTlv_WriteBlock1Headers PanelTlv_WriteLivePanelHeaders PanelTlv_WritePanelMemoryHeaders SeqBuf_WaitForEmpty SeqData_InitPlaybackFromField SeqOut_FlushWithChunking */   /* scripts/analysis/cc900/module_calls.py v10 */
/* cc900-name: Param_SignExt_H3_Helper2=Param_SignExtendReturn_Helper3_Helper2 */
/* cc900-name: ExtData_VoiceCmpDisp_Helper=ExtData_Voice_CompareAndDispatch_Helper */

extern void PanelTlv_WriteLivePanelHeaders(void);
extern void PanelTlv_WritePanelMemoryHeaders(void);
extern void PanelTlv_WriteBlock0Headers(unsigned char *);
extern void PanelTlv_WriteBlock1Headers(unsigned char *);
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
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd00;
extern unsigned char __near ram_bd0c;
extern void MidiSeq_SwapActiveBuffers(void);
extern void SeqBuf_WaitForEmpty(void);
extern void MidiChan_ParseVoiceData(void);
extern void SeqData_InitPlaybackFromField(void);
extern void SeqAlt_CheckInitBuffer(void);
extern void ArpQueue_Enqueue(void);
extern long __near ram_bc5c;
extern long __near ram_bcb4;
extern void SeqOut_FlushWithChunking(long);
extern void ArpQueue_SwapBuffers(void);
extern unsigned char __near MIDIPKT_RX_GROUPS;
extern unsigned char __near ram_10ea;
extern void ArpQueue_InitBuffer(long, long);
extern void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned int);

void DELAY_300_LOOPS(void)
{
  unsigned int i = 300;
  for (;;) {
    if (--i == 0) break;
  }
}

void PanelTlv_WriteAllHeaders(void)
{
  PanelTlv_WriteLivePanelHeaders();
  PanelTlv_WritePanelMemoryHeaders();
}

void PanelTlv_WriteLivePanelHeaders(void)
{
  PanelTlv_WriteBlock0Headers((unsigned char *)0xf9a0L);
  PanelTlv_WriteBlock1Headers((unsigned char *)0xfd60L);
}

int PanelTlv_Rule_KeepBits(unsigned char *base, unsigned char *rule)
{
  base[rule[1]] &= rule[2];
  return 3;
}

int PanelTlv_Rule_StoreByte(unsigned char *base, unsigned char *rule)
{
  base[rule[1]] = rule[2];
  return 3;
}

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

void MidiChan_SetVoiceBaseState(void)
{
  if (ram_bd18 & 0x40)
    ram_bd00 = 128;
  else
    ram_bd0c = 128;
}

void SeqAlt_ProcessAndFinalize(void)
{
  MidiSeq_SwapActiveBuffers();
  SeqBuf_WaitForEmpty();
  MidiChan_ParseVoiceData();
  SeqData_InitPlaybackFromField();
  SeqAlt_CheckInitBuffer();
}

void Param_SignExt_H3_Helper2(void)
{
  ArpQueue_Enqueue();
  SeqOut_FlushWithChunking(ram_bc5c);
  ArpQueue_SwapBuffers();
}

void MidiSysEx_ProcessBlock_Helper5(void)
{
  if (MIDIPKT_RX_GROUPS & 0x10) ram_10ea |= 0x01;
}

void ArpQueue_ReinitCurrentBuffer(void)
{
  ArpQueue_InitBuffer(ram_bc5c, ram_bcb4);
}

void MidiCtrl_GmBitToPolyphonyMode(unsigned char a)
{
  unsigned char c = 0;
  if (a & 0x04) c = 1;
  SubCPU_SetPolyphonyModeAndResendVolumes(c);
}
