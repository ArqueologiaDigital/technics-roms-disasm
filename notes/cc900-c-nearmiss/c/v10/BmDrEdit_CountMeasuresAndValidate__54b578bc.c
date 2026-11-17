/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_7a.c (2026-11-16-53-p6-r11)
   sha256 54b578bcd2edb77a4ee5933401bf4ce7163f6f991f040bbe0895750b5828089c (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_2772;
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);
extern void SeqData_SkipToNextEvent(void);
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
	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xce);
}
