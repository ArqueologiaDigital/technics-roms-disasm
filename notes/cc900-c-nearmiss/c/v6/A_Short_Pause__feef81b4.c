/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_mode_handlers.c (2026-11-16-55-p6-r10)
   sha256 feef81b489138637ae2edb729d68bee7cfa563f22f5f1d9df96c1a210ad48d73 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void A_Short_Pause(void)
{
	unsigned int i, j;

	for (i = 0; i < 0x1000; i++)
		for (j = 0; j < 0x100; j++)
			;
}
