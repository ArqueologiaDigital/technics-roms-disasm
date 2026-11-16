/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_mode_handlers.c (2026-11-16-45-p6-r9)
   sha256 e8290cf0e2c1400fe8302006d65a91fdbadc0fb832aee8e37910df20f825bae4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void A_Short_Pause(void)
{
	unsigned int i, j;

	for (i = 0; i < 0x1000; i++)
		for (j = 0; j < 0x100; j++)
			;
}
