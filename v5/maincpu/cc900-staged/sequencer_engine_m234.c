/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

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
extern void SeqPart_DualPartLoad(void);
extern void SeqPart_LoadAndValidateData(void);
extern unsigned char __near SQEDT_MINS_REPEAT;
extern unsigned char __near SQEDT_MINS_TRACK_B;
extern unsigned int __near SQEDT_MINS_AT;
extern void SeqPart_ByteBlockA95A(void);
extern void SeqPart_LoadDualPartData(void);

void SeqPart_LoadAndValidateData(void)
{
	unsigned char i;
	unsigned char t;
	unsigned int w;

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
			w = SEQ_OP_DEST_MEASURE + SEQ_OP_MEASURES;
			SEQ_OP_DEST_MEASURE = w;
		}
	}
}

void SeqPart_LoadDualPartData(void)
{
	unsigned char i;
	unsigned char t;
	unsigned int w;

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
			w = SEQ_OP_DEST_MEASURE + SEQ_OP_MEASURES;
			SEQ_OP_DEST_MEASURE = w;
		}
	}
}
