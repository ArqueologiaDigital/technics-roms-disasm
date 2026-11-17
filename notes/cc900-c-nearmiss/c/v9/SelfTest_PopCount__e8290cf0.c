/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_mode_handlers.c (2026-11-16-45-p6-r9)
   sha256 e8290cf0e2c1400fe8302006d65a91fdbadc0fb832aee8e37910df20f825bae4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned char SelfTest_PopCount(unsigned char a)
{
	unsigned char n, i;

	n = 0;
	for (i = 0; i < 8; i++) {
		if (a & 1) n++;
		a >>= 1;
	}
	return n;
}
