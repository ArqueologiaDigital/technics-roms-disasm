/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m234.c (2026-11-22-8-p6-r75)
   sha256 af074566423bdb0c16fdf164b7ec2a10ef6a92c59be03dfb61f6d319bcb8dc6e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
