/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5b.c (2026-11-16-45-p6-r9)
   sha256 02668fddc4a7ae9f0dcae741aab0cb2afb9cebcd20d58654e0aa4bfa1965ed0a (tar-sha256); compiled at -O3 -Xr
   cc900-name: BmDrEdit_DecrValidateCounter=BmDrEdit_DecrementAndValidateCounter */
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
int BmDrEdit_DecrValidateCounter(unsigned int *blk, unsigned int *off)
{
	if (--*off >= 5) return 0;
	*blk = PartCtrl_ReadWord_Off1(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa0);
		return -1;
	}
	*off = 0xff;
	return 0;
}
