/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_mode_handlers.c (2026-11-16-55-p6-r10)
   sha256 9b2637ba9b6fb73ef8f43c0b59bfcefa4889a093b6b6875ca235d7efdda2d1e7 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void A_Short_Pause(void)
{
	unsigned int i, j;

	for (i = 0; i < 0x1000; i++)
		for (j = 0; j < 0x100; j++)
			;
}
