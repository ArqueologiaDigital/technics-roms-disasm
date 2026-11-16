/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/bmdredit_routines_m232.c (2026-11-16-68-p6-r12)
   sha256 3ef51bb74e95bbb7d635a9dd37a802d1b3988a4303a28a31816e87d4cf1c2a52 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned int __near ram_2758;
extern void SeqData_SkipToNextEvent(void);
void BmDrEdit_CountMeasuresAndValidate(void)
{
	unsigned char c;

	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xd1);
	ram_2758 = 0;
	for (;;) {
		c = SeqData_ReadNextByte();
		if (c == 0x82 || c == 0x84) break;
		if (c == 0x81) ram_2758++;
		SeqData_SkipToNextEvent();
	}
	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xce);
}
