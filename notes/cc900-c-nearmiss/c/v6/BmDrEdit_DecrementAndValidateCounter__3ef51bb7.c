/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/bmdredit_routines_m232.c (2026-11-16-68-p6-r12)
   sha256 3ef51bb74e95bbb7d635a9dd37a802d1b3988a4303a28a31816e87d4cf1c2a52 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: BmDrEdit_DecrValidateCounter=BmDrEdit_DecrementAndValidateCounter */
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void SeqData_SetErrorCode(unsigned int);
int BmDrEdit_DecrValidateCounter(unsigned int *blk, unsigned int *off)
{
	(*off)--;
	if (*off >= 5) return 0;
	*blk = PartCtrl_ReadWord_Off1(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa0);
		return -1;
	}
	*off = 0xff;
	return 0;
}
