/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_26r1m234a.c (2026-11-22-5-p6-r72)
   sha256 931416bb149309396f32979add96150441423b23123d83e7c9e76f3192f69194 (tar-sha256); compiled at -O3 -Xr
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
