/* lane_p6 helper N, round 5, form a: module 234 (sequencer/sequencer_engine.s), new functions of the Part_* /
   PartCtrl_* family (siblings of the built Part_ClearVoiceSlot, PartCtrl_ReadWord, SeqBuf_WriteMidiEvent).
   - Part_SetClearVoiceBit7: sets or clears bit 7 of byte 0xd0 + (p - 1) * 3 of song s's part table (the ROM keeps
     -3 and +0xd0 apart: the distributed (p - 1) * 3).
   - Part_ClearAndStealSingleVoice: clears part p of song 0 and re-allocates the voices its block chain held.
   - PartCtrl_WriteBytePair: stores two bytes at offset off of 256-byte block blk at 0xb0000, the second one at
     offset 5 of the next block (PartCtrl_ReadWord) when off is 0xff; -1 at the end of the chain.
   - Seq_ValidatePartAndTempo: the source / destination tracks (unless 0x7f) and the from / measures / destination
     measure values are valid: 0, else -1.
   - SeqBuf_WriteNoteOffEntry: writes the 5-byte all-notes-off entry {0x90, 0x7f, 0, 0, ch - 1 (0x7f for 0x32)}.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord Part_ReadByteDirect Part_ReadVoiceWord Part_SetClearVoiceBit7 Part_StealAndReallocVoices Part_WriteByte Part_WriteByte_Indexed Part_WriteVoiceWord Part_WriteWord_Indexed SeqBuf_FlushAndReinit_NoteEvents Seq_ValidatePartNumber Seq_ValidateTempoValue SeqNotePool_Init */

extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);

void Part_SetClearVoiceBit7(unsigned char s, unsigned char p, unsigned char on)
{
	unsigned char v;

	v = Part_ReadByteDirect(s, (unsigned char)((p - 1) * 3 + 0xd0));
	if (on != 0)
		v |= 0x80;
	else
		v &= ~0x80;
	Part_WriteByte(s, (unsigned char)((p - 1) * 3 + 0xd0), v);
}

extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_StealAndReallocVoices(unsigned int);

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

extern unsigned char ram_b0000[];
extern unsigned int PartCtrl_ReadWord(unsigned int n);

int PartCtrl_WriteBytePair(unsigned int blk, unsigned int off, unsigned char *s)
{
	unsigned char *p;
	unsigned int n;

	p = (unsigned char *)((unsigned long)ram_b0000 + (((unsigned long)(blk - 1) << 8) + off));
	*p = s[0];
	if (off == 0xff) {
		if ((n = PartCtrl_ReadWord(blk)) == 0xffff)
			return -1;
		p = (unsigned char *)((unsigned long)ram_b0000 + (((unsigned long)(n - 1) << 8) + 5));
	} else
		p++;
	*p = s[1];
	return 0;
}

extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned int __near SEQ_OP_DEST_MEASURE;
extern int Seq_ValidatePartNumber(unsigned int);
extern int Seq_ValidateTempoValue(unsigned int);

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

extern unsigned char __near ram_1d86;
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);
extern void SeqNotePool_Init(unsigned int);

void SeqBuf_WriteNoteOffEntry(unsigned char ch)
{
	unsigned char b[8];

	if (ram_1d86 != 0)
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
