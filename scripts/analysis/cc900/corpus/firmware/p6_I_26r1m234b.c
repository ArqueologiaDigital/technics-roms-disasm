/* lane_p6 helper I, round 26r1, form b: module 234 (sequencer/sequencer_engine.s), the functions of form a with
   one spot changed each: SeqPart_LoadDualPartData / SeqPart_LoadAndValidateData take the track by ?: from the
   cell and advance the bar as `x = x + y`; Part_WriteAllVoiceSubBlocks_A / _B index the table with the int
   i - 1; PartCtrl_NavigateBackward / _Alt read the offset once into a local.
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

	if (SQEDT_MINS_REPEAT == 0 || (SEQ_EDIT_FLAGS & 8))
		return;
	SEQ_TRACK = SQEDT_MINS_TRACK_B == 17 ? 127 : SQEDT_MINS_TRACK_B;
	SEQ_OP_FROM = SQEDT_MINS_AT;
	SEQ_OP_DEST_MEASURE = SQEDT_MINS_AT + SEQ_OP_MEASURES;
	for (i = 0; i < SQEDT_MINS_REPEAT; i++) {
		GLOBAL_ERROR_CODE = 0xff;
		SEQ_ERROR_CODE = 0;
		SeqPart_ByteBlockA95A();
		if (GLOBAL_ERROR_CODE != 35)
			return;
		if (SEQ_EDIT_FLAGS & 8)
			return;
		SEQ_OP_DEST_MEASURE = SEQ_OP_DEST_MEASURE + SEQ_OP_MEASURES;
	}
}

void SeqPart_LoadAndValidateData(void)
{
	unsigned char i;

	if (SQEDT_MCP_REPEAT == 0 || (SEQ_EDIT_FLAGS & 8))
		return;
	SEQ_TRACK = SQEDT_MCP_TRACK_B == 17 ? 127 : SQEDT_MCP_TRACK_B;
	SEQ_OP_FROM = SQEDT_MCP_AT;
	SEQ_OP_DEST_MEASURE = SQEDT_MCP_AT + SEQ_OP_MEASURES;
	for (i = 0; i < SQEDT_MCP_REPEAT; i++) {
		GLOBAL_ERROR_CODE = 0xff;
		SEQ_ERROR_CODE = 0;
		SeqPart_DualPartLoad();
		if (GLOBAL_ERROR_CODE != 35)
			return;
		if (SEQ_EDIT_FLAGS & 8)
			return;
		SEQ_OP_DEST_MEASURE = SEQ_OP_DEST_MEASURE + SEQ_OP_MEASURES;
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
		Part_WriteSubBlock32(p, i, PartSubBlkA_WriteLoop32_Table[i - 1]);
	for (i = 1; i <= 16; i++)
		Part_WriteSubBlock48(p, i, PartSubBlkA_WriteLoop48_Table[i - 1]);
}

void Part_WriteAllVoiceSubBlocks_B(unsigned char p)
{
	unsigned char i;

	for (i = 1; i <= 16; i++)
		Part_WriteSubBlock32(p, i, PartSubBlkB_WriteLoop32_Table[i - 1]);
	for (i = 1; i <= 16; i++)
		Part_WriteSubBlock48(p, i, PartSubBlkA_WriteLoop48_Table[i - 1]);
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
	unsigned int o;

	o = SEQOP_SECONDARY_OFFSET;
	if (o != 5)
		SEQOP_SECONDARY_OFFSET = o - 1;
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
	unsigned int o;

	o = SEQOP_PRIMARY_OFFSET;
	if (o != 5)
		SEQOP_PRIMARY_OFFSET = o - 1;
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
