/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Accomp_ValidateAutoPlayChordVoice Chan_SetActiveBit NotePool_InsertEntry PartCtrl_ReadWord Part_DeactivateChannel Part_IsVoiceActive Part_ReadVoiceByte Part_SendVoiceOffAndCCEvents Part_ValidateVoiceChannel Rhythm_DispatchNoteAlloc SeqBuf_WriteNoteOffEntry SeqData_ReadNextByte SeqPlay_FindAndActivateVoice SeqPlay_InitStartState SeqStep_HandleNoteOverflow SeqTiming_CompareAndUpdateState SeqVoice_ActivateWithBarSync SeqVoice_DeactivateAndReinit VoiceAlloc_ProcessAll VoiceAlloc_TestBitHigh */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_f218[];
extern unsigned int __near ram_f1f8[];
extern void Part_ValidateVoiceChannel(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);
extern void Part_ValidateVoiceAndSetupSeq(unsigned char a);
extern void Rhythm_DispatchNoteAlloc(unsigned int, unsigned int *, unsigned char *);
extern unsigned int Rhythm_ComputeNoteAllocation(unsigned int a);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern void SeqPos_AdvanceWithWrap(unsigned char a);

void Part_ValidateVoiceAndSetupSeq(unsigned char a)
{
  unsigned int o, b;
  unsigned char t;
  Part_ValidateVoiceChannel(a);
  if (SEQ_ERROR_CODE != 0) return;
  o = ram_f218[(unsigned char)(a - 1)];
  if (o < 5 || o > 0xff) goto bad;
  b = ram_f1f8[(unsigned char)(a - 1)];
  if (b > 0x4d8) { SEQ_ERROR_CODE = 10; return; }
  SEQ_DATA_BLOCK = b;
  SEQ_DATA_OFFSET = o;
  t = SeqData_ReadNextByte();
  if (t != 0x82 && t != 0x84) {
bad:
    SEQ_ERROR_CODE = 11;
    return;
  }
  SEQ_ERROR_CODE = 0;
}

unsigned int Rhythm_ComputeNoteAllocation(unsigned int a)
{
  unsigned int r;
  unsigned char f;
  r = 0;
  f = 0;
  Rhythm_DispatchNoteAlloc(a, &r, &f);
  return r;
}

void SeqPos_AdvanceWithWrap(unsigned char a)
{
  unsigned int n, o;
  n = a;
  o = SEQ_DATA_OFFSET + n;
  SEQ_DATA_OFFSET = o;
  if (o > 0xff) {
    o -= 0x100;
    o += 5;
    SEQ_DATA_OFFSET = o;
    SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
  }
}
