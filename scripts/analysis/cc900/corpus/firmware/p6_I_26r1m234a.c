/* lane_p6 helper I, round 26r1, form a: module 234 (sequencer/sequencer_engine.s), family of 2 x 118 B: the
   MEASURE INSERT / MEASURE COPY repeat loops SeqPart_LoadDualPartData (SQEDT_MINS_*, SeqPart_ByteBlockA95A) and
   SeqPart_LoadAndValidateData (SQEDT_MCP_*, SeqPart_DualPartLoad).  Byte counter (the ROM homes it in QIZ), the
   source track through a byte local (17 -> 127), the destination bar advanced with +=.
   Also the families Part_WriteAllVoiceSubBlocks_A / _B (2 x 98 B: two 1..16 byte loops, table byte at i - 1
   computed in the byte) and PartCtrl_NavigateBackward / _Alt (2 x 77 B: step the offset back, else follow the
   block link with error 0x47 / 0x48 or 11).
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord_Off1 PartCtrl_TestBit7 Part_WriteSubBlock32 Part_WriteSubBlock48 SeqData_SetErrorCode */

extern unsigned char __near SQEDT_MINS_REPEAT;
extern unsigned char __near SQEDT_MINS_TRACK_B;
extern unsigned int __near SQEDT_MINS_AT;
extern unsigned char __near SQEDT_MCP_REPEAT;
extern unsigned char __near SQEDT_MCP_TRACK_B;
extern unsigned int __near SQEDT_MCP_AT;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned int __near SEQ_OP_DEST_MEASURE;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char __near SEQ_ERROR_CODE;
extern void SeqPart_ByteBlockA95A(void);
extern void SeqPart_DualPartLoad(void);

void SeqPart_LoadDualPartData(void)
{
	unsigned char i;
	unsigned char t;

	if (SQEDT_MINS_REPEAT != 0 && !(SEQ_EDIT_FLAGS & 8)) {
		t = SQEDT_MINS_TRACK_B;
		if (t == 17)
			t = 127;
		SEQ_TRACK = t;
		SEQ_OP_FROM = SQEDT_MINS_AT;
		SEQ_OP_DEST_MEASURE = SQEDT_MINS_AT + SEQ_OP_MEASURES;
		for (i = 0; i < SQEDT_MINS_REPEAT; i++) {
			GLOBAL_ERROR_CODE = 0xff;
			SEQ_ERROR_CODE = 0;
			SeqPart_ByteBlockA95A();
			if (GLOBAL_ERROR_CODE != 35 || (SEQ_EDIT_FLAGS & 8))
				break;
			SEQ_OP_DEST_MEASURE += SEQ_OP_MEASURES;
		}
	}
}

void SeqPart_LoadAndValidateData(void)
{
	unsigned char i;
	unsigned char t;

	if (SQEDT_MCP_REPEAT != 0 && !(SEQ_EDIT_FLAGS & 8)) {
		t = SQEDT_MCP_TRACK_B;
		if (t == 17)
			t = 127;
		SEQ_TRACK = t;
		SEQ_OP_FROM = SQEDT_MCP_AT;
		SEQ_OP_DEST_MEASURE = SQEDT_MCP_AT + SEQ_OP_MEASURES;
		for (i = 0; i < SQEDT_MCP_REPEAT; i++) {
			GLOBAL_ERROR_CODE = 0xff;
			SEQ_ERROR_CODE = 0;
			SeqPart_DualPartLoad();
			if (GLOBAL_ERROR_CODE != 35 || (SEQ_EDIT_FLAGS & 8))
				break;
			SEQ_OP_DEST_MEASURE += SEQ_OP_MEASURES;
		}
	}
}

extern unsigned char PartSubBlkA_WriteLoop32_Table[];
extern unsigned char PartSubBlkB_WriteLoop32_Table[];
extern unsigned char PartSubBlkA_WriteLoop48_Table[];
extern void Part_WriteSubBlock32(unsigned int, unsigned int, unsigned char);
extern void Part_WriteSubBlock48(unsigned int, unsigned int, unsigned char);

void Part_WriteAllVoiceSubBlocks_A(unsigned char p)
{
	unsigned char i;

	for (i = 1; i <= 16; i++)
		Part_WriteSubBlock32(p, i, PartSubBlkA_WriteLoop32_Table[(unsigned char)(i - 1)]);
	for (i = 1; i <= 16; i++)
		Part_WriteSubBlock48(p, i, PartSubBlkA_WriteLoop48_Table[(unsigned char)(i - 1)]);
}

void Part_WriteAllVoiceSubBlocks_B(unsigned char p)
{
	unsigned char i;

	for (i = 1; i <= 16; i++)
		Part_WriteSubBlock32(p, i, PartSubBlkB_WriteLoop32_Table[(unsigned char)(i - 1)]);
	for (i = 1; i <= 16; i++)
		Part_WriteSubBlock48(p, i, PartSubBlkA_WriteLoop48_Table[(unsigned char)(i - 1)]);
}

extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern void SeqData_SetErrorCode(unsigned int);

void PartCtrl_NavigateBackward(void)
{
	unsigned int b;

	if (SEQOP_SECONDARY_OFFSET != 5)
		SEQOP_SECONDARY_OFFSET--;
	else {
		b = PartCtrl_ReadWord_Off1(SEQOP_SECONDARY_BLOCK);
		if (PartCtrl_TestBit7(b) == 0) {
			SeqData_SetErrorCode(0x47);
			SEQ_ERROR_CODE = 2;
		} else if (b == 0 || b == 0xffff)
			SEQ_ERROR_CODE = 11;
		else {
			SEQOP_SECONDARY_BLOCK = b;
			SEQOP_SECONDARY_OFFSET = 255;
		}
	}
}

void PartCtrl_NavigateBackwardAlt(void)
{
	unsigned int b;

	if (SEQOP_PRIMARY_OFFSET != 5)
		SEQOP_PRIMARY_OFFSET--;
	else {
		b = PartCtrl_ReadWord_Off1(SEQOP_PRIMARY_BLOCK);
		if (PartCtrl_TestBit7(b) == 0) {
			SeqData_SetErrorCode(0x48);
			SEQ_ERROR_CODE = 2;
		} else if (b == 0 || b == 0xffff)
			SEQ_ERROR_CODE = 11;
		else {
			SEQOP_PRIMARY_BLOCK = b;
			SEQOP_PRIMARY_OFFSET = 255;
		}
	}
}
