/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -XS -Xr
*/
/* cc900-module: AnalogIn_PollAfterTouch AnalogIn_PollExpressionPedal ArpQueue_Enqueue ArpQueue_InitBuffer Audio_FlushPendingBankSelects MidiChan_ParseVoiceData PanelTlv_WriteBlock0Headers PanelTlv_WriteBlock1Headers PanelTlv_WriteLivePanelHeaders PanelTlv_WritePMemHeaders SeqBuf_WaitForEmpty SeqData_InitPlaybackFromField SeqOut_FlushWithChunking */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void PanelTlv_WriteLivePanelHeaders(void);
/* cc900-name: PanelTlv_WritePMemHeaders=PanelTlv_WritePanelMemoryHeaders */
extern void PanelTlv_WritePMemHeaders(void);
extern void PanelTlv_WriteAllHeaders(void);

void PanelTlv_WriteAllHeaders(void)
{
  PanelTlv_WriteLivePanelHeaders();
  PanelTlv_WritePMemHeaders();
}
