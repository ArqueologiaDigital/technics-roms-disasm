/* lane_p6 helper K, round 27r1, form c: module 234 (sequencer/sequencer_engine.s), one-spot retry of
   SeqPart_LoadDualPartData / SeqPart_LoadAndValidateData from p6_I_26r1m234a (run 2026-11-22-5-p6-r72, O3Xr equal
   up to the bar advance, where V4.23 wrote add-to-memory).  Here the old bar is read into a plain local, then the
   sum is stored.
   cc900-options: -O3 -Xr
*/

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
			w = SEQ_OP_DEST_MEASURE;
			SEQ_OP_DEST_MEASURE = w + SEQ_OP_MEASURES;
		}
	}
}

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
			w = SEQ_OP_DEST_MEASURE;
			SEQ_OP_DEST_MEASURE = w + SEQ_OP_MEASURES;
		}
	}
}
