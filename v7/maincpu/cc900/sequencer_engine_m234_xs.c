/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -XS -Xr
*/
/* cc900-module: PartCtrl_ReadWord PartCtrl_ReadWord_Off1 PartCtrl_SetClearBit7 PartCtrl_TestBit7 PartCtrl_WriteByteToBuf PartCtrl_WriteWord PartCtrl_WriteWord_Off1 Part_DeallocVoices1And2 Part_ReadVoiceBit7 Part_ReadVoiceWord Part_UnlinkVoiceFromChain Part_ValidateVoiceChannel Part_WriteVoiceWord Part_WriteWordBlock_OffsetAF Part_WriteWord_Indexed SeqData_ReadNextByte SeqPlay_AllocBuffersAndInit */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near ACC_RUN_FLAGS;
extern unsigned char __near ram_1d90;
extern unsigned char __near ram_11f4;
extern unsigned char __near ram_1d5e;
extern unsigned char __near ram_1da0;
extern void SeqRestart_CheckAndDispatch(void);
extern void BitMapOut_PrepareAndRender(int);
extern void SeqPlay_AllocBuffersAndInit(void);
extern void SeqPlay_CheckStartConditions(void);
extern void SeqPlay_HandleVoiceReassign(void);

void SeqPlay_HandleVoiceReassign(void)
{
  unsigned char f;

  if ((SEQ_CONTROL_FLAGS & 0x04) && !(PANEL_STYLE[5] & 0x30)) {
    SeqRestart_CheckAndDispatch();
    f = SEQ_CONTROL_FLAGS;
    f &= ~0x04;
    f |= 0x10;
    SEQ_CONTROL_FLAGS = f;
  }
  if (ram_1d90 != 0 && !(ACC_TRANSPORT_STATE & 0x04) && !(SEQ_TRANSPORT_STATE & 0x14)) {
    ram_11f4 = 0;
    BitMapOut_PrepareAndRender(0);
    ram_1d90 = 0;
  }
  if ((SEQ_CONTROL_FLAGS & 0x10) && !(ACC_TRANSPORT_STATE & 0x04) && !(SEQ_TRANSPORT_STATE & 0x14)
      && ram_1d5e == 0 && !(ACC_RUN_FLAGS & 0x02)) {
    SeqPlay_AllocBuffersAndInit();
    SEQ_CONTROL_FLAGS &= ~0x10;
  }
  if (ram_1da0 == 0) return;
  if (SEQ_TRANSPORT_STATE & 0x1c) return;
  SeqPlay_CheckStartConditions();
  ram_1da0 = 0;
}
