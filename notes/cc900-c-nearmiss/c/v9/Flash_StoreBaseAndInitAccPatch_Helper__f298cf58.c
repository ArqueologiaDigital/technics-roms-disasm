/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/flash_floppy_handlers_m159.c (2026-11-16-68-p6-r12)
   sha256 f298cf58f1e95017152f8f428de512d851044cb54b5fa7524a5e6601f38af3d0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: Flash_StoreBaseAccPatch_Helper=Flash_StoreBaseAndInitAccPatch_Helper */
unsigned char Flash_StoreBaseAccPatch_Helper(unsigned char a)
{
	unsigned char r;

	if (a < 10) r = a + 48;
	else if (a < 20) r = a + 38;
	else if (a < 30) r = a + 28;
	else if (a < 40) r = a + 18;
	else r = a + 8;
	return r;
}
