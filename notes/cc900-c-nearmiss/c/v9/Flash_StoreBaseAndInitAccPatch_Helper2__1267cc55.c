/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/flash_floppy_handlers_xr.c (2026-11-16-38-p6-r6)
   sha256 1267cc550ab43ea3d044a0fa842b4d7b3c39895b72eed0ffe08bf5d467a58d97 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr
   cc900-name: Flash_StoreBaseAccPatch_Helper2=Flash_StoreBaseAndInitAccPatch_Helper2 */
unsigned char Flash_StoreBaseAccPatch_Helper2(unsigned char a)
{
	unsigned char r;

	if (a < 10) r = 48;
	else if (a < 20) r = 49;
	else if (a < 30) r = 50;
	else {
		r = 52;
		if (a >= 40) return r;
		r = 51;
	}
	return r;
}
