/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: AnalogIn_PollAfterTouch AnalogIn_PollExpressionPedal ArpQueue_Enqueue ArpQueue_InitBuffer Audio_FlushPendingBankSelects MidiChan_ParseVoiceData PanelTlv_WriteBlock0Headers PanelTlv_WriteBlock1Headers PanelTlv_WriteLivePanelHeaders PanelTlv_WritePanelMemoryHeaders SeqBuf_WaitForEmpty SeqData_InitPlaybackFromField SeqOut_FlushWithChunking */   /* scripts/analysis/cc900/module_calls.py v10 */

extern volatile int __near SYSTEM_TIMESTAMP;
extern void MidiStream_Delay25Ticks(void);
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd00;
extern unsigned char __near ram_bd0c;
extern void MidiChan_SetVoiceBaseState(void);
extern void ArpQueue_Enqueue(void);
extern long __near ram_bc5c;
extern void SeqOut_FlushWithChunking(long);
extern void ArpQueue_SwapBuffers(void);
extern void Param_SignExt_H3_Helper2(void);
extern void MidiSeq_SwapActiveBuffers(void);
extern void SeqBuf_WaitForEmpty(void);
extern void MidiChan_ParseVoiceData(void);
extern void SeqData_InitPlaybackFromField(void);
extern void SeqAlt_CheckInitBuffer(void);
extern void SeqAlt_ProcessAndFinalize(void);

void MidiStream_Delay25Ticks(void)
{
  int t;
  t = SYSTEM_TIMESTAMP;
  while (SYSTEM_TIMESTAMP - t < 25)
    ;
}

void MidiChan_SetVoiceBaseState(void)
{
  if (ram_bd18 & 0x40)
    ram_bd00 = 128;
  else
    ram_bd0c = 128;
}

/* cc900-name: Param_SignExt_H3_Helper2=Param_SignExtendReturn_Helper3_Helper2 */
void Param_SignExt_H3_Helper2(void)
{
  ArpQueue_Enqueue();
  SeqOut_FlushWithChunking(ram_bc5c);
  ArpQueue_SwapBuffers();
}

void SeqAlt_ProcessAndFinalize(void)
{
  MidiSeq_SwapActiveBuffers();
  SeqBuf_WaitForEmpty();
  MidiChan_ParseVoiceData();
  SeqData_InitPlaybackFromField();
  SeqAlt_CheckInitBuffer();
}
