/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/bmdredit_routines.c (2026-11-16-55-p6-r10)
   sha256 1c588747f7a7a3af0537047d02d34917a36db8c4a23c0c8642d93ab2c082f5a5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
void BmDrEdit_ClearAndScanToEnd(void)
{
	unsigned int o, b;

	SEQ_ERROR_CODE = 0;
	do {
		o = SEQ_DATA_OFFSET;
		if (o > 5) {
			SEQ_DATA_OFFSET = o - 1;
		} else {
			b = PartCtrl_ReadWord_Off1(SEQ_DATA_BLOCK);
			if (b == 0) {
				SEQ_ERROR_CODE = 255;
				return;
			}
			SEQ_DATA_BLOCK = b;
			SEQ_DATA_OFFSET = 255;
		}
	} while (!(SeqData_ReadNextByte() & 0x80));
}
