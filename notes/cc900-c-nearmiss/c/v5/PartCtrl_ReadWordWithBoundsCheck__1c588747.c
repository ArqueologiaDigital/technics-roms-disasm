/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines.c (2026-11-16-55-p6-r10)
   sha256 1c588747f7a7a3af0537047d02d34917a36db8c4a23c0c8642d93ab2c082f5a5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
int PartCtrl_ReadWordWithBoundsChk(unsigned int *blk, unsigned int *off)
{
	(*off)++;
	if (*off <= 0xff) return 0;
	*blk = PartCtrl_ReadWord(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa1);
		return -1;
	}
	*off = 5;
	return 0;
}
