/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: AnalogIn_PollAfterTouch AnalogIn_PollExpressionPedal ArpQueue_Enqueue ArpQueue_InitBuffer Audio_FlushPendingBankSelects MidiChan_ParseVoiceData PanelTlv_WriteBlock0Headers PanelTlv_WriteBlock1Headers PanelTlv_WriteLivePanelHeaders PanelTlv_WritePanelMemoryHeaders SeqBuf_WaitForEmpty SeqData_InitPlaybackFromField SeqOut_FlushWithChunking */   /* scripts/analysis/cc900/module_calls.py v10 */

struct mq;
struct tmpl16;
typedef struct mq *mqp;
typedef struct tmpl16 *tp16;
extern mqp __near MIDISEQ_ACTIVE_BLOCK_PTR;
extern tp16 __near MIDISEQ_ACTIVE_BUF_PTR;
extern void ArpQueue_InitBuffer(struct mq *q, struct tmpl16 *t);
extern void MidiSeq_ReinitCurrentBuffer(void);
extern unsigned char ram_340f8;
extern unsigned char __near ram_b750;
extern void SndParam_ApplyAndSync(void);
extern void SoundMode_SetReverbType(void);
extern void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned int);
extern void MidiCtrl_GmBitToPolyphonyMode(unsigned char a);

void MidiSeq_ReinitCurrentBuffer(void)
{
  ArpQueue_InitBuffer(MIDISEQ_ACTIVE_BLOCK_PTR, MIDISEQ_ACTIVE_BUF_PTR);
}

void SoundMode_SetReverbType(void)
{
  switch (ram_340f8) {
  default:
    ram_b750 = 128;
    break;
  case 1:
    ram_b750 = 155;
    break;
  case 2:
    ram_b750 = 156;
    break;
  case 3:
    ram_b750 = 157;
    break;
  }
  SndParam_ApplyAndSync();
}

void MidiCtrl_GmBitToPolyphonyMode(unsigned char a)
{
  unsigned char c = 0;
  if (a & 0x04) c = 1;
  SubCPU_SetPolyphonyModeAndResendVolumes(c);
}
