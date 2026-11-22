/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_26r1m234a.c (2026-11-22-5-p6-r72)
   sha256 931416bb149309396f32979add96150441423b23123d83e7c9e76f3192f69194 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern void SeqData_SetErrorCode(unsigned int);
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
