/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord Part_ReadByteDirect Part_ReadVoiceWord Part_SetClearVoiceBit7 Part_StealAndReallocVoices Part_WriteByte Part_WriteByte_Indexed Part_WriteVoiceWord Part_WriteWord_Indexed SeqBuf_FlushAndReinit_NoteEvents SeqNotePool_Init Seq_ValidatePartNumber Seq_ValidateTempoValue */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_StealAndReallocVoices(unsigned int);
extern void Part_SetClearVoiceBit7(unsigned char s, unsigned char p, unsigned char on);
extern void Part_ClearAndStealSingleVoice(unsigned char p);
extern unsigned char __near ram_1d80;
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);
extern void SeqNotePool_Init(unsigned int);
extern void SeqBuf_WriteNoteOffEntry(unsigned char ch);
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned int __near SEQ_OP_DEST_MEASURE;
extern int Seq_ValidatePartNumber(unsigned int);
extern int Seq_ValidateTempoValue(unsigned int);
extern int Seq_ValidatePartAndTempo(void);

void Part_ClearAndStealSingleVoice(unsigned char p)
{
	unsigned int v;

	Part_SetClearVoiceBit7(0, p, 0);
	v = Part_ReadVoiceWord(0, p);
	Part_WriteVoiceWord(0, p, 0xffff);
	Part_WriteWord_Indexed(0, p, 0xffff);
	Part_WriteByte_Indexed(0, p, 5);
	Part_StealAndReallocVoices(v);
}

void SeqBuf_WriteNoteOffEntry(unsigned char ch)
{
	unsigned char b[8];

	if (ram_1d80 != 0)
		SeqBuf_FlushAndReinit_VoiceCCEvents();
	b[0] = 0x90;
	b[1] = 0x7f;
	b[2] = 0;
	b[3] = 0;
	if (ch == 0x32)
		b[4] = 0x7f;
	else
		b[4] = ch - 1;
	SeqBuf_WriteBytes(5, b);
	SeqBuf_FlushAndReinit_NoteEvents();
	if (ch == 0x32)
		SeqNotePool_Init(0x32);
}

int Seq_ValidatePartAndTempo(void)
{
	if (SEQ_TRACK != 0x7f) {
		if (Seq_ValidatePartNumber(SEQ_TRACK) != 0)
			return -1;
		if (Seq_ValidatePartNumber(SEQ_OP_DEST_TRACK) != 0)
			return -1;
	}
	if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_DEST_MEASURE) != 0)
		return -1;
	return 0;
}
