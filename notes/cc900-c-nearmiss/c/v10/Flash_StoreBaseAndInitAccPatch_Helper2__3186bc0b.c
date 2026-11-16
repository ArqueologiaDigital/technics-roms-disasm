/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3a.c (2026-11-16-37-p6-r5)
   sha256 3186bc0bbe1ff510f5c448c06940ec3afa58641942c0c826f244eafcbc9d2b38 (tar-sha256); compiled at -O3 -Xr
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
