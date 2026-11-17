/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5a.c (2026-11-16-45-p6-r9)
   sha256 0a24d3abb3ad01135d3ba1544257bdeae1dc14fc21da9794d409ad64bba47312 (tar-sha256); compiled at -O3 -Xr */
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);
extern void SeqData_SkipToNextEvent(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_2772;
void BmDrEdit_CountMeasuresAndValidate(void)
{
	unsigned char c;

	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xd1);
	ram_2772 = 0;
	for (;;) {
		c = SeqData_ReadNextByte();
		if (c == 0x82 || c == 0x84) break;
		if (c == 0x81) ram_2772++;
		SeqData_SkipToNextEvent();
	}
	if (SEQ_ERROR_CODE == 0) return;
	SeqData_SetErrorCode(0xce);
}
