/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-22-6-p6-r73)
   sha256 353a617c20fac00e9cb4df8e12747c8535d8163504f0a502dbb89a8dc82774f9 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
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
