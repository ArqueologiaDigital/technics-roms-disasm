/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_mode_handlers.c (2026-11-16-55-p6-r10)
   sha256 60a10fd657f38e3147b987886ac918ce0139df81b88a61ee998701ccab02e7f8 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void A_Short_Pause(void)
{
	unsigned int i, j;

	for (i = 0; i < 0x1000; i++)
		for (j = 0; j < 0x100; j++)
			;
}
