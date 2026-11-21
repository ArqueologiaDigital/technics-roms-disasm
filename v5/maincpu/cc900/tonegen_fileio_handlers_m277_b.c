/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: AnalogIn_PollAfterTouch AnalogIn_PollExpressionPedal ArpQueue_Enqueue ArpQueue_InitBuffer Audio_FlushPendingBankSelects MidiChan_ParseVoiceData PanelTlv_ValidateBlock0 PanelTlv_ValidateBlock1 PanelTlv_WriteBlock0Headers PanelTlv_WriteBlock1Headers PanelTlv_WriteLivePanelHeaders PanelTlv_WritePanelMemoryHeaders SeqBuf_WaitForEmpty SeqData_InitPlaybackFromField SeqOut_FlushWithChunking */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int PanelTlv_Rule_SetBits(unsigned char *rec, unsigned char *r);
extern void PanelTlv_ValidateBlock0(unsigned char *mem);
extern void PanelTlv_ValidateBlock1(unsigned char *mem);
extern void ToneGen_DispatchByMode(void);
extern void SwbtWr_NullRet(void);
extern void PanelTlv_ValidateLivePanel(void);
extern unsigned char __near SEQ_SONG_RECORD[];
extern void PanelTlv_ValidateSongPanel(void);
extern int PanelTlv_Rule_KeepBits(unsigned char *base, unsigned char *rule);
extern int PanelTlv_Rule_StoreByte(unsigned char *base, unsigned char *rule);
extern void PanelTlv_WriteLivePanelHeaders(void);
extern void PanelTlv_WriteBlock0Headers(unsigned char *);
extern void PanelTlv_WriteBlock1Headers(unsigned char *);

int PanelTlv_Rule_SetBits(unsigned char *rec, unsigned char *r)
{
  rec[r[1]] |= r[2];
  return 3;
}

void PanelTlv_ValidateLivePanel(void)
{
  PanelTlv_ValidateBlock0((unsigned char *)0xf9a0L);
  PanelTlv_ValidateBlock1((unsigned char *)0xfd60L);
  ToneGen_DispatchByMode();
  SwbtWr_NullRet();
}

void PanelTlv_ValidateSongPanel(void)
{
  PanelTlv_ValidateBlock0(&SEQ_SONG_RECORD[768]);
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

void PanelTlv_WriteLivePanelHeaders(void)
{
  PanelTlv_WriteBlock0Headers((unsigned char *)0xf9a0L);
  PanelTlv_WriteBlock1Headers((unsigned char *)0xfd60L);
}
