/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_26r1m234b.c (2026-11-22-5-p6-r72)
   sha256 f316df6085e8748df6652fc087065511a652687f1f637e8ac98e407668b66221 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SQEDT_MINS_REPEAT;
extern unsigned char __near SQEDT_MINS_TRACK_B;
extern unsigned int __near SQEDT_MINS_AT;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned int __near SEQ_OP_DEST_MEASURE;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char __near SEQ_ERROR_CODE;
extern void SeqPart_ByteBlockA95A(void);
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
